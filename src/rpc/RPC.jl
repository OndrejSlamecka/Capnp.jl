# Cap'n Proto RPC module for Julia
# Provides client and server RPC functionality with promise pipelining

module RPC

using ..Capnp

# Type ID aliases per data-model.md
const QuestionId = UInt32
const AnswerId = UInt32
const ExportId = UInt32
const ImportId = UInt32
const EmbargoId = UInt32

# Capability types and table
include("capability.jl")

# Promise infrastructure (FR-012)
include("promise.jl")

# Transport layer (FR-010, FR-011)
include("transport.jl")

# Connection management (FR-014)
include("connection.jl")

# RPC Protocol message parsing (Level 0)
include("protocol.jl")

# Client RPC (FR-010, FR-013)
include("client.jl")

# Server RPC (FR-015, FR-016, FR-017)
include("server.jl")

# Exports - Type ID aliases
export QuestionId, AnswerId, ExportId, ImportId, EmbargoId

# Exports - Capability types
export CapDescriptorKind, CapDescriptor, CapabilityTable
export sender_hosted, sender_promise, receiver_hosted
export get_descriptor, add_descriptor!, add_sender_hosted!, add_receiver_hosted!, add_null!, clear!

# Exports - Promise infrastructure
export PromiseState, PipelineOpKind, PipelineOp, PromisedAnswer
export Promise, PromiseAlreadySettledException
export state, is_resolved, is_rejected, is_settled, question_id
export resolve!, reject!, call_pipelined

# Exports - Transport layer
export Transport, TcpTransport, UnixTransport, MockTransport
export send_message, receive_message, send_raw_message
export inject_message!, get_sent_messages, clear_sent_messages!

# Exports - Connection management
export ConnectionState, ExceptionType
export DisconnectedException, ConnectionFailedException, RemoteException, InvalidCapabilityException
export LocalCapability, RemoteCapability, PendingQuestion, PendingAnswer, Connection
export is_connected
export set_connected!, set_disconnecting!, set_disconnected!, set_failed!
export question_count, import_count, export_count, answer_count
export next_question_id!, next_export_id!
export add_question!, get_question, remove_question!
export add_answer!, get_answer, remove_answer!
export add_export!, get_export, remove_export!
export add_import!, get_import, remove_import!
export incref!, decref!

# Exports - Client RPC
export connect, bootstrap, ConnectionOptions
export handle_message!, handle_return!, handle_exception!, handle_resolve!, handle_release!
export start_message_loop!

# Exports - Server RPC
export Server, ServerOptions, CallContext
export is_running, set_running!, client_count, add_client!, remove_client!
export listen, serve, serve_async, shutdown!
export set_result!, set_exception!, export_capability
export handle_bootstrap, handle_call!, handle_finish!, handle_server_release!

# Exports - Protocol parsing
export MessageType, ReturnType, MessageTargetType, SendResultsToType
export ParsedBootstrap, ParsedMessageTarget, ParsedCall, ParsedFinish, ParsedRelease, ParsedMessage
export ParsedParams
export parse_rpc_message
export build_return_message, build_bootstrap_return

end # module RPC
