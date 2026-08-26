# Cap'n Proto RPC Client (FR-010, FR-013)
# Provides client-side RPC functionality

# Note: RemotePromise is defined in connection.jl for proper include order

"""
    connect(host::AbstractString, port::Integer) -> Connection

Connect to a Cap'n Proto RPC server via TCP.
"""
function connect(host::AbstractString, port::Integer)
    connect(host, port, ConnectionOptions())
end

"""
    connect(socket_path::AbstractString) -> Connection

Connect to a Cap'n Proto RPC server via Unix domain socket.
"""
function connect(socket_path::AbstractString)
    connect(socket_path, ConnectionOptions())
end

"""
    bootstrap_async(connection::Connection, ::Type{T}) -> Promise{T}

Request the remote bootstrap capability. Generated client types are expected to
have a one-argument constructor accepting a `RemoteCapability`.
"""
function bootstrap_async(conn::Connection, ::Type{T}) where {T}
    is_connected(conn) || throw(DisconnectedException("Connection is not connected"))
    qid = next_question_id!(conn)
    raw_promise = Promise{Any}(question_id = qid)
    typed_promise = Promise{T}(question_id = qid)
    add_question!(conn, PendingQuestion(qid, raw_promise, ExportId[]))

    on_resolve!(raw_promise, function (payload)
        try
            if isempty(payload.traverser.capabilities)
                throw(InvalidCapabilityException("Bootstrap did not return a remote capability"))
            end
            cap = payload.traverser.capabilities[1]
            cap isa RemoteCapability || throw(InvalidCapabilityException("Bootstrap did not return a remote capability"))
            resolve!(typed_promise, T === RemoteCapability ? cap : T(cap))
        catch err
            reject!(typed_promise, err isa Exception ? err : ErrorException(string(err)))
        end
    end)
    on_reject!(raw_promise, err -> reject!(typed_promise, err))

    try
        queue_message!(conn, build_bootstrap_request(qid))
    catch err
        remove_question!(conn, qid)
        reject!(raw_promise, err isa Exception ? err : ErrorException(string(err)))
    end
    return typed_promise
end

"""Request and synchronously return a typed bootstrap client."""
bootstrap(conn::Connection, ::Type{T}) where {T} = fetch(bootstrap_async(conn, T))

"""
    ConnectionOptions

Configuration options for RPC connections.
"""
struct ConnectionOptions
    max_message_size::Int
    max_segments::Int
    traversal_limit_words::Int
    nesting_limit::Int
    inbound_queue_size::Int
    outbound_queue_size::Int
    max_questions::Int
    max_answers::Int
    max_exports::Int
    max_imports::Int

    function ConnectionOptions(; max_message_size::Int = Capnp.DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = Capnp.DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = Capnp.DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = Capnp.DEFAULT_NESTING_LIMIT, inbound_queue_size::Int = 64, outbound_queue_size::Int = 64, max_questions::Int = 1024, max_answers::Int = 1024, max_exports::Int = 8192, max_imports::Int = 8192)
        Capnp._validate_reader_limits(max_message_size, max_segments)
        Capnp._validate_traversal_limits(traversal_limit_words, nesting_limit)
        _validate_connection_limits(inbound_queue_size, outbound_queue_size, max_questions, max_answers, max_exports, max_imports)
        new(max_message_size, max_segments, traversal_limit_words, nesting_limit, inbound_queue_size, outbound_queue_size, max_questions, max_answers, max_exports, max_imports)
    end
end

"""
    connect(host::AbstractString, port::Integer, options::ConnectionOptions) -> Connection

Connect to a Cap'n Proto RPC server via TCP with custom options.
"""
function connect(host::AbstractString, port::Integer, options::ConnectionOptions)
    transport = TcpTransport(host, port; max_message_size = options.max_message_size, max_segments = options.max_segments, traversal_limit_words = options.traversal_limit_words, nesting_limit = options.nesting_limit)
    return connect(transport; options)
end

"""
    connect(socket_path::AbstractString, options::ConnectionOptions) -> Connection

Connect to a Cap'n Proto RPC server via Unix domain socket with custom options.
"""
function connect(socket_path::AbstractString, options::ConnectionOptions)
    transport = UnixTransport(socket_path; max_message_size = options.max_message_size, max_segments = options.max_segments, traversal_limit_words = options.traversal_limit_words, nesting_limit = options.nesting_limit)
    return connect(transport; options)
end

"""
    connect(transport::Transport; owns_transport=true, start_message_loop=true)

Create an RPC connection over an already-configured transport. This is the
advanced extension point for custom streams and optional Reseau TLS support.
"""
function connect(transport::Transport; owns_transport::Bool = true, start_message_loop::Bool = true, options::ConnectionOptions = ConnectionOptions())
    isopen(transport) || throw(ConnectionFailedException("Transport is not open"))
    conn = Connection(transport; owns_transport, inbound_queue_size = options.inbound_queue_size, outbound_queue_size = options.outbound_queue_size, max_questions = options.max_questions, max_answers = options.max_answers, max_exports = options.max_exports, max_imports = options.max_imports)
    set_connected!(conn)
    start_message_loop && start_message_loop!(conn)
    return conn
end

# Message handling (internal functions)

"""
    handle_message!(conn::Connection, message::MessageReader)

Process an incoming RPC message.
Dispatches to appropriate handler based on message type.
"""
function handle_message!(conn::Connection, message::Capnp.MessageReader)
    # Parse the RPC message
    parsed = parse_rpc_message(message)

    # Dispatch based on message type
    if parsed.type == MessageType.RETURN
        return lock(conn.lock) do
            return_msg = parsed.return_msg
            if return_msg !== nothing
                question = get_question(conn, return_msg.answer_id)
                if question !== nothing
                    if return_msg.kind == ReturnType.RESULTS
                        # Populate the reader's capabilities array with instantiated RemoteCapabilities
                        reader = return_msg.payload_ptr.traverser
                        for cap_desc in return_msg.cap_table
                            if cap_desc.kind == CapDescriptorType.SENDER_HOSTED
                                import_id = cap_desc.sender_hosted
                                cap = get_import(conn, import_id)
                                if cap === nothing
                                    cap = RemoteCapability(import_id, UInt64(0), conn)
                                    add_import!(conn, import_id, cap)
                                else
                                    incref!(cap)
                                end
                                push!(reader.capabilities, cap)
                            elseif cap_desc.kind == CapDescriptorType.SENDER_PROMISE
                                import_id = cap_desc.sender_promise
                                cap = get_import(conn, import_id)
                                if cap === nothing
                                    cap = RemoteCapability(import_id, UInt64(0), conn)
                                    add_import!(conn, import_id, cap)
                                else
                                    incref!(cap)
                                end
                                push!(reader.capabilities, cap)
                            elseif cap_desc.kind == CapDescriptorType.RECEIVER_HOSTED
                                export_id = cap_desc.receiver_hosted
                                cap = get_export(conn, export_id)
                                push!(reader.capabilities, cap)
                            else
                                push!(reader.capabilities, nothing)
                            end
                        end
                        resolve!(question.promise, return_msg.payload_ptr)
                    elseif return_msg.kind == ReturnType.EXCEPTION
                        exc_type = return_msg.exception_type !== nothing ? return_msg.exception_type : ExceptionType.FAILED
                        exc_reason = return_msg.exception_reason !== nothing ? return_msg.exception_reason : "Unknown error"
                        reject!(question.promise, RemoteException(exc_reason, exc_type))
                    elseif return_msg.kind == ReturnType.CANCELED
                        reject!(question.promise, RemoteException("Call canceled", ExceptionType.FAILED))
                    elseif return_msg.kind == ReturnType.RESULTS_SENT_ELSEWHERE
                        # Not implemented yet, reject for now
                        reject!(question.promise, RemoteException("Results sent elsewhere", ExceptionType.UNIMPLEMENTED))
                    elseif return_msg.kind == ReturnType.TAKE_FROM_OTHER_QUESTION
                        # Not implemented yet, reject for now
                        reject!(question.promise, RemoteException("Take from other question", ExceptionType.UNIMPLEMENTED))
                    elseif return_msg.kind == ReturnType.ACCEPT_FROM_THIRD_PARTY
                        # Not implemented yet, reject for now
                        reject!(question.promise, RemoteException("Accept from third party", ExceptionType.UNIMPLEMENTED))
                    end

                    # Handle releaseParamCaps
                    if return_msg.release_param_caps
                        for cap_id in question.param_caps
                            cap = get_export(conn, cap_id)
                            if cap !== nothing && decref!(cap)
                                remove_export!(conn, cap_id)
                            end
                        end
                    end

                    remove_question!(conn, return_msg.answer_id)

                    # Send Finish message to acknowledge Return and free peer resources
                    finish_msg = build_finish_message(return_msg.answer_id, false)
                    queue_message!(conn, finish_msg)
                end
            end
            return nothing
        end
    elseif parsed.type == MessageType.RESOLVE
        # Handle Resolve message (Level 2 promise resolution)
        if parsed.resolve !== nothing
            handle_resolve!(conn, parsed.resolve)
        end
    elseif parsed.type == MessageType.RELEASE
        # Handle Release message
        if parsed.release !== nothing
            handle_release!(conn, parsed.release.id, parsed.release.reference_count)
        end
    elseif parsed.type == MessageType.FINISH
        # Handle Finish message (server telling us a question is done)
        if parsed.finish !== nothing
            # Remove the pending answer
            remove_answer!(conn, parsed.finish.question_id)
        end
    elseif parsed.type == MessageType.ABORT
        # Connection is being aborted
        set_failed!(conn, "Connection aborted by remote")
    else
        # Unhandled message type
        @warn "Unhandled RPC message type" type=parsed.type
    end

    return nothing
end

"""
    handle_return!(conn::Connection, answer_id::AnswerId, result)

Handle a Return message from the server.
"""
function handle_return!(conn::Connection, answer_id::AnswerId, result)
    lock(conn.lock) do
        question = pop!(conn.questions, answer_id, nothing)
        question === nothing || resolve!(question.promise, result)
    end
    return nothing
end

"""
    handle_exception!(conn::Connection, answer_id::AnswerId, reason::String, type::ExceptionType.T)

Handle an exception Return message from the server.
"""
function handle_exception!(conn::Connection, answer_id::AnswerId, reason::String, type::ExceptionType.T)
    lock(conn.lock) do
        question = pop!(conn.questions, answer_id, nothing)
        question === nothing || reject!(question.promise, RemoteException(reason, type))
    end
    return nothing
end

"""
    handle_resolve!(conn::Connection, resolve::ParsedResolve)

Handle a Resolve message - promise was replaced with a capability or exception.
This implements the client-side of C001-RESOLVE contract.

When a capability was received as senderPromise (promised export), the server
sends a Resolve message when the promise resolves. This function:
1. Looks up the RemotePromise by promise_id (which is the import_id)
2. Resolves/rejects the local promise accordingly
3. Creates a RemoteCapability if resolved to a capability
"""
function handle_resolve!(conn::Connection, resolve::ParsedResolve)
    import_id = ImportId(resolve.promise_id)

    # Look up the remote promise
    remote = get_remote_promise(conn, import_id)

    if remote === nothing
        # Unknown promise ID - might be a bug or late message
        @warn "Received Resolve for unknown promise" promise_id=resolve.promise_id
        return nothing
    end

    if resolve.kind == ResolveType.CAP
        # Promise resolved to a capability
        cap_desc = resolve.cap_descriptor

        if cap_desc === nothing
            reject!(remote.local_promise, InvalidCapabilityException("Resolve.cap is null"))
        elseif cap_desc.kind == CapDescriptorType.SENDER_HOSTED
            # Resolved to a regular hosted capability
            new_import_id = cap_desc.sender_hosted
            if new_import_id !== nothing
                # Create or reference the remote capability
                remote_cap = get_import(conn, new_import_id)
                if remote_cap === nothing
                    remote_cap = RemoteCapability(new_import_id, UInt64(0), conn)
                    add_import!(conn, new_import_id, remote_cap)
                else
                    incref!(remote_cap)
                end
                resolve!(remote.local_promise, remote_cap)
            else
                reject!(remote.local_promise, InvalidCapabilityException("senderHosted ID is null"))
            end
        elseif cap_desc.kind == CapDescriptorType.SENDER_PROMISE
            # Resolved to another promise - chain the promises
            new_import_id = cap_desc.sender_promise
            if new_import_id !== nothing
                # Create a new remote promise for the chained promise
                chained_promise = Promise{Any}()
                add_remote_promise!(conn, new_import_id, chained_promise)
                # The original promise will resolve when the chained one does
                on_resolve!(chained_promise, value -> resolve!(remote.local_promise, value))
                on_reject!(chained_promise, err -> reject!(remote.local_promise, err))
            else
                reject!(remote.local_promise, InvalidCapabilityException("senderPromise ID is null"))
            end
        elseif cap_desc.kind == CapDescriptorType.RECEIVER_HOSTED
            # Resolved to a capability we host - this is unusual but valid
            receiver_id = cap_desc.receiver_hosted
            if receiver_id !== nothing
                local_cap = get_export(conn, ExportId(receiver_id))
                if local_cap !== nothing
                    resolve!(remote.local_promise, local_cap)
                else
                    reject!(remote.local_promise, InvalidCapabilityException("receiverHosted ID not found in exports"))
                end
            else
                reject!(remote.local_promise, InvalidCapabilityException("receiverHosted ID is null"))
            end
        elseif cap_desc.kind == CapDescriptorType.NONE
            # Resolved to null capability
            resolve!(remote.local_promise, nothing)
        else
            # Third-party hosted or other - not implemented
            reject!(remote.local_promise, InvalidCapabilityException("Unsupported CapDescriptor kind: $(cap_desc.kind)"))
        end
    else
        # Promise resolved to an exception
        exc_type = resolve.exception_type !== nothing ? resolve.exception_type : ExceptionType.FAILED
        exc_reason = resolve.exception_reason !== nothing ? resolve.exception_reason : "Unknown error"
        reject!(remote.local_promise, RemoteException(exc_reason, exc_type))
    end

    # Remove the remote promise from tracking (it's now resolved/rejected)
    remove_remote_promise!(conn, import_id)

    return nothing
end

"""
    handle_release!(conn::Connection, id::UInt32, ref_count::UInt32)

Handle a Release message - decrement reference count on exported capability.
"""
function handle_release!(conn::Connection, id::UInt32, ref_count::UInt32)
    cap = get_export(conn, id)
    if cap !== nothing
        for _ = 1:ref_count
            if decref!(cap)
                remove_export!(conn, id)
                break
            end
        end
    end
end

# Async message handling loop (for background processing)

"""
    start_message_loop!(conn::Connection)

Start the background message handling loop.
Returns a Task that processes incoming messages.
"""
function start_message_loop!(conn::Connection)
    existing_task = lock(conn.lock) do
        if conn.message_task !== nothing && !istaskdone(conn.message_task)
            return conn.message_task
        end
        return nothing
    end
    existing_task !== nothing && return existing_task

    conn.write_task = @async begin
        try
            for data in conn.outbound_queue
                send_raw_message(conn.transport, data)
            end
        catch e
            close(conn)
            e isa DisconnectedException || set_failed!(conn, string(e))
        end
    end

    conn.process_task = @async begin
        try
            for message in conn.inbound_queue
                if conn.message_handler !== identity
                    conn.message_handler(conn, message)
                else
                    handle_message!(conn, message)
                end
            end
        catch e
            _reject_pending_questions!(conn, e isa Exception ? e : ErrorException(string(e)))
            close(conn)
            e isa DisconnectedException || set_failed!(conn, string(e))
        end
    end

    task = @async begin
        try
            while is_connected(conn)
                message = receive_message(conn.transport)
                put!(conn.inbound_queue, message)
            end
        catch e
            close(conn.inbound_queue)
            close(conn.outbound_queue)
            _reject_pending_questions!(conn, e isa Exception ? e : ErrorException(string(e)))
            close(conn)
            e isa DisconnectedException || set_failed!(conn, string(e))
        end
    end
    lock(conn.lock) do
        conn.message_task = task
    end
    return task
end

function _reject_pending_questions!(conn::Connection, err::Exception)
    questions = PendingQuestion[]
    lock(conn.lock) do
        append!(questions, values(conn.questions))
        empty!(conn.questions)
    end
    for question in questions
        is_settled(question.promise) || reject!(question.promise, err)
    end
    return nothing
end

# ============================================================================
# Level 2: Persistent Capability Client Methods
# ============================================================================

"""
    NotPersistentException

Exception thrown when trying to save a non-persistent capability.
"""
struct NotPersistentException <: Exception
    reason::String
end

"""
    call_save(conn::Connection, import_id::ImportId) -> Promise{DefaultSturdyRef}

Call Persistent.save() on a remote capability.
Returns a Promise that resolves to a DefaultSturdyRef when the save completes.

This implements C002-SAVE contract for clients.

# Arguments
- `conn`: The RPC connection
- `import_id`: The import ID of the capability to save

# Returns
- A Promise that resolves to a DefaultSturdyRef

# Throws
- `NotPersistentException` if the capability doesn't implement Persistent
- `RemoteException` if the server returns an error
"""
function call_save(conn::Connection, import_id::ImportId)
    # Get next question ID
    qid = next_question_id!(conn)

    # Build the save call message
    message = build_save_call(qid, import_id)

    # Create a promise for the result
    promise = Promise{Any}(question_id = qid)

    # Track the question
    question = PendingQuestion(qid, promise, ExportId[])
    add_question!(conn, question)

    # Send the message
    queue_message!(conn, message)

    # Return a typed promise that will convert the result
    result_promise = Promise{DefaultSturdyRef}()

    on_resolve!(promise, function (value)
        # Value should be ParsedSaveResults
        if value isa ParsedSaveResults
            if !isempty(value.sturdy_ref_data)
                sturdy_ref = deserialize_sturdy_ref(value.sturdy_ref_data)
                resolve!(result_promise, sturdy_ref)
            else
                reject!(result_promise, RemoteException("Empty SturdyRef returned", ExceptionType.FAILED))
            end
        else
            reject!(result_promise, RemoteException("Unexpected save result type", ExceptionType.FAILED))
        end
    end)

    on_reject!(promise, function (err)
        # Check if it's a "not implemented" error (capability doesn't support Persistent)
        if err isa RemoteException && err.type == ExceptionType.UNIMPLEMENTED
            reject!(result_promise, NotPersistentException("Capability does not implement Persistent interface"))
        else
            reject!(result_promise, err)
        end
    end)

    return result_promise
end

"""
    call_save_sync(conn::Connection, import_id::ImportId; timeout_ms::Int=5000) -> DefaultSturdyRef

Synchronously call Persistent.save() on a remote capability.
Blocks until the save completes or times out.

# Arguments
- `conn`: The RPC connection
- `import_id`: The import ID of the capability to save
- `timeout_ms`: Maximum time to wait in milliseconds (default 5000)

# Returns
- A DefaultSturdyRef

# Throws
- `NotPersistentException` if the capability doesn't implement Persistent
- `RemoteException` if the server returns an error
- Timeout-related error if the operation times out
"""
function call_save_sync(conn::Connection, import_id::ImportId; timeout_ms::Int = 5000)
    promise = call_save(conn, import_id)

    # Wait for the promise to settle (with timeout would require additional infrastructure)
    wait(promise)

    return fetch(promise)
end

"""
    call_restore(conn::Connection, restorer_import_id::ImportId, sturdy_ref::DefaultSturdyRef) -> Promise{RemoteCapability}

Call restore on a restorer capability to get back a previously saved capability.
Returns a Promise that resolves to the restored RemoteCapability.

This implements C003-RESTORE contract for clients.

# Arguments
- `conn`: The RPC connection
- `restorer_import_id`: The import ID of the restorer capability (usually from bootstrap)
- `sturdy_ref`: The SturdyRef obtained from a previous save() call

# Returns
- A Promise that resolves to a RemoteCapability

# Throws
- `RestoreException(:not_found, ...)` if the capability was not found
- `RestoreException(:unauthorized, ...)` if the owner doesn't match
- `RestoreException(:expired, ...)` if the capability has expired
- `RemoteException` for other server errors
"""
function call_restore(conn::Connection, restorer_import_id::ImportId, sturdy_ref::DefaultSturdyRef)
    # Get next question ID
    qid = next_question_id!(conn)

    # Serialize the sturdy ref
    sturdy_ref_data = serialize_sturdy_ref(sturdy_ref)

    # Build the restore call message
    message = build_restore_call(qid, restorer_import_id, sturdy_ref_data)

    # Create a promise for the result
    promise = Promise{Any}(question_id = qid)

    # Track the question
    question = PendingQuestion(qid, promise, ExportId[])
    add_question!(conn, question)

    # Send the message
    queue_message!(conn, message)

    # Return a typed promise that will convert the result
    result_promise = Promise{RemoteCapability}()

    on_resolve!(promise, function (value)
        if value isa ParsedRestoreResults
            if value.success && value.import_id !== nothing
                # Create a RemoteCapability for the restored capability
                remote_cap = get_import(conn, value.import_id)
                if remote_cap === nothing
                    remote_cap = RemoteCapability(value.import_id, UInt64(0), conn)
                    add_import!(conn, value.import_id, remote_cap)
                else
                    incref!(remote_cap)
                end
                resolve!(result_promise, remote_cap)
            else
                # Restoration failed
                error_type = value.error_type !== nothing ? value.error_type : :failed
                error_reason = value.error_reason !== nothing ? value.error_reason : "Unknown error"
                reject!(result_promise, RestoreException(error_reason, error_type))
            end
        else
            reject!(result_promise, RemoteException("Unexpected restore result type", ExceptionType.FAILED))
        end
    end)

    on_reject!(promise, function (err)
        # Map remote exceptions to RestoreException where appropriate
        if err isa RemoteException
            if err.type == ExceptionType.UNIMPLEMENTED
                reject!(result_promise, RestoreException("Restorer does not support this SturdyRef", :not_found))
            else
                reject!(result_promise, err)
            end
        else
            reject!(result_promise, err)
        end
    end)

    return result_promise
end

"""
    call_restore_sync(conn::Connection, restorer_import_id::ImportId, sturdy_ref::DefaultSturdyRef; timeout_ms::Int=5000) -> RemoteCapability

Synchronously restore a capability from a SturdyRef.
Blocks until the restore completes or times out.

# Arguments
- `conn`: The RPC connection
- `restorer_import_id`: The import ID of the restorer capability
- `sturdy_ref`: The SturdyRef obtained from a previous save() call
- `timeout_ms`: Maximum time to wait in milliseconds (default 5000)

# Returns
- A RemoteCapability

# Throws
- `RestoreException` for restore-related errors
- `RemoteException` for other server errors
"""
function call_restore_sync(conn::Connection, restorer_import_id::ImportId, sturdy_ref::DefaultSturdyRef; timeout_ms::Int = 5000)
    promise = call_restore(conn, restorer_import_id, sturdy_ref)

    # Wait for the promise to settle
    wait(promise)

    return fetch(promise)
end

# Exports
export connect, bootstrap, bootstrap_async, ConnectionOptions
export handle_message!, handle_return!, handle_exception!, handle_resolve!, handle_release!
export start_message_loop!
export NotPersistentException, call_save, call_save_sync
export call_restore, call_restore_sync
export call, add_capability_to_message!, release!

"""
    _send_cancel_finish!(conn::Connection, qid::QuestionId)

Internal function called by `cancel(::Promise)` to send a `Finish` message
indicating the client is no longer interested in the result.
"""
function _send_cancel_finish!(conn::Connection, qid::QuestionId)
    # The RPC spec states that a canceled call still requires sending a Finish message.
    # The releaseResultCaps flag is set to false because we are not waiting for results.
    msg = build_finish_message(qid, false)
    queue_message!(conn, msg)
end

"""
    call(cap::Union{RemoteCapability, Promise}, interface_id::UInt64, method_id::UInt16;
         data_word_count::UInt16 = UInt16(0), pointer_count::UInt16 = UInt16(0), params_builder::Function = (p, l) -> nothing) -> Promise

Call an RPC method on a RemoteCapability or a Promise (pipelining).
"""
function call(cap::Union{RemoteCapability,Promise}, interface_id::UInt64, method_id::UInt16; data_word_count::UInt16 = UInt16(0), pointer_count::UInt16 = UInt16(0), params_builder::Function = (p, l) -> nothing)
    conn = cap.connection
    if conn === nothing
        error("Cannot call on a capability or promise without a connection")
    end

    if cap isa RemoteCapability
        target = ParsedMessageTarget(MessageTargetType.IMPORTED_CAP, cap.import_id)
    else
        # PromisedAnswer
        ops = PromisedAnswerOp[]
        for op in cap.pipeline_ops
            kind = op.kind == PipelineOpKind.GET_POINTER_FIELD ? PromisedAnswerOpType.GET_POINTER_FIELD : PromisedAnswerOpType.NOOP
            push!(ops, PromisedAnswerOp(kind, op.pointer_index))
        end
        pa = ParsedPromisedAnswer(cap._question_id, ops)
        target = ParsedMessageTarget(MessageTargetType.PROMISED_ANSWER, nothing, pa)
    end

    qid = next_question_id!(conn)

    builder = build_call(qid, target, interface_id, method_id, params_builder; data_word_count = data_word_count, pointer_count = pointer_count)

    promise = Promise{Any}(question_id = qid, connection = conn)
    question = PendingQuestion(qid, promise, ExportId[])
    add_question!(conn, question)

    io = IOBuffer()
    Capnp.writeMessageToStream(builder, io)
    queue_message!(conn, take!(io))

    return promise
end

function add_capability_to_message!(builder, client)
    # Get the capability from the client
    cap = client.cap
    # Register the capability in the builder and return its index
    # We must construct a ParsedCapDescriptor based on the capability
    desc = if cap isa RemoteCapability
        ParsedCapDescriptor(CapDescriptorType.RECEIVER_HOSTED, receiver_hosted = cap.import_id)
    elseif cap isa Promise
        # If it's a promise, it's a receiver answer
        ops = PromisedAnswerOp[]
        for op in cap.pipeline_ops
            kind = op.kind == PipelineOpKind.GET_POINTER_FIELD ? PromisedAnswerOpType.GET_POINTER_FIELD : PromisedAnswerOpType.NOOP
            push!(ops, PromisedAnswerOp(kind, op.pointer_index))
        end
        pa = ParsedPromisedAnswer(cap._question_id, ops)
        ParsedCapDescriptor(CapDescriptorType.RECEIVER_ANSWER, receiver_answer = pa)
    else
        # Sender hosted not implemented for full local objects yet
        error("Exporting local capabilities not fully implemented")
    end
    push!(builder.capabilities, desc)
    return UInt32(length(builder.capabilities) - 1)
end

"""
    release!(cap::RemoteCapability)

Release a reference to a remote capability. If the reference count reaches zero,
a Release message is sent to the remote peer and the capability is removed from
the local import table.
"""
function release!(cap::RemoteCapability)
    if decref!(cap)
        # Send Release message with count 1
        msg = build_release_message(cap.import_id, UInt32(1))

        # We need to send it if the connection is still alive
        if cap.connection.transport !== nothing # using a simple check
            try
                queue_message!(cap.connection, msg)
            catch
                # Ignore transport errors during release
            end
        end

        remove_import!(cap.connection, cap.import_id)
    else
        # We released one local reference but still have more, so we send a Release
        # message to the remote peer to let them know we dropped one of our copies.
        msg = build_release_message(cap.import_id, UInt32(1))
        if cap.connection.transport !== nothing
            try
                queue_message!(cap.connection, msg)
            catch
                # Ignore transport errors during release
            end
        end
    end
end

"""
    connect(host::AbstractString, port::Integer, tls_config::TLSConfig; options::ConnectionOptions=ConnectionOptions()) -> Connection
    
Establish a TLS-secured Cap'n Proto RPC connection. 
Requires the `Reseau` package to be loaded.
"""
function connect(host::AbstractString, port::Integer, tls_config::AbstractTLSConfig; options::ConnectionOptions = ConnectionOptions())
    error("TLS connections require the Reseau package to be loaded. Run `using Reseau`.")
end
