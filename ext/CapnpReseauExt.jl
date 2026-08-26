module CapnpReseauExt

using Capnp
using Capnp.RPC
using Reseau

# We define the ReseauTransport which wraps a Reseau connection (like Reseau.TLS.Conn)
# and implements the Capnp Transport interface.

mutable struct ReseauTransport{S} <: Capnp.RPC.Transport
    socket::S
    is_open::Bool
    max_message_size::Int
    max_segments::Int
    traversal_limit_words::Int
    nesting_limit::Int
    read_lock::ReentrantLock
    write_lock::ReentrantLock

    function ReseauTransport(socket::S; max_message_size::Int = Capnp.DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = Capnp.DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = Capnp.DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = Capnp.DEFAULT_NESTING_LIMIT) where {S}
        Capnp._validate_reader_limits(max_message_size, max_segments)
        Capnp._validate_traversal_limits(traversal_limit_words, nesting_limit)
        return new{S}(socket, true, max_message_size, max_segments, traversal_limit_words, nesting_limit, ReentrantLock(), ReentrantLock())
    end
end

Base.isopen(t::ReseauTransport) = t.is_open # Reseau connections don't always have `isopen` method

function Base.close(t::ReseauTransport)
    was_open = t.is_open
    t.is_open = false
    if was_open
        try
            close(t.socket)
        catch
        end
    end
    return nothing
end

Capnp.RPC.send_message(t::ReseauTransport, builder::Capnp.AllocMessageBuilder) = Capnp.RPC._send_builder(t, builder)
function Capnp.RPC.receive_message(t::ReseauTransport)
    try
        return Capnp.RPC._receive_reader(t, t.socket, t.read_lock, t.max_message_size, t.max_segments, t.traversal_limit_words, t.nesting_limit)
    catch e
        if e isa Reseau.TLS.TLSError || e isa Reseau.IOPoll.DeadlineExceededError || e isa Reseau.TLS.TLSHandshakeTimeoutError
            throw(Capnp.RPC.DisconnectedException("TLS transport read failed: $(e)"))
        end
        rethrow()
    end
end


function Capnp.RPC.send_raw_message(t::ReseauTransport, data::AbstractVector{UInt8})
    Capnp.RPC._validate_outbound_frame(data, t.max_message_size, t.max_segments)
    try
        return Capnp.RPC._send_bytes(t, t.socket, t.write_lock, data)
    catch e
        if e isa Reseau.TLS.TLSError || e isa Reseau.IOPoll.DeadlineExceededError || e isa Reseau.TLS.TLSHandshakeTimeoutError
            throw(Capnp.RPC.DisconnectedException("TLS transport write failed: $(e)"))
        end
        rethrow()
    end

end

# Implement connect for TLSConfig
function Capnp.RPC.connect(host::AbstractString, port::Integer, tls_config::RPC.TLSConfig; options::RPC.ConnectionOptions = RPC.ConnectionOptions())
    cache13c = Reseau.TLS._TLSSessionCache{Reseau.TLS._TLS13ClientSession}(ReentrantLock(), Dict{String, Reseau.TLS._TLS13ClientSession}(), String[], 64)
    cache13s = Reseau.TLS._TLSSessionCache{Reseau.TLS._TLS13ServerSession}(ReentrantLock(), Dict{String, Reseau.TLS._TLS13ServerSession}(), String[], 64)
    cache12c = Reseau.TLS._TLSSessionCache{Reseau.TLS._TLS12ClientSession}(ReentrantLock(), Dict{String, Reseau.TLS._TLS12ClientSession}(), String[], 64)
    cache12s = Reseau.TLS._TLSSessionCache{Reseau.TLS._TLS12ServerSession}(ReentrantLock(), Dict{String, Reseau.TLS._TLS12ServerSession}(), String[], 64)
    config = Reseau.TLS.Config(
        tls_config.sni !== nothing ? (tls_config.sni::String) : String(host),
        tls_config.verify_host::Bool,
        tls_config.verify_host::Bool,
        Reseau.TLS.ClientAuthMode.NoClientCert,
        tls_config.client_cert::String,
        tls_config.client_key::String,
        tls_config.ca_roots::String,
        nothing,
        tls_config.alpn_protocols !== nothing ? (tls_config.alpn_protocols::Vector{String}) : String[],
        UInt16[],
        Int64(tls_config.handshake_timeout_ns !== nothing ? tls_config.handshake_timeout_ns : UInt64(10_000_000_000)),
        nothing,
        nothing,
        false,
        Reseau.TLS._TLSSessionTicketKeyState(),
        cache13c, cache13s, cache12c, cache12s,
        Reseau.TLS._TLSLocalIdentityState(),
        Reseau.TLS._TLSLocalIdentityState()
    )

    # Reseau.TLS.connect accepts an address string in the format "host:port"
    socket = Reseau.TLS.connect("tcp", "$host:$port", config)
    if tls_config.read_timeout_ns !== nothing
        Reseau.TLS.set_read_deadline!(socket, time_ns() + tls_config.read_timeout_ns)
    end
    if tls_config.write_timeout_ns !== nothing
        Reseau.TLS.set_write_deadline!(socket, time_ns() + tls_config.write_timeout_ns)
    end
    transport = ReseauTransport(socket; max_message_size = options.max_message_size, max_segments = options.max_segments, traversal_limit_words = options.traversal_limit_words, nesting_limit = options.nesting_limit)

    return RPC.connect(transport; options)
end

# Implement listen for TLSListenerConfig
function Capnp.RPC.listen(server::RPC.Server, host::AbstractString, port::Integer, tls_config::RPC.TLSListenerConfig)
    client_auth = tls_config.require_client_cert ? Reseau.TLS.ClientAuthMode.RequireAndVerifyClientCert : Reseau.TLS.ClientAuthMode.NoClientCert
    cache13c = Reseau.TLS._TLSSessionCache{Reseau.TLS._TLS13ClientSession}(ReentrantLock(), Dict{String, Reseau.TLS._TLS13ClientSession}(), String[], 64)
    cache13s = Reseau.TLS._TLSSessionCache{Reseau.TLS._TLS13ServerSession}(ReentrantLock(), Dict{String, Reseau.TLS._TLS13ServerSession}(), String[], 64)
    cache12c = Reseau.TLS._TLSSessionCache{Reseau.TLS._TLS12ClientSession}(ReentrantLock(), Dict{String, Reseau.TLS._TLS12ClientSession}(), String[], 64)
    cache12s = Reseau.TLS._TLSSessionCache{Reseau.TLS._TLS12ServerSession}(ReentrantLock(), Dict{String, Reseau.TLS._TLS12ServerSession}(), String[], 64)
    config = Reseau.TLS.Config(
        nothing,
        false,
        false,
        client_auth,
        tls_config.server_cert::String,
        tls_config.server_key::String,
        nothing,
        tls_config.ca_roots::String,
        tls_config.alpn_protocols !== nothing ? (tls_config.alpn_protocols::Vector{String}) : String[],
        UInt16[],
        Int64(tls_config.handshake_timeout_ns !== nothing ? tls_config.handshake_timeout_ns : UInt64(10_000_000_000)),
        nothing,
        nothing,
        false,
        Reseau.TLS._TLSSessionTicketKeyState(),
        cache13c, cache13s, cache12c, cache12s,
        Reseau.TLS._TLSLocalIdentityState(),
        Reseau.TLS._TLSLocalIdentityState()
    )

    listener = Reseau.TCP.listen("tcp", "$host:$port")

    RPC.set_running!(server, true)
    server.tcp_server = listener

    server.listener_task = @async begin
        try
            ccall(:puts, Cint, (Cstring,), "SERVER LOOP STARTED")
            while RPC.is_running(server)
                client_sock = Reseau.TCP.accept(listener)
                ccall(:puts, Cint, (Cstring,), "SERVER ACCEPTED CLIENT")

                @async begin
                    try
                        tls_sock = Reseau.TLS.server(client_sock, config)
                        # Handshake is performed on first read/write or explicitly via handshake!
                        ccall(:puts, Cint, (Cstring,), "SERVER STARTING HANDSHAKE")
                        Reseau.TLS.handshake!(tls_sock)
                        ccall(:puts, Cint, (Cstring,), "SERVER HANDSHAKE DONE")

                        if tls_config.read_timeout_ns !== nothing
                            Reseau.TLS.set_read_deadline!(tls_sock, time_ns() + tls_config.read_timeout_ns)
                        end
                        if tls_config.write_timeout_ns !== nothing
                            Reseau.TLS.set_write_deadline!(tls_sock, time_ns() + tls_config.write_timeout_ns)
                        end
                        transport = ReseauTransport(
                            tls_sock;
                            max_message_size = server.options.max_message_size,
                            max_segments = server.options.max_segments,
                            traversal_limit_words = server.options.traversal_limit_words,
                            nesting_limit = server.options.nesting_limit,
                        )
                        conn = RPC.Connection(
                            transport;
                            owns_transport = true,
                            inbound_queue_size = server.options.inbound_queue_size,
                            outbound_queue_size = server.options.outbound_queue_size,
                            max_questions = server.options.max_questions,
                            max_answers = server.options.max_answers,
                            max_exports = server.options.max_exports,
                            max_imports = server.options.max_imports,
                        )
                        RPC.add_client!(server, conn)
                        RPC.start_message_loop!(conn)
                    catch e
                        ccall(:puts, Cint, (Cstring,), "SERVER ERROR ACCEPTING TLS CONNECTION")
                        close(client_sock)
                    end
                end
            end
        catch e
            ccall(:puts, Cint, (Cstring,), "SERVER LISTENER ERROR")
        finally
            close(listener)
        end
    end

    return server
end


Base.closewrite(t::ReseauTransport) = Base.closewrite(t.socket)

# Precompile workloads
if Base.VERSION >= v"1.9"
    precompile(Capnp.RPC.connect, (String, Int, Capnp.RPC.TLSConfig))
    precompile(Capnp.RPC.listen, (Capnp.RPC.Server, String, Int, Capnp.RPC.TLSListenerConfig))
end

end
