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

    PipelineOp(kind::PipelineOpKind.T, idx::UInt16=UInt16(0)) = new(kind, idx)
end

# PromisedAnswer references a pending call's result for pipelining
struct PromisedAnswer
    question_id::QuestionId
    transform::Vector{PipelineOp}

    PromisedAnswer(qid::UInt32, ops::Vector{PipelineOp}=PipelineOp[]) = new(qid, ops)
end

"""
    Promise{T}

A promise representing an eventual value of type T.
Supports Cap'n Proto RPC promise pipelining.
"""
mutable struct Promise{T}
    state::PromiseState.T
    result::Union{T, Nothing}
    error::Union{Exception, Nothing}
    waiters::Vector{Condition}
    _question_id::Union{QuestionId, Nothing}
    lock::ReentrantLock

    function Promise{T}(; question_id::Union{QuestionId, Nothing}=nothing) where T
        new{T}(PromiseState.PENDING, nothing, nothing, Condition[], question_id, ReentrantLock())
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
function resolve!(p::Promise{T}, value::T) where T
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
    end
    return p
end

# Allow resolve! with any value that can be converted to T
function resolve!(p::Promise{T}, value) where T
    resolve!(p, convert(T, value))
end

"""
    reject!(promise::Promise, error::Exception)

Reject the promise with an error.
"""
function reject!(p::Promise, error::Exception)
    lock(p.lock) do
        if is_settled(p)
            throw(PromiseAlreadySettledException("Promise already settled"))
        end
        p.error = error
        p.state = PromiseState.REJECTED
        # Wake up all waiters
        for cond in p.waiters
            notify(cond)
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
function Base.fetch(p::Promise{T}) where T
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
    child = Promise{Any}(question_id=parent._question_id)

    # The actual pipelining happens at the RPC protocol level
    # This function just creates the promise structure
    return child
end

# Export everything
export PromiseState, PipelineOpKind, PipelineOp, PromisedAnswer
export Promise, PromiseAlreadySettledException
export state, is_resolved, is_rejected, is_settled, question_id
export resolve!, reject!, call_pipelined
