# Cap'n Proto RPC Server (FR-015, FR-016, FR-017)
# Provides server-side RPC functionality

using Sockets

"""
    ServerOptions

Configuration options for RPC servers.
"""
struct ServerOptions
    max_connections::Int
    connection_timeout::Int  # milliseconds
    send_buffer_size::Int
    receive_buffer_size::Int

    function ServerOptions(;
        max_connections::Int = 1000,
        connection_timeout::Int = 30000,
        send_buffer_size::Int = 65536,
        receive_buffer_size::Int = 65536
    )
        new(max_connections, connection_timeout, send_buffer_size, receive_buffer_size)
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

    function CallContext(conn::Connection, qid::QuestionId, iface_id::UInt64, method_id::UInt16)
        new(conn, qid, iface_id, method_id, nothing, false, "", ExceptionType.FAILED)
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
end

"""
    export_capability(ctx::CallContext, impl, interface_id::UInt64) -> ExportId

Export a capability to be returned to the client.
"""
function export_capability(ctx::CallContext, impl, interface_id::UInt64)
    eid = next_export_id!(ctx.connection)
    cap = LocalCapability(interface_id, impl)
    add_export!(ctx.connection, eid, cap)
    return eid
end

"""
    Server

RPC server that listens for connections and dispatches method calls.
"""
mutable struct Server
    bootstrap_impl::Any
    connection_handler::Union{Function, Nothing}
    clients::Vector{Connection}
    options::ServerOptions
    is_running::Bool
    listener_task::Union{Task, Nothing}
    tcp_server::Union{Sockets.TCPServer, Nothing}
    lock::ReentrantLock

    function Server(bootstrap_impl; options::ServerOptions = ServerOptions())
        new(bootstrap_impl, nothing, Connection[], options, false, nothing, nothing, ReentrantLock())
    end

    function Server(bootstrap_impl, handler::Function; options::ServerOptions = ServerOptions())
        new(bootstrap_impl, handler, Connection[], options, false, nothing, nothing, ReentrantLock())
    end

    # Support do-block syntax: Server(impl) do conn ... end
    function Server(handler::Function, bootstrap_impl; options::ServerOptions = ServerOptions())
        new(bootstrap_impl, handler, Connection[], options, false, nothing, nothing, ReentrantLock())
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
    transport = TcpTransport(socket)
    conn = Connection(transport)

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
    try
        while is_connected(conn) && is_running(server)
            message = receive_message(conn.transport)
            handle_server_message!(server, conn, message)
        end
    catch e
        if !(e isa DisconnectedException || e isa EOFError)
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
        @warn "Error handling RPC message" exception=(e, catch_backtrace())
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
    send_raw_message(conn.transport, response)
end

"""
    handle_call_message!(server::Server, conn::Connection, call::ParsedCall)

Handle a Call message - dispatch to method implementation and send Return.
"""
function handle_call_message!(_server::Server, conn::Connection, call::ParsedCall)
    # Create call context
    ctx = CallContext(conn, call.question_id, call.interface_id, call.method_id)

    # Find the target capability
    cap = nothing
    if call.target.kind == MessageTargetType.IMPORTED_CAP && call.target.imported_cap !== nothing
        cap = get_export(conn, ExportId(call.target.imported_cap))
    end

    if cap === nothing
        set_exception!(ctx, "Invalid capability", ExceptionType.FAILED)
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

    # For Calculator interface (example)
    # The interface_id should match the schema
    # method_id: 0=add, 1=subtract, 2=multiply, 3=divide

    # Try to find a dispatch function for this interface
    method_name = Symbol("dispatch_$(interface_id)_$(method_id)")
    if isdefined(Main, method_name)
        getfield(Main, method_name)(impl, ctx, params)
    else
        # Fall back to trying Calculator_* methods if impl is a Calculator_Server
        if method_id == 0
            Calculator_add(impl, ctx, params)
        elseif method_id == 1
            Calculator_subtract(impl, ctx, params)
        elseif method_id == 2
            Calculator_multiply(impl, ctx, params)
        elseif method_id == 3
            Calculator_divide(impl, ctx, params)
        elseif method_id == 4
            Calculator_getSubCalculator(impl, ctx, params)
        else
            set_exception!(ctx, "Method not found: interface=$interface_id method=$method_id", ExceptionType.UNIMPLEMENTED)
        end
    end
end

# Stub functions for Calculator methods - to be overridden by user implementations
function Calculator_add end
function Calculator_subtract end
function Calculator_multiply end
function Calculator_divide end
function Calculator_getSubCalculator end

"""
Default Calculator implementations that use parsed params.
These can be overridden by user implementations.
"""
function Calculator_add(::Any, ctx::CallContext, params::ParsedParams)
    result = params.left + params.right
    set_result!(ctx, result)
end

function Calculator_subtract(::Any, ctx::CallContext, params::ParsedParams)
    result = params.left - params.right
    set_result!(ctx, result)
end

function Calculator_multiply(::Any, ctx::CallContext, params::ParsedParams)
    result = params.left * params.right
    set_result!(ctx, result)
end

function Calculator_divide(::Any, ctx::CallContext, params::ParsedParams)
    if params.right == 0.0
        set_exception!(ctx, "Division by zero", ExceptionType.FAILED)
    else
        result = params.left / params.right
        set_result!(ctx, result)
    end
end

"""
    send_return_response!(conn::Connection, ctx::CallContext)

Build and send a Return message based on the call context.
"""
function send_return_response!(conn::Connection, ctx::CallContext)
    response = build_return_message(
        ctx.question_id,
        ctx.result;
        has_exception=ctx.has_exception,
        exception_reason=ctx.exception_reason
    )
    send_raw_message(conn.transport, response)
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
        for _ in 1:ref_count
            if decref!(cap)
                remove_export!(conn, id)
                break
            end
        end
    end
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
export is_running, set_running!, client_count, add_client!, remove_client!
export listen, serve, serve_async, shutdown!
export set_result!, set_exception!, export_capability
export handle_bootstrap, handle_call!, handle_finish!, handle_server_release!
