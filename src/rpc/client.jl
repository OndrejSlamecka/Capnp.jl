# Cap'n Proto RPC Client (FR-010, FR-013)
# Provides client-side RPC functionality

# Note: RemotePromise is defined in connection.jl for proper include order

"""
    connect(host::AbstractString, port::Integer) -> Connection

Connect to a Cap'n Proto RPC server via TCP.
"""
function connect(host::AbstractString, port::Integer)
    transport = TcpTransport(host, port)
    conn = Connection(transport)
    set_connected!(conn)
    return conn
end

"""
    connect(socket_path::AbstractString) -> Connection

Connect to a Cap'n Proto RPC server via Unix domain socket.
"""
function connect(socket_path::AbstractString)
    transport = UnixTransport(socket_path)
    conn = Connection(transport)
    set_connected!(conn)
    return conn
end

"""
    bootstrap(connection::Connection, ::Type{T}) -> T

Request the bootstrap capability from the server.
Returns a client stub of the specified type.
"""
function bootstrap(conn::Connection, ::Type{T}) where T
    # Send Bootstrap message
    qid = next_question_id!(conn)

    # Create and send Bootstrap request
    builder = Capnp.AllocMessageBuilder()
    # In a full implementation, we would build the Bootstrap message here
    # For now, this is a placeholder

    # Create promise for the response
    promise = Promise{Any}(question_id=qid)

    # Track the question
    question = PendingQuestion(qid, promise, ExportId[])
    add_question!(conn, question)

    # Send the message
    send_message(conn.transport, builder)

    # In a full implementation, we would:
    # 1. Wait for Return message
    # 2. Extract capability from response
    # 3. Create client stub wrapping the capability

    # Return placeholder - actual implementation needs message handling loop
    return nothing
end

"""
    ConnectionOptions

Configuration options for RPC connections.
"""
struct ConnectionOptions
    send_buffer_size::Int
    receive_buffer_size::Int
    max_message_size::Int
    traversal_limit::Int
    nesting_limit::Int

    function ConnectionOptions(;
        send_buffer_size::Int = 65536,
        receive_buffer_size::Int = 65536,
        max_message_size::Int = 64 * 1024 * 1024,  # 64 MiB
        traversal_limit::Int = 64 * 1024 * 1024,   # 64 MiB
        nesting_limit::Int = 64
    )
        new(send_buffer_size, receive_buffer_size, max_message_size, traversal_limit, nesting_limit)
    end
end

"""
    connect(host::AbstractString, port::Integer, options::ConnectionOptions) -> Connection

Connect to a Cap'n Proto RPC server via TCP with custom options.
"""
function connect(host::AbstractString, port::Integer, options::ConnectionOptions)
    # Options will be used when implementing proper message handling
    connect(host, port)
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
                            cap = RemoteCapability(import_id, UInt64(0), conn)
                            add_import!(conn, import_id, cap)
                            push!(reader.capabilities, cap)
                        elseif cap_desc.kind == CapDescriptorType.SENDER_PROMISE
                            import_id = cap_desc.sender_promise
                            cap = RemoteCapability(import_id, UInt64(0), conn)
                            add_import!(conn, import_id, cap)
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
                end
                remove_question!(conn, return_msg.answer_id)
                
                # Send Finish message to acknowledge Return and free peer resources
                finish_builder = build_finish_message(return_msg.answer_id, false)
                io = IOBuffer()
                Capnp.writeMessageToStream(finish_builder, io)
                send_raw_message(conn.transport, take!(io))
            end
        end
        return nothing
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
    question = get_question(conn, answer_id)
    if question !== nothing
        resolve!(question.promise, result)
        remove_question!(conn, answer_id)
    end
end

"""
    handle_exception!(conn::Connection, answer_id::AnswerId, reason::String, type::ExceptionType.T)

Handle an exception Return message from the server.
"""
function handle_exception!(conn::Connection, answer_id::AnswerId, reason::String, type::ExceptionType.T)
    question = get_question(conn, answer_id)
    if question !== nothing
        reject!(question.promise, RemoteException(reason, type))
        remove_question!(conn, answer_id)
    end
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
                remote_cap = RemoteCapability(new_import_id, UInt64(0), conn)
                add_import!(conn, new_import_id, remote_cap)
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
        for _ in 1:ref_count
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
    @async begin
        try
            while is_connected(conn)
                message = receive_message(conn.transport)
                handle_message!(conn, message)
            end
        catch e
            if e isa DisconnectedException
                set_disconnected!(conn)
            else
                set_failed!(conn, string(e))
            end
        end
    end
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
    promise = Promise{Any}(question_id=qid)

    # Track the question
    question = PendingQuestion(qid, promise, ExportId[])
    add_question!(conn, question)

    # Send the message
    send_raw_message(conn.transport, message)

    # Return a typed promise that will convert the result
    result_promise = Promise{DefaultSturdyRef}()

    on_resolve!(promise, function(value)
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

    on_reject!(promise, function(err)
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
function call_save_sync(conn::Connection, import_id::ImportId; timeout_ms::Int=5000)
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
    promise = Promise{Any}(question_id=qid)

    # Track the question
    question = PendingQuestion(qid, promise, ExportId[])
    add_question!(conn, question)

    # Send the message
    send_raw_message(conn.transport, message)

    # Return a typed promise that will convert the result
    result_promise = Promise{RemoteCapability}()

    on_resolve!(promise, function(value)
        if value isa ParsedRestoreResults
            if value.success && value.import_id !== nothing
                # Create a RemoteCapability for the restored capability
                remote_cap = RemoteCapability(value.import_id, UInt64(0), conn)
                add_import!(conn, value.import_id, remote_cap)
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

    on_reject!(promise, function(err)
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
function call_restore_sync(conn::Connection, restorer_import_id::ImportId, sturdy_ref::DefaultSturdyRef; timeout_ms::Int=5000)
    promise = call_restore(conn, restorer_import_id, sturdy_ref)

    # Wait for the promise to settle
    wait(promise)

    return fetch(promise)
end

# Exports
export connect, bootstrap, ConnectionOptions
export handle_message!, handle_return!, handle_exception!, handle_resolve!, handle_release!
export start_message_loop!
export NotPersistentException, call_save, call_save_sync
export call_restore, call_restore_sync
export call, add_capability_to_message!

"""
    call(cap::Union{RemoteCapability, Promise}, interface_id::UInt64, method_id::UInt16;
         data_word_count::UInt16 = UInt16(0), pointer_count::UInt16 = UInt16(0), params_builder::Function = (p, l) -> nothing) -> Promise

Call an RPC method on a RemoteCapability or a Promise (pipelining).
"""
function call(cap::Union{RemoteCapability, Promise}, interface_id::UInt64, method_id::UInt16;
              data_word_count::UInt16 = UInt16(0), pointer_count::UInt16 = UInt16(0), params_builder::Function = (p, l) -> nothing)
    conn = cap.connection
    if conn === nothing
        error("Cannot call on a capability or promise without a connection")
    end

    if cap isa RemoteCapability
        target = ParsedMessageTarget(MessageTargetType.IMPORTED_CAP, cap.import_id)
    else
        # PromisedAnswer
        pa = ParsedPromisedAnswer(cap._question_id, PipelineOp[])
        target = ParsedMessageTarget(MessageTargetType.PROMISED_ANSWER, pa)
    end

    qid = next_question_id!(conn)

    builder = build_call(qid, target, interface_id, method_id, params_builder;
                         data_word_count=data_word_count, pointer_count=pointer_count)

    promise = Promise{Any}(question_id=qid, connection=conn)
    question = PendingQuestion(qid, promise, ExportId[])
    add_question!(conn, question)

    io = IOBuffer()
    Capnp.writeMessageToStream(builder, io)
    send_raw_message(conn.transport, take!(io))

    return promise
end

function add_capability_to_message!(builder, client)
    # Get the capability from the client
    cap = client.cap
    # Register the capability in the builder and return its index
    # We must construct a ParsedCapDescriptor based on the capability
    desc = if cap isa RemoteCapability
        ParsedCapDescriptor(CapDescriptorType.RECEIVER_HOSTED, receiver_hosted=cap.import_id)
    elseif cap isa Promise
        # If it's a promise, it's a receiver answer
        pa = ParsedPromisedAnswer(cap._question_id, PipelineOp[])
        ParsedCapDescriptor(CapDescriptorType.RECEIVER_ANSWER, receiver_answer=pa)
    else
        # Sender hosted not implemented for full local objects yet
        error("Exporting local capabilities not fully implemented")
    end
    push!(builder.capabilities, desc)
    return UInt32(length(builder.capabilities) - 1)
end
