# Cap'n Proto RPC Client (FR-010, FR-013)
# Provides client-side RPC functionality

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
"""
function handle_message!(conn::Connection, message::Capnp.MessageReader)
    # In a full implementation, this would:
    # 1. Parse the RPC message type
    # 2. Dispatch to appropriate handler (Return, Resolve, Release, etc.)

    # Placeholder for now
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
    handle_resolve!(conn::Connection, promise_id::UInt32, cap)

Handle a Resolve message - promise was replaced with a capability.
"""
function handle_resolve!(conn::Connection, promise_id::UInt32, cap)
    # Update the import table with the resolved capability
    # This is used when a capability was originally received as a promise
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

# Exports
export connect, bootstrap, ConnectionOptions
export handle_message!, handle_return!, handle_exception!, handle_resolve!, handle_release!
export start_message_loop!
