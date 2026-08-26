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
include("tls.jl")
include("connection.jl")

# RPC Protocol message parsing (Level 0)
# Note: protocol.jl also includes Persistent interface constants (Level 2)
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
export DefaultSturdyRef, DefaultOwner, SaveParams, SaveResults
export serialize_sturdy_ref, deserialize_sturdy_ref
export Restorer, RestoreException, RestorerRegistry, DefaultRestorer
export register!, restore, validate_owner, revoke!
export PersistentCapability, SimplePersistentCapability
export can_save, generate_sturdy_ref, is_persistent

# Exports - Promise infrastructure
export PromiseState, PipelineOpKind, PipelineOp, PromisedAnswer
export Promise, PromiseAlreadySettledException
export state, is_resolved, is_rejected, is_settled, question_id
export resolve!, reject!, call_pipelined
export on_resolve!, on_reject!, then

# Exports - Transport layer
export Transport, TransportContractError, IOTransport, TcpTransport, UnixTransport, MockTransport
export send_message, receive_message, send_raw_message
export inject_message!, get_sent_messages, clear_sent_messages!

# Exports - Connection management
export TLSConfig, TLSListenerConfig
export ConnectionState, ExceptionType
export DisconnectedException, TimeoutException, ConnectionFailedException, RemoteException, InvalidCapabilityException, ResourceLimitError
export LocalCapability, RemoteCapability, PendingQuestion, PendingAnswer, Connection
export RemotePromise, PromisedExport, PromiseTracker
export is_connected
export flush_outbound!
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

# Exports - Client RPC
export connect, bootstrap, set_read_deadline!, set_write_deadline!, bootstrap_async, ConnectionOptions
export handle_message!, handle_return!, handle_exception!, handle_resolve!, handle_release!
export start_message_loop!
export NotPersistentException, call_save, call_save_sync
export call_restore, call_restore_sync
export release!

# Exports - Server RPC
export Server, ServerOptions, CallContext
export ExportEntry, promise_export_entry
export is_running, set_running!, client_count, add_client!, remove_client!
export listen, serve, serve_async, shutdown!
export set_result!, set_exception!, export_capability, export_promised_capability!
export handle_bootstrap, handle_call!, handle_finish!, handle_server_release!
export send_resolve!, send_resolve_exception!
export set_restorer!, get_restorer
export handle_save_call!, handle_restore_call!
export register_persistent!, is_save_call

# Exports - Protocol parsing
export MessageType, ReturnType, MessageTargetType, SendResultsToType
export ResolveType, CapDescriptorType, PromisedAnswerOpType
export PromisedAnswerOp, ParsedPromisedAnswer, ParsedCapDescriptor
export ParsedBootstrap, ParsedMessageTarget, ParsedCall, ParsedFinish, ParsedRelease, ParsedResolve, ParsedReturn, ParsedMessage

export parse_rpc_message, parse_cap_descriptor, parse_promised_answer
export build_bootstrap_request, build_return_message, build_bootstrap_return
export build_resolve_message, build_resolve_exception
export ParsedSaveResults, build_save_call, parse_save_results
export ParsedRestoreResults, build_restore_call, parse_restore_results

# Exports - Persistent capability types (Level 2)
export PERSISTENT_INTERFACE_ID, PERSISTENT_ANNOTATION_ID, PERSISTENT_SAVE_METHOD_ID

end # module RPC
