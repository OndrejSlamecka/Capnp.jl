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
    PendingQuestion

Represents an outgoing RPC call waiting for a response.
"""
struct PendingQuestion
    question_id::QuestionId
    promise::Promise
    param_caps::Vector{ExportId}

    PendingQuestion(qid::QuestionId, promise::Promise, caps::Vector{ExportId}=ExportId[]) =
        new(qid, promise, caps)
end

"""
    PendingAnswer

Represents an incoming RPC call being processed.
"""
mutable struct PendingAnswer
    answer_id::AnswerId
    result_caps::Vector{ExportId}
    pipeline_refs::UInt32

    PendingAnswer(aid::AnswerId, caps::Vector{ExportId}=ExportId[], refs::UInt32=UInt32(0)) =
        new(aid, caps, refs)
end

"""
    Connection

Manages an RPC connection with questions, answers, exports, and imports tables.
"""
mutable struct Connection
    transport::Transport
    _state::ConnectionState.T
    questions::Dict{QuestionId, PendingQuestion}
    answers::Dict{AnswerId, PendingAnswer}
    exports::Dict{ExportId, LocalCapability}
    imports::Dict{ImportId, RemoteCapability}
    next_question_id::QuestionId
    next_export_id::ExportId
    error_reason::Union{String, Nothing}
    lock::ReentrantLock

    function Connection(transport::Transport)
        new(
            transport,
            ConnectionState.CONNECTING,
            Dict{QuestionId, PendingQuestion}(),
            Dict{AnswerId, PendingAnswer}(),
            Dict{ExportId, LocalCapability}(),
            Dict{ImportId, RemoteCapability}(),
            QuestionId(0),
            ExportId(1),  # Export IDs start at 1 (0 is reserved/invalid)
            nothing,
            ReentrantLock()
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
    set_disconnected!(conn)
    close(conn.transport)

    # Reject all pending questions
    for (_, question) in conn.questions
        if !is_settled(question.promise)
            reject!(question.promise, DisconnectedException("Connection closed"))
        end
    end
end

# Exports
export ConnectionState, ExceptionType
export DisconnectedException, ConnectionFailedException, RemoteException, InvalidCapabilityException
export LocalCapability, RemoteCapability, PendingQuestion, PendingAnswer, Connection
export state, is_connected
export set_connected!, set_disconnecting!, set_disconnected!, set_failed!
export question_count, import_count, export_count, answer_count
export next_question_id!, next_export_id!
export add_question!, get_question, remove_question!
export add_answer!, get_answer, remove_answer!
export add_export!, get_export, remove_export!
export add_import!, get_import, remove_import!
export incref!, decref!
