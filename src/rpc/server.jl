# Cap'n Proto RPC Server (FR-015, FR-016, FR-017)
# Provides server-side RPC functionality

using Sockets

"""
    ExportEntry

Extended export table entry with promise metadata for Level 2.
Tracks whether an export is a promise awaiting resolution.
"""
struct ExportEntry
    capability::Any           # The actual capability
    ref_count::UInt32         # Reference count from remote
    is_promise::Bool          # True if this is a promise export
    promise_id::Union{ExportId,Nothing}  # Link to promise if resolved from one
end

"""
Create a regular (non-promise) export entry.
"""
function ExportEntry(capability::Any, ref_count::UInt32 = UInt32(1))
    ExportEntry(capability, ref_count, false, nothing)
end

"""
Create a promise export entry.
"""
function promise_export_entry(capability, promise_id::ExportId)
    ExportEntry(capability, UInt32(1), true, promise_id)
end

# Note: PromisedExport is defined in connection.jl for proper include order

"""
    ServerOptions

Configuration options for RPC servers.
"""
struct ServerOptions
    max_connections::Int
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

    function ServerOptions(; max_connections::Int = 1000, max_message_size::Int = Capnp.DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = Capnp.DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = Capnp.DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = Capnp.DEFAULT_NESTING_LIMIT, inbound_queue_size::Int = 64, outbound_queue_size::Int = 64, max_questions::Int = 1024, max_answers::Int = 1024, max_exports::Int = 8192, max_imports::Int = 8192)
        max_connections > 0 || throw(ArgumentError("max_connections must be positive"))
        Capnp._validate_reader_limits(max_message_size, max_segments)
        Capnp._validate_traversal_limits(traversal_limit_words, nesting_limit)
        _validate_connection_limits(inbound_queue_size, outbound_queue_size, max_questions, max_answers, max_exports, max_imports)
        new(max_connections, max_message_size, max_segments, traversal_limit_words, nesting_limit, inbound_queue_size, outbound_queue_size, max_questions, max_answers, max_exports, max_imports)
    end
end

"""
    CallContext

Context passed to server method implementations.
Contains connection info and methods to set results or exceptions.
"""
mutable struct CallContext
    connection::Connection
    question_id::QuestionId
    interface_id::UInt64
    method_id::UInt16
    result::Any
    has_exception::Bool
    exception_reason::String
    exception_type::ExceptionType.T
    result_caps::Vector{ExportId}

    function CallContext(conn::Connection, qid::QuestionId, iface_id::UInt64, method_id::UInt16)
        new(conn, qid, iface_id, method_id, nothing, false, "", ExceptionType.FAILED, ExportId[])
    end
end

"""
    set_result!(ctx::CallContext, result)

Set the result of an RPC call.
"""
function set_result!(ctx::CallContext, result)
    ctx.result = result
    ctx.has_exception = false
end

"""
    set_exception!(ctx::CallContext, reason::String, type::ExceptionType.T)

Set an exception for an RPC call.
"""
function set_exception!(ctx::CallContext, reason::String, type::ExceptionType.T)
    ctx.has_exception = true
    ctx.exception_reason = reason
    ctx.exception_type = type

    # Cleanup any result capabilities exported before the exception
    for cap_id in ctx.result_caps
        cap = get_export(ctx.connection, cap_id)
        if cap !== nothing && decref!(cap)
            remove_export!(ctx.connection, cap_id)
        end
    end
    empty!(ctx.result_caps)
end

"""
    export_capability(ctx::CallContext, impl, interface_id::UInt64) -> ExportId

Export a capability to be returned to the client.
"""
function export_capability(ctx::CallContext, impl, interface_id::UInt64)
    eid = next_export_id!(ctx.connection)
    cap = LocalCapability(interface_id, impl)
    add_export!(ctx.connection, eid, cap)
    push!(ctx.result_caps, eid)
    return eid
end

"""
    Server

RPC server that listens for connections and dispatches method calls.
Supports Level 2 persistent capabilities via an optional restorer.
"""
mutable struct Server
    bootstrap_impl::Any
    connection_handler::Union{Function,Nothing}
    clients::Vector{Connection}
    options::ServerOptions
    is_running::Bool
    listener_task::Union{Task,Nothing}
    tcp_server::Any
    lock::ReentrantLock
    # Level 2: Restorer for persistent capabilities
    restorer::Union{DefaultRestorer,Nothing}

    function Server(bootstrap_impl; handler::Union{Function,Nothing} = nothing, options::ServerOptions = ServerOptions(), restorer::Union{DefaultRestorer,Nothing} = nothing)
        new(bootstrap_impl, handler, Connection[], options, false, nothing, nothing, ReentrantLock(), restorer)
    end

    # Support do-block syntax: Server(impl) do conn ... end
    function Server(handler::Function, bootstrap_impl; options::ServerOptions = ServerOptions(), restorer::Union{DefaultRestorer,Nothing} = nothing)
        new(bootstrap_impl, handler, Connection[], options, false, nothing, nothing, ReentrantLock(), restorer)
    end
end

# State accessors
is_running(server::Server) = server.is_running

function set_running!(server::Server, running::Bool)
    lock(server.lock) do
        server.is_running = running
    end
end

# Client management
function client_count(server::Server)
    lock(server.lock) do
        length(server.clients)
    end
end

function add_client!(server::Server, conn::Connection)
    lock(server.lock) do
        push!(server.clients, conn)
    end
end

function remove_client!(server::Server, conn::Connection)
    lock(server.lock) do
        filter!(c -> c !== conn, server.clients)
    end
end

function get_clients(server::Server)
    lock(server.lock) do
        copy(server.clients)
    end
end

"""
    listen(server::Server, host::AbstractString, port::Integer)

Start listening for TCP connections on the specified host and port.
"""
function listen(server::Server, host::AbstractString, port::Integer)
    server.tcp_server = Sockets.listen(Sockets.IPv4(host), port)
    set_running!(server, true)
    return server
end

"""
    listen(server::Server, socket_path::AbstractString)

Start listening for Unix domain socket connections.
"""
function listen(server::Server, socket_path::AbstractString)
    # Remove existing socket file if it exists
    isfile(socket_path) && rm(socket_path)
    server.tcp_server = Sockets.listen(socket_path)
    set_running!(server, true)
    return server
end

"""
    serve(server::Server)

Start the server's accept loop. This function blocks and handles incoming connections.
"""
function serve(server::Server)
    if server.tcp_server === nothing
        error("Server not listening. Call listen() first.")
    end

    set_running!(server, true)

    try
        while is_running(server)
            try
                socket = accept(server.tcp_server)
                handle_new_connection(server, socket)
            catch e
                if e isa EOFError || !is_running(server)
                    break
                end
                @warn "Error accepting connection" exception=e
            end
        end
    finally
        set_running!(server, false)
    end
end

"""
    serve_async(server::Server) -> Task

Start the server's accept loop in a background task.
"""
function serve_async(server::Server)
    server.listener_task = @async serve(server)
    return server.listener_task
end

"""
    handle_new_connection(server::Server, socket)

Handle a new incoming connection.
"""
function handle_new_connection(server::Server, socket)
    # Check max connections
    if client_count(server) >= server.options.max_connections
        close(socket)
        return
    end

    # Create transport and connection
    transport = if socket isa Sockets.TCPSocket
        TcpTransport(socket; max_message_size = server.options.max_message_size, max_segments = server.options.max_segments, traversal_limit_words = server.options.traversal_limit_words, nesting_limit = server.options.nesting_limit)
    else
        UnixTransport(socket, ""; max_message_size = server.options.max_message_size, max_segments = server.options.max_segments, traversal_limit_words = server.options.traversal_limit_words, nesting_limit = server.options.nesting_limit)
    end
    conn = Connection(transport; owns_transport = true, inbound_queue_size = server.options.inbound_queue_size, outbound_queue_size = server.options.outbound_queue_size, max_questions = server.options.max_questions, max_answers = server.options.max_answers, max_exports = server.options.max_exports, max_imports = server.options.max_imports)

    # Call connection handler if set
    if server.connection_handler !== nothing
        if !server.connection_handler(conn)
            close(conn)
            return
        end
    end

    # Mark as connected and add to clients
    set_connected!(conn)
    add_client!(server, conn)

    # Start client handler task
    @async handle_client(server, conn)
end

"""
    handle_client(server::Server, conn::Connection)

Handle messages from a connected client.
"""
function handle_client(server::Server, conn::Connection)
    conn.message_handler = (c, m) -> handle_server_message!(server, c, m)
    start_message_loop!(conn)
    # wait for the connection to close
    try
        wait(conn.process_task)
    catch e
        if !(e isa TaskFailedException && (e.task.exception isa EOFError || e.task.exception isa DisconnectedException))
            @warn "Error handling client" exception=e
        end
    finally
        remove_client!(server, conn)
        close(conn)
    end
end

"""
    handle_server_message!(server::Server, conn::Connection, message)

Process an incoming RPC message on the server side.
Parses the RPC message type and dispatches to appropriate handler.
"""
function handle_server_message!(server::Server, conn::Connection, message::Capnp.MessageReader)
    try
        # Parse the incoming RPC message
        parsed = parse_rpc_message(message)

        if parsed.type == MessageType.BOOTSTRAP
            handle_bootstrap_message!(server, conn, parsed.bootstrap)
        elseif parsed.type == MessageType.CALL
            handle_call_message!(server, conn, parsed.call)
        elseif parsed.type == MessageType.FINISH
            handle_finish_message!(conn, parsed.finish)
        elseif parsed.type == MessageType.RELEASE
            handle_release_message!(conn, parsed.release)
        else
            # Send unimplemented response for unsupported message types
            @warn "Received unsupported RPC message type" type=parsed.type
        end
    catch e
        for (i, frame) in enumerate(stacktrace(catch_backtrace()))
        end
    end
end

"""
    handle_bootstrap_message!(server::Server, conn::Connection, bootstrap::ParsedBootstrap)

Handle a Bootstrap message - export the root capability and send Return.
"""
function handle_bootstrap_message!(server::Server, conn::Connection, bootstrap::ParsedBootstrap)
    # Export the bootstrap capability
    export_id = handle_bootstrap(server, conn)

    # Build and send Return message with the capability
    response = build_bootstrap_return(bootstrap.question_id, export_id)
    queue_message!(conn, response)
end

"""
    handle_call_message!(server::Server, conn::Connection, call::ParsedCall)

Handle a Call message - dispatch to method implementation and send Return.
Includes Level 2 support for Persistent.save() calls.
"""
function handle_call_message!(server::Server, conn::Connection, call::ParsedCall)
    # Create call context
    ctx = CallContext(conn, call.question_id, call.interface_id, call.method_id)

    # Find the target capability
    cap = nothing
    if call.target.kind == MessageTargetType.IMPORTED_CAP && call.target.imported_cap !== nothing
        cap = get_export(conn, ExportId(call.target.imported_cap))
    elseif call.target.kind == MessageTargetType.PROMISED_ANSWER
        # Implement promise pipelining: look up the answer and follow the transform
        pa = call.target.promised_answer
        if pa !== nothing
            answer = get_answer(conn, pa.question_id)
            if answer !== nothing
                # Follow the transform ops (usually GET_POINTER_FIELD)
                # For our simple prototype, we just look up the capability in result_caps based on the first GET_POINTER_FIELD
                if length(pa.transform) > 0 && pa.transform[1].kind == PromisedAnswerOpType.GET_POINTER_FIELD
                    idx = pa.transform[1].get_pointer_field
                    if idx !== nothing && (idx + 1) <= length(answer.result_caps)
                        cap = get_export(conn, answer.result_caps[idx+1])
                    end
                elseif length(answer.result_caps) > 0
                    # Fallback if no transform is provided but we have a capability
                    cap = get_export(conn, answer.result_caps[1])
                end
            end
        end

        # Fallback to bootstrap if not found (legacy behavior)
        if cap === nothing
            cap = get_export(conn, ExportId(1))
        end
    end

    if cap === nothing
        set_exception!(ctx, "Invalid capability", ExceptionType.FAILED)
    else
        # Check if this is a Persistent.save() call (Level 2)
        if is_save_call(call)
            handle_save_call!(server, conn, ctx, cap, call)
        else
            # Dispatch the call to the implementation
            try
                dispatch_method!(cap.impl, call.interface_id, call.method_id, ctx, call.params)
            catch e
                if e isa RemoteException
                    set_exception!(ctx, e.reason, e.type)
                else
                    set_exception!(ctx, string(e), ExceptionType.FAILED)
                end
            end
        end
    end

    # Store the answer so pipelined calls can find it
    answer = PendingAnswer(ctx.question_id, ctx.result_caps, UInt32(0))
    answer.result = ctx.result
    add_answer!(conn, answer)

    # Send Return message
    send_return_response!(conn, ctx)
end

"""
    dispatch_method!(impl, interface_id::UInt64, method_id::UInt16, ctx::CallContext, params)

Dispatch a method call to the implementation.
This function should be overridden by generated code or user implementations.
"""
function dispatch_method!(impl, interface_id::UInt64, method_id::UInt16, ctx::CallContext, params)
    # Default implementation - try to call a method based on naming convention
    # Generated code will provide proper dispatch

    # Try to find a dispatch function for this interface
    method_name = Symbol("dispatch_$(interface_id)_$(method_id)")
    if isdefined(Main, method_name)
        getfield(Main, method_name)(impl, ctx, params)
    else
        set_exception!(ctx, "Method not found: interface=$interface_id method=$method_id", ExceptionType.UNIMPLEMENTED)
    end
end



"""
    send_return_response!(conn::Connection, ctx::CallContext)

Build and send a Return message based on the call context.
"""
function send_return_response!(conn::Connection, ctx::CallContext)
    response = build_return_message(ctx.question_id, ctx.result; has_exception = ctx.has_exception, exception_reason = ctx.exception_reason)
    queue_message!(conn, response)
end

"""
    handle_finish_message!(conn::Connection, finish::ParsedFinish)

Handle a Finish message - clean up the answer.
"""
function handle_finish_message!(conn::Connection, finish::ParsedFinish)
    handle_finish!(conn, finish.question_id, finish.release_result_caps)
end

"""
    handle_release_message!(conn::Connection, release::ParsedRelease)

Handle a Release message - decrement capability reference count.
"""
function handle_release_message!(conn::Connection, release::ParsedRelease)
    handle_server_release!(conn, ExportId(release.id), release.reference_count)
end

"""
    handle_bootstrap(server::Server, conn::Connection) -> ExportId

Handle a Bootstrap message - return the root capability.
"""
function handle_bootstrap(server::Server, conn::Connection)
    # Export the bootstrap capability
    eid = next_export_id!(conn)
    cap = LocalCapability(UInt64(0), server.bootstrap_impl)  # Interface ID 0 for bootstrap
    add_export!(conn, eid, cap)
    return eid
end

"""
    handle_call!(server::Server, conn::Connection, target, interface_id::UInt64, method_id::UInt16, params, question_id::QuestionId)

Handle a Call message - dispatch to the appropriate method implementation.
"""
function handle_call!(server::Server, conn::Connection, target, interface_id::UInt64, method_id::UInt16, params, question_id::QuestionId)
    # Create call context
    ctx = CallContext(conn, question_id, interface_id, method_id)

    # Find the capability to call
    cap = nothing
    if target isa UInt32
        # ImportedCap - look up in exports
        cap = get_export(conn, target)
    end

    if cap === nothing
        set_exception!(ctx, "Invalid capability", ExceptionType.FAILED)
        return send_return!(conn, ctx)
    end

    # Dispatch the call
    try
        # The actual dispatch would call the generated method dispatcher
        # dispatch_interface(cap.impl, interface_id, method_id, ctx, params)
        error("Method dispatch not yet implemented")
    catch e
        if e isa RemoteException
            set_exception!(ctx, e.reason, e.type)
        else
            set_exception!(ctx, string(e), ExceptionType.FAILED)
        end
    end

    # Send return message
    send_return!(conn, ctx)
end

"""
    send_return!(conn::Connection, ctx::CallContext)

Send a Return message for a completed call.
"""
function send_return!(conn::Connection, ctx::CallContext)
    # Build and send Return message
    # In a full implementation, this would serialize the result or exception
    # into a Cap'n Proto Return message and send it over the transport
    return nothing
end

"""
    handle_finish!(conn::Connection, question_id::QuestionId, release_caps::Bool)

Handle a Finish message - clean up the answer entry.
"""
function handle_finish!(conn::Connection, question_id::QuestionId, release_caps::Bool)
    answer = get_answer(conn, question_id)
    if answer !== nothing
        if release_caps
            # Release any capabilities in the result
            for cap_id in answer.result_caps
                cap = get_export(conn, cap_id)
                if cap !== nothing && decref!(cap)
                    remove_export!(conn, cap_id)
                end
            end
        end
        remove_answer!(conn, question_id)
    end
end

"""
    handle_release!(conn::Connection, id::ExportId, ref_count::UInt32)

Handle a Release message - decrement reference count on exported capability.
"""
function handle_server_release!(conn::Connection, id::ExportId, ref_count::UInt32)
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

"""
    send_resolve!(conn::Connection, promise_id::ExportId, export_id::ExportId)

Send a Resolve message to notify the client that a promised capability has resolved.
This implements the server-side of C001-RESOLVE contract.

Called when:
1. A capability was exported as senderPromise (promised export)
2. The underlying promise resolves to an actual capability
"""
function send_resolve!(conn::Connection, promise_id::ExportId, export_id::ExportId)
    # Build and send the Resolve message
    # The resolved capability uses senderHosted to indicate it's now fully available
    message = build_resolve_message(promise_id, CapDescriptorType.SENDER_HOSTED, export_id)
    queue_message!(conn, message)
end

"""
    send_resolve_exception!(conn::Connection, promise_id::ExportId, reason::String, exc_type::ExceptionType.T)

Send a Resolve message with an exception when a promised capability fails to resolve.
"""
function send_resolve_exception!(conn::Connection, promise_id::ExportId, reason::String, exc_type::ExceptionType.T)
    message = build_resolve_exception(promise_id, reason, exc_type)
    queue_message!(conn, message)
end

"""
    export_promised_capability!(ctx::CallContext, promise::Promise{Any}, interface_id::UInt64) -> ExportId

Export a capability that is still a promise (not yet resolved).
Uses senderPromise in the CapDescriptor and sets up a callback to send Resolve when it settles.

This is used when a method returns a capability that isn't immediately available.
"""
function export_promised_capability!(ctx::CallContext, promise::Promise{Any}, interface_id::UInt64)
    conn = ctx.connection
    eid = next_export_id!(conn)

    # Track this as a promised export
    add_promised_export!(conn, eid, promise)

    # Set up callback to send Resolve when the promise settles
    on_resolve!(promise, function (resolved_cap)
        # Export the resolved capability with a new ID
        new_eid = next_export_id!(conn)
        cap = LocalCapability(interface_id, resolved_cap)
        add_export!(conn, new_eid, cap)

        # Send Resolve to client
        send_resolve!(conn, eid, new_eid)

        # Clean up promised export tracking
        remove_promised_export!(conn, eid)
    end)

    on_reject!(promise, function (err)
        # Send Resolve with exception
        reason = err isa Exception ? string(err) : string(err)
        exc_type = err isa RemoteException ? err.type : ExceptionType.FAILED
        send_resolve_exception!(conn, eid, reason, exc_type)

        # Clean up promised export tracking
        remove_promised_export!(conn, eid)
    end)

    return eid
end


# ============================================================================
# Level 2: Server-Side Persistent Capability Handling
# ============================================================================

"""
    set_restorer!(server::Server, restorer::DefaultRestorer)

Configure the server's restorer for persistent capabilities.
"""
function set_restorer!(server::Server, restorer::DefaultRestorer)
    lock(server.lock) do
        server.restorer = restorer
    end
end

"""
    get_restorer(server::Server) -> Union{DefaultRestorer, Nothing}

Get the server's restorer for persistent capabilities.
"""
function get_restorer(server::Server)
    lock(server.lock) do
        return server.restorer
    end
end

"""
    handle_save_call!(server::Server, conn::Connection, ctx::CallContext, cap)

Handle a Persistent.save() call on a capability.
This implements C004-SERVER-PERSISTENCE contract.

If the capability is persistent, generates a SturdyRef and returns it.
If not persistent, returns an UNIMPLEMENTED exception.
"""
function handle_save_call!(server::Server, conn::Connection, ctx::CallContext, cap, call::ParsedCall)
    # Check if we have a restorer configured
    restorer = get_restorer(server)
    if restorer === nothing
        set_exception!(ctx, "Server does not support persistent capabilities", ExceptionType.UNIMPLEMENTED)
        return
    end

    # Get the actual capability (unwrap LocalCapability if needed)
    impl = cap isa LocalCapability ? cap.impl : cap

    # Check if the capability is persistent
    if !is_persistent(impl)
        set_exception!(ctx, "Capability does not implement Persistent interface", ExceptionType.UNIMPLEMENTED)
        return
    end

    # Extract sealFor from params (it's the first pointer in SaveParams)
    seal_for = nothing
    if call.params !== nothing && call.params.pointer_count >= 1
        # Extract the AnyPointer
        seal_for = Capnp.read_struct_pointer(call.params, 0, 0)
    end

    # Check if the owner can save this capability
    if !can_save(impl, seal_for)
        set_exception!(ctx, "Owner not authorized to save this capability", ExceptionType.FAILED)
        return
    end

    # Generate the SturdyRef
    try
        sturdy_ref = generate_sturdy_ref(impl, seal_for, restorer)
        # Serialize the SturdyRef as the result
        result_data = serialize_sturdy_ref(sturdy_ref)
        set_result!(ctx, ParsedSaveResults(result_data))
    catch e
        set_exception!(ctx, "Failed to generate SturdyRef: $(string(e))", ExceptionType.FAILED)
    end
end

"""
    handle_restore_call!(server::Server, conn::Connection, ctx::CallContext, sturdy_ref_data::Vector{UInt8})

Handle a restore call from a client.
Looks up the capability in the restorer and exports it.
"""
function handle_restore_call!(server::Server, conn::Connection, ctx::CallContext, sturdy_ref_data::Vector{UInt8})
    restorer = get_restorer(server)
    if restorer === nothing
        set_exception!(ctx, "Server does not support persistent capabilities", ExceptionType.UNIMPLEMENTED)
        return
    end

    # Deserialize the SturdyRef
    try
        sturdy_ref = deserialize_sturdy_ref(sturdy_ref_data)
        owner = DefaultOwner()  # TODO: Extract owner from params

        # Restore the capability
        capability = restore(restorer, sturdy_ref, owner)

        # Export the restored capability
        export_id = export_capability(ctx, capability, UInt64(0))
        set_result!(ctx, ParsedRestoreResults(true, export_id, nothing, nothing))
    catch e
        if e isa RestoreException
            set_exception!(ctx, e.reason, ExceptionType.FAILED)
        else
            set_exception!(ctx, "Restore failed: $(string(e))", ExceptionType.FAILED)
        end
    end
end

"""
    register_persistent!(server::Server, object_id::Vector{UInt8}, capability, owner::DefaultOwner) -> Union{DefaultSturdyRef, Nothing}

Register a capability as persistent in the server's restorer.
Returns the SturdyRef, or nothing if no restorer is configured.
"""
function register_persistent!(server::Server, object_id::Vector{UInt8}, capability, owner::DefaultOwner = DefaultOwner())
    restorer = get_restorer(server)
    if restorer === nothing
        return nothing
    end
    return register!(restorer, object_id, capability, owner)
end

"""
    is_save_call(call::ParsedCall) -> Bool

Check if a Call message is a Persistent.save() call.
"""
function is_save_call(call::ParsedCall)
    return call.interface_id == PERSISTENT_INTERFACE_ID && call.method_id == PERSISTENT_SAVE_METHOD_ID
end

"""
    shutdown!(server::Server)

Gracefully shutdown the server and all client connections.
"""
function shutdown!(server::Server)
    set_running!(server, false)

    # Close all client connections
    clients = get_clients(server)
    for conn in clients
        close(conn)
    end

    # Clear client list
    lock(server.lock) do
        empty!(server.clients)
    end

    # Close the listener
    if server.tcp_server !== nothing
        close(server.tcp_server)
        server.tcp_server = nothing
    end
end

# Exports
export Server, ServerOptions, CallContext
export ExportEntry, promise_export_entry
export is_running, set_running!, client_count, add_client!, remove_client!
export listen, serve, serve_async, shutdown!
export set_result!, set_exception!, export_capability, export_promised_capability!
export handle_bootstrap, handle_call!, handle_finish!, handle_server_release!
export send_resolve!, send_resolve_exception!

# Level 2: Server-side persistence exports
export set_restorer!, get_restorer
export handle_save_call!, handle_restore_call!
export register_persistent!, is_save_call

"""
    listen(server::Server, host::AbstractString, port::Integer, tls_config::TLSListenerConfig)

Listen for incoming TLS-secured Cap'n Proto RPC connections.
Requires the `Reseau` package to be loaded.
"""
function listen(server::Server, host::AbstractString, port::Integer, tls_config::AbstractTLSListenerConfig)
    error("TLS listeners require the Reseau package to be loaded. Run `using Reseau`.")
end
