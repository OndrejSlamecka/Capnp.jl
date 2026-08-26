# Cap'n Proto RPC Promise infrastructure (FR-012)
# Provides Promise type with state management and pipelining support

# Promise state enum (module-scoped per constitution)
module PromiseState
@enum T begin
    PENDING   # Awaiting result
    RESOLVED  # Result available
    REJECTED  # Error occurred
end
end

# Pipeline operation kind
module PipelineOpKind
@enum T begin
    NOOP
    GET_POINTER_FIELD
end
end

# Exception thrown when trying to resolve/reject an already settled promise
struct PromiseAlreadySettledException <: Exception
    msg::String
end

# Pipeline operation for promise pipelining
struct PipelineOp
    kind::PipelineOpKind.T
    pointer_index::UInt16

    PipelineOp(kind::PipelineOpKind.T, idx::UInt16 = UInt16(0)) = new(kind, idx)
end

# PromisedAnswer references a pending call's result for pipelining
struct PromisedAnswer
    question_id::QuestionId
    transform::Vector{PipelineOp}

    PromisedAnswer(qid::UInt32, ops::Vector{PipelineOp} = PipelineOp[]) = new(qid, ops)
end

"""
    Promise{T}

A promise representing an eventual value of type T.
Supports Cap'n Proto RPC promise pipelining and Level 2 resolution callbacks.
"""
mutable struct Promise{T}
    state::PromiseState.T
    result::Union{T,Nothing}
    error::Union{Exception,Nothing}
    settled::Base.Event
    _question_id::Union{QuestionId,Nothing}
    connection::Any
    pipeline_ops::Vector{PipelineOp}
    lock::ReentrantLock
    # Level 2: Callbacks for promise resolution
    on_resolve_callbacks::Vector{Function}  # Called with resolved value
    on_reject_callbacks::Vector{Function}   # Called with exception

    function Promise{T}(; question_id::Union{QuestionId,Nothing} = nothing, connection = nothing, pipeline_ops::Vector{PipelineOp} = PipelineOp[]) where {T}
        new{T}(PromiseState.PENDING, nothing, nothing, Base.Event(), question_id, connection, pipeline_ops, ReentrantLock(), Function[], Function[])
    end
end

# Allow Promise() without type parameter (defaults to Any)
Promise(; kwargs...) = Promise{Any}(; kwargs...)

"""
    state(promise::Promise) -> PromiseState.T

Get the current state of the promise.
"""
state(p::Promise) = p.state

"""
    is_resolved(promise::Promise) -> Bool

Check if the promise has been resolved with a value.
"""
is_resolved(p::Promise) = p.state == PromiseState.RESOLVED

"""
    is_rejected(promise::Promise) -> Bool

Check if the promise has been rejected with an error.
"""
is_rejected(p::Promise) = p.state == PromiseState.REJECTED

"""
    is_settled(promise::Promise) -> Bool

Check if the promise has been settled (resolved or rejected).
"""
is_settled(p::Promise) = p.state != PromiseState.PENDING

"""
    question_id(promise::Promise) -> Union{QuestionId, Nothing}

Get the RPC question ID associated with this promise (for pipelining).
"""
question_id(p::Promise) = p._question_id

"""
    resolve!(promise::Promise{T}, value::T)

Resolve the promise with a value.
"""
function resolve!(p::Promise{T}, value::T) where {T}
    callbacks_to_call = Function[]
    lock(p.lock) do
        if is_settled(p)
            throw(PromiseAlreadySettledException("Promise already settled"))
        end
        p.result = value
        p.state = PromiseState.RESOLVED
        notify(p.settled)
        # Collect callbacks to call outside the lock
        append!(callbacks_to_call, p.on_resolve_callbacks)
    end
    # Call callbacks outside the lock to avoid deadlocks
    for cb in callbacks_to_call
        try
            cb(value)
        catch e
            @warn "Promise resolve callback threw exception" exception=e
        end
    end
    return p
end

# Allow resolve! with any value that can be converted to T
function resolve!(p::Promise{T}, value) where {T}
    resolve!(p, convert(T, value))
end

"""
    reject!(promise::Promise, error::Exception)

Reject the promise with an error.
"""
function reject!(p::Promise, err::Exception)
    callbacks_to_call = Function[]
    lock(p.lock) do
        if is_settled(p)
            throw(PromiseAlreadySettledException("Promise already settled"))
        end
        p.error = err
        p.state = PromiseState.REJECTED
        notify(p.settled)
        # Collect callbacks to call outside the lock
        append!(callbacks_to_call, p.on_reject_callbacks)
    end
    # Call callbacks outside the lock to avoid deadlocks
    for cb in callbacks_to_call
        try
            cb(err)
        catch e
            @warn "Promise reject callback threw exception" exception=e
        end
    end
    return p
end

"""
    Base.wait(promise::Promise)

Block until the promise is settled.
"""
function Base.wait(p::Promise)
    is_settled(p) || wait(p.settled)
    return nothing
end

"""
    Base.fetch(promise::Promise{T}) -> T

Block until the promise is settled, then return the value or throw the error.
"""
function Base.fetch(p::Promise{T}) where {T}
    wait(p)
    lock(p.lock) do
        if p.state == PromiseState.RESOLVED
            return p.result::T
        else
            err = p.error
            if err === nothing
                error("Promise rejected without an error")
            end
            throw(err)
        end
    end
end

"""
    call_pipelined(promise::Promise, ops::Vector{PipelineOp}) -> Promise

Create a pipelined promise that calls through the given transform operations
on the result of the parent promise.
"""
function call_pipelined(parent::Promise, ops::Vector{PipelineOp})
    new_ops = copy(parent.pipeline_ops)
    append!(new_ops, ops)
    child = Promise{Any}(question_id = parent._question_id, connection = parent.connection, pipeline_ops = new_ops)
    return child
end

"""
    cancel(promise::Promise)

Cancel the promise. If the promise represents an ongoing RPC question,
sends a Finish message to the server indicating the client no longer
needs the result.
"""
function cancel(p::Promise)
    # Check if we can cancel
    qid, conn = lock(p.lock) do
        if p.state != PromiseState.PENDING || p._question_id === nothing || p.connection === nothing
            return nothing, nothing
        end
        return p._question_id, p.connection
    end

    if qid !== nothing && conn !== nothing
        # Send Finish message with releaseResultCaps = false (cancel)
        # Cap'n Proto RPC says: "If a client wishes to cancel a question, it simply sends a Finish message."
        try
            # Call connection method to send Finish
            # We must import or use the Capnp.RPC connection method here, which will be added below
            _send_cancel_finish!(conn, qid)
        catch e
            @warn "Failed to send cancel message" exception=e
        end
    end

    return
end

# Level 2: Callback registration functions

"""
    on_resolve!(promise::Promise, callback::Function)

Register a callback to be called when the promise resolves.
The callback receives the resolved value as its argument.
If the promise is already resolved, the callback is called immediately.
"""
function on_resolve!(p::Promise, callback::Function)
    call_now = false
    value = nothing
    lock(p.lock) do
        if p.state == PromiseState.RESOLVED
            call_now = true
            value = p.result
        else
            push!(p.on_resolve_callbacks, callback)
        end
    end
    if call_now
        try
            callback(value)
        catch e
            @warn "Promise resolve callback threw exception" exception=e
        end
    end
    return p
end

"""
    on_reject!(promise::Promise, callback::Function)

Register a callback to be called when the promise is rejected.
The callback receives the exception as its argument.
If the promise is already rejected, the callback is called immediately.
"""
function on_reject!(p::Promise, callback::Function)
    call_now = false
    err = nothing
    lock(p.lock) do
        if p.state == PromiseState.REJECTED
            call_now = true
            err = p.error
        else
            push!(p.on_reject_callbacks, callback)
        end
    end
    if call_now
        try
            callback(err)
        catch e
            @warn "Promise reject callback threw exception" exception=e
        end
    end
    return p
end

"""
    then(promise::Promise, on_resolve::Function, on_reject::Function=identity) -> Promise

Register callbacks for both resolution and rejection.
Returns the promise for chaining.
"""
function then(p::Promise, on_resolve_cb::Function, on_reject_cb::Function = identity)
    on_resolve!(p, on_resolve_cb)
    on_reject!(p, on_reject_cb)
    return p
end

# Export everything
export PromiseState, PipelineOpKind, PipelineOp, PromisedAnswer
export Promise, PromiseAlreadySettledException
export state, is_resolved, is_rejected, is_settled, question_id
export resolve!, reject!, call_pipelined
export on_resolve!, on_reject!, then
