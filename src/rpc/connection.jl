# Cap'n Proto RPC Connection management (FR-014)
# Manages RPC connection state and capability tables

# Connection state enum (module-scoped per constitution)
module ConnectionState
@enum T begin
    CONNECTING    # Handshake in progress
    CONNECTED     # Ready for RPC
    DISCONNECTING # Graceful shutdown
    DISCONNECTED  # Closed
    FAILED        # Error state
end
end

# Exception type enum (module-scoped per constitution)
module ExceptionType
@enum T begin
    FAILED
    OVERLOADED
    DISCONNECTED
    UNIMPLEMENTED
end
end

# RPC Exception types
struct TimeoutException <: Exception
    msg::String
end
Base.showerror(io::IO, e::TimeoutException) = print(io, "TimeoutException: ", e.msg)

struct DisconnectedException <: Exception
    reason::String
end

struct ConnectionFailedException <: Exception
    reason::String
end

struct RemoteException <: Exception
    reason::String
    type::ExceptionType.T
end

struct InvalidCapabilityException <: Exception
    reason::String
end

struct ResourceLimitError <: Exception
    resource::Symbol
    limit::Int
end

Base.showerror(io::IO, error::ResourceLimitError) =
    print(io, "RPC resource limit exceeded for ", error.resource, " (limit ", error.limit, ")")

function _validate_connection_limits(inbound_queue_size::Int, outbound_queue_size::Int, max_questions::Int, max_answers::Int, max_exports::Int, max_imports::Int)
    inbound_queue_size > 0 || throw(ArgumentError("inbound_queue_size must be positive"))
    outbound_queue_size > 0 || throw(ArgumentError("outbound_queue_size must be positive"))
    max_questions > 0 || throw(ArgumentError("max_questions must be positive"))
    max_answers > 0 || throw(ArgumentError("max_answers must be positive"))
    max_exports > 0 || throw(ArgumentError("max_exports must be positive"))
    max_imports > 0 || throw(ArgumentError("max_imports must be positive"))
    return nothing
end

function _check_table_limit(table, key, limit::Int, resource::Symbol)
    haskey(table, key) || length(table) < limit || throw(ResourceLimitError(resource, limit))
    return nothing
end

"""
    LocalCapability

A capability exported by the local side of a connection.
"""
mutable struct LocalCapability
    interface_id::UInt64
    impl::Any
    ref_count::UInt32

    LocalCapability(interface_id::UInt64, impl) = new(interface_id, impl, UInt32(1))
end

"""
    incref!(cap::LocalCapability)

Increment the reference count of a local capability.
"""
function incref!(cap::LocalCapability)
    cap.ref_count += 1
    return cap
end

"""
    decref!(cap::LocalCapability) -> Bool

Decrement the reference count of a local capability.
Returns true if the capability should be released (ref_count reached 0).
"""
function decref!(cap::LocalCapability)
    cap.ref_count == 0 && throw(InvalidCapabilityException("Capability reference count is already zero"))
    cap.ref_count -= 1
    return cap.ref_count == 0
end

"""
    RemoteCapability

A capability imported from the remote side of a connection.
"""
mutable struct RemoteCapability
    import_id::ImportId
    interface_id::UInt64
    ref_count::UInt32
    connection::Any  # Will be Connection, declared as Any to avoid circular dependency

    function RemoteCapability(import_id::ImportId, interface_id::UInt64, connection)
        new(import_id, interface_id, UInt32(1), connection)
    end
end

"""
    incref!(cap::RemoteCapability)

Increment the reference count of a remote capability.
"""
function incref!(cap::RemoteCapability)
    cap.ref_count += 1
    return cap
end

"""
    decref!(cap::RemoteCapability) -> Bool

Decrement the reference count of a remote capability.
Returns true if the capability should be released (ref_count reached 0).
"""
function decref!(cap::RemoteCapability)
    cap.ref_count == 0 && throw(InvalidCapabilityException("Capability reference count is already zero"))
    cap.ref_count -= 1
    return cap.ref_count == 0
end

"""
    PendingQuestion

Represents an outgoing RPC call waiting for a response.
"""
struct PendingQuestion
    question_id::QuestionId
    promise::Promise
    param_caps::Vector{ExportId}

    PendingQuestion(qid::QuestionId, promise::Promise, caps::Vector{ExportId} = ExportId[]) = new(qid, promise, caps)
end

"""
    PendingAnswer

Represents an incoming RPC call being processed.
"""
mutable struct PendingAnswer
    answer_id::AnswerId
    result_caps::Vector{ExportId}
    pipeline_refs::UInt32
    result::Any

    PendingAnswer(aid::AnswerId, caps::Vector{ExportId} = ExportId[], refs::UInt32 = UInt32(0)) = new(aid, caps, refs, nothing)
end

"""
    RemotePromise

Tracks a remote promise awaiting a Resolve message.
Used for Level 2 promise resolution on the client side.
"""
struct RemotePromise
    import_id::ImportId           # The promised import (from senderPromise)
    local_promise::Promise{Any}   # Local promise to fulfill on Resolve
end

"""
    PromisedExport

Tracks a promised export that requires an eventual Resolve message.
Used for Level 2 promise resolution on the server side.
"""
struct PromisedExport
    export_id::ExportId
    promise::Promise{Any}  # The underlying promise that will resolve
    resolved::Bool         # Whether Resolve has been sent
end

"""
Create a new promised export that hasn't been resolved yet.
"""
PromisedExport(export_id::ExportId, promise::Promise{Any}) = PromisedExport(export_id, promise, false)

"""
    PromiseTracker

Level 2 promise tracking state for a connection.
Tracks promised exports (server-side) and remote promises (client-side).
"""
mutable struct PromiseTracker
    # Server-side: promises exported that require Resolve messages
    promised_exports::Dict{ExportId,PromisedExport}
    # Client-side: remote promises awaiting Resolve
    remote_promises::Dict{ImportId,RemotePromise}

    PromiseTracker() = new(Dict{ExportId,PromisedExport}(), Dict{ImportId,RemotePromise}())
end

"""
    Connection

Manages an RPC connection with questions, answers, exports, and imports tables.
"""
mutable struct Connection
    transport::Transport
    _state::ConnectionState.T
    questions::Dict{QuestionId,PendingQuestion}
    answers::Dict{AnswerId,PendingAnswer}
    exports::Dict{ExportId,LocalCapability}
    imports::Dict{ImportId,RemoteCapability}
    next_question_id::QuestionId
    next_export_id::ExportId
    error_reason::Union{String,Nothing}
    lock::ReentrantLock
    owns_transport::Bool
    message_task::Union{Task,Nothing}
    # Level 2: Promise tracking
    promise_tracker::PromiseTracker
    # Queues
    inbound_queue::Channel{Capnp.MessageReader}
    outbound_queue::Channel{Vector{UInt8}}
    write_task::Union{Task,Nothing}
    process_task::Union{Task,Nothing}
    message_handler::Function
    max_questions::Int
    max_answers::Int
    max_exports::Int
    max_imports::Int

    function Connection(transport::Transport; owns_transport::Bool = true, inbound_queue_size::Int = 64, outbound_queue_size::Int = 64, max_questions::Int=1024, max_answers::Int=1024, max_exports::Int=8192, max_imports::Int=8192)
        _validate_connection_limits(inbound_queue_size, outbound_queue_size, max_questions, max_answers, max_exports, max_imports)
        new(
            transport,
            ConnectionState.CONNECTING,
            Dict{QuestionId,PendingQuestion}(),
            Dict{AnswerId,PendingAnswer}(),
            Dict{ExportId,LocalCapability}(),
            Dict{ImportId,RemoteCapability}(),
            0,
            0,
            nothing,
            ReentrantLock(),
            owns_transport,
            nothing,
            PromiseTracker(),
            Channel{Capnp.MessageReader}(inbound_queue_size),
            Channel{Vector{UInt8}}(outbound_queue_size),
            nothing,
            nothing,
            identity,
            max_questions,
            max_answers,
            max_exports,
            max_imports,
        )
    end
end

# State accessors
state(conn::Connection) = conn._state
is_connected(conn::Connection) = conn._state == ConnectionState.CONNECTED

# State transitions
function set_connected!(conn::Connection)
    lock(conn.lock) do
        conn._state = ConnectionState.CONNECTED
    end
end

function set_disconnecting!(conn::Connection)
    lock(conn.lock) do
        conn._state = ConnectionState.DISCONNECTING
    end
end

function set_disconnected!(conn::Connection)
    lock(conn.lock) do
        conn._state = ConnectionState.DISCONNECTED
    end
end

function set_failed!(conn::Connection, reason::String)
    lock(conn.lock) do
        conn._state = ConnectionState.FAILED
        conn.error_reason = reason
    end
end

# Table counts
question_count(conn::Connection) = length(conn.questions)
import_count(conn::Connection) = length(conn.imports)
export_count(conn::Connection) = length(conn.exports)
answer_count(conn::Connection) = length(conn.answers)

"""
    next_question_id!(conn::Connection) -> QuestionId

Generate the next unique question ID for an outgoing call.
"""
function next_question_id!(conn::Connection)
    lock(conn.lock) do
        qid = conn.next_question_id
        conn.next_question_id += 1
        return qid
    end
end

"""
    next_export_id!(conn::Connection) -> ExportId

Generate the next unique export ID for a local capability.
"""
function next_export_id!(conn::Connection)
    lock(conn.lock) do
        eid = conn.next_export_id
        conn.next_export_id += 1
        return eid
    end
end

# Question management
function add_question!(conn::Connection, question::PendingQuestion)
    lock(conn.lock) do
        _check_table_limit(conn.questions, question.question_id, conn.max_questions, :questions)
        conn.questions[question.question_id] = question
    end
end

function get_question(conn::Connection, qid::QuestionId)
    lock(conn.lock) do
        get(conn.questions, qid, nothing)
    end
end

function remove_question!(conn::Connection, qid::QuestionId)
    lock(conn.lock) do
        delete!(conn.questions, qid)
    end
end

# Answer management
function add_answer!(conn::Connection, answer::PendingAnswer)
    lock(conn.lock) do
        _check_table_limit(conn.answers, answer.answer_id, conn.max_answers, :answers)
        conn.answers[answer.answer_id] = answer
    end
end

function get_answer(conn::Connection, aid::AnswerId)
    lock(conn.lock) do
        get(conn.answers, aid, nothing)
    end
end

function remove_answer!(conn::Connection, aid::AnswerId)
    lock(conn.lock) do
        delete!(conn.answers, aid)
    end
end

# Export management
function add_export!(conn::Connection, eid::ExportId, cap::LocalCapability)
    lock(conn.lock) do
        _check_table_limit(conn.exports, eid, conn.max_exports, :exports)
        conn.exports[eid] = cap
    end
end

function get_export(conn::Connection, eid::ExportId)
    lock(conn.lock) do
        get(conn.exports, eid, nothing)
    end
end

function remove_export!(conn::Connection, eid::ExportId)
    lock(conn.lock) do
        delete!(conn.exports, eid)
    end
end

# Import management
function add_import!(conn::Connection, iid::ImportId, cap::RemoteCapability)
    lock(conn.lock) do
        _check_table_limit(conn.imports, iid, conn.max_imports, :imports)
        conn.imports[iid] = cap
    end
end

function get_import(conn::Connection, iid::ImportId)
    lock(conn.lock) do
        get(conn.imports, iid, nothing)
    end
end

function remove_import!(conn::Connection, iid::ImportId)
    lock(conn.lock) do
        delete!(conn.imports, iid)
    end
end

# Connection close
function Base.close(conn::Connection)
    pending = PendingQuestion[]
    should_close_transport = false
    lock(conn.lock) do
        conn._state = ConnectionState.DISCONNECTED
        append!(pending, values(conn.questions))
        empty!(conn.questions)
        empty!(conn.answers)
        empty!(conn.exports)
        empty!(conn.imports)
        empty!(conn.promise_tracker.promised_exports)
        empty!(conn.promise_tracker.remote_promises)
        should_close_transport = conn.owns_transport && isopen(conn.transport)
        close(conn.inbound_queue)
        close(conn.outbound_queue)
    end

    if should_close_transport
        close(conn.transport)
    end

    for question in pending
        if !is_settled(question.promise)
            reject!(question.promise, DisconnectedException("Connection closed"))
        end
    end
    return nothing
end

# Level 2: Promise tracking functions

"""
    add_promised_export!(conn, export_id, promise)

Track a promised export that requires a Resolve message.
"""
function add_promised_export!(conn::Connection, export_id::ExportId, promise::Promise{Any})
    lock(conn.lock) do
        _check_table_limit(conn.promise_tracker.promised_exports, export_id, conn.max_exports, :promised_exports)
        conn.promise_tracker.promised_exports[export_id] = PromisedExport(export_id, promise)
    end
end

"""
    get_promised_export(conn, export_id)

Get a promised export by ID.
"""
function get_promised_export(conn::Connection, export_id::ExportId)
    lock(conn.lock) do
        get(conn.promise_tracker.promised_exports, export_id, nothing)
    end
end

"""
    remove_promised_export!(conn, export_id)

Remove a promised export after resolution.
"""
function remove_promised_export!(conn::Connection, export_id::ExportId)
    lock(conn.lock) do
        delete!(conn.promise_tracker.promised_exports, export_id)
    end
end

"""
    add_remote_promise!(conn, import_id, promise)

Track a remote promise awaiting a Resolve message.
"""
function add_remote_promise!(conn::Connection, import_id::ImportId, promise::Promise{Any})
    lock(conn.lock) do
        _check_table_limit(conn.promise_tracker.remote_promises, import_id, conn.max_imports, :remote_promises)
        conn.promise_tracker.remote_promises[import_id] = RemotePromise(import_id, promise)
    end
end

"""
    get_remote_promise(conn, import_id)

Get a remote promise by ID.
"""
function get_remote_promise(conn::Connection, import_id::ImportId)
    lock(conn.lock) do
        get(conn.promise_tracker.remote_promises, import_id, nothing)
    end
end

"""
    remove_remote_promise!(conn, import_id)

Remove a remote promise after resolution.
"""
function remove_remote_promise!(conn::Connection, import_id::ImportId)
    lock(conn.lock) do
        delete!(conn.promise_tracker.remote_promises, import_id)
    end
end

# Exports
export ConnectionState, ExceptionType
export DisconnectedException, TimeoutException, ConnectionFailedException, RemoteException, InvalidCapabilityException, ResourceLimitError
export LocalCapability, RemoteCapability, PendingQuestion, PendingAnswer, Connection
export RemotePromise, PromisedExport, PromiseTracker
export state, is_connected
export set_connected!, set_disconnecting!, set_disconnected!, set_failed!
export question_count, import_count, export_count, answer_count
export next_question_id!, next_export_id!
export add_question!, get_question, remove_question!
export add_answer!, get_answer, remove_answer!
export add_export!, get_export, remove_export!
export add_import!, get_import, remove_import!
export add_promised_export!, get_promised_export, remove_promised_export!
export add_remote_promise!, get_remote_promise, remove_remote_promise!
export incref!, decref!

queue_message!(conn::Connection, data::AbstractVector{UInt8}) = put!(conn.outbound_queue, data)
function flush_outbound!(conn::Connection)
    while isready(conn.outbound_queue)
        data = take!(conn.outbound_queue)
        send_raw_message(conn.transport, data)
    end
end
