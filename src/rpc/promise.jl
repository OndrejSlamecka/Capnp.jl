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
    waiters::Vector{Condition}
    _question_id::Union{QuestionId,Nothing}
    lock::ReentrantLock
    # Level 2: Callbacks for promise resolution
    on_resolve_callbacks::Vector{Function}  # Called with resolved value
    on_reject_callbacks::Vector{Function}   # Called with exception

    function Promise{T}(; question_id::Union{QuestionId,Nothing} = nothing) where {T}
        new{T}(PromiseState.PENDING, nothing, nothing, Condition[], question_id, ReentrantLock(), Function[], Function[])
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
        # Wake up all waiters
        for cond in p.waiters
            notify(cond)
        end
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
        # Wake up all waiters
        for cond in p.waiters
            notify(cond)
        end
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
    if is_settled(p)
        return
    end

    cond = Condition()
    lock(p.lock) do
        if is_settled(p)
            return
        end
        push!(p.waiters, cond)
    end

    wait(cond)
    return
end

"""
    Base.fetch(promise::Promise{T}) -> T

Block until the promise is settled, then return the value or throw the error.
"""
function Base.fetch(p::Promise{T}) where {T}
    wait(p)
    if p.state == PromiseState.RESOLVED
        return p.result::T
    else
        throw(p.error)
    end
end

"""
    call_pipelined(promise::Promise, ops::Vector{PipelineOp}) -> Promise

Create a pipelined promise that calls through the given transform operations
on the result of the parent promise.
"""
function call_pipelined(parent::Promise, ops::Vector{PipelineOp})
    # Create a new promise that represents the pipelined call
    # In a real implementation, this would be tracked by the connection
    # and the Call message would reference the parent via PromisedAnswer
    child = Promise{Any}(question_id = parent._question_id)

    # The actual pipelining happens at the RPC protocol level
    # This function just creates the promise structure
    return child
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
