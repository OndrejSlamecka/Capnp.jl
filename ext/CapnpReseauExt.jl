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
    read_lock::ReentrantLock
    write_lock::ReentrantLock

    function ReseauTransport(socket::S; max_message_size::Int = Capnp.DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = Capnp.DEFAULT_MAX_SEGMENTS) where {S}
        Capnp._validate_reader_limits(max_message_size, max_segments)
        return new{S}(socket, true, max_message_size, max_segments, ReentrantLock(), ReentrantLock())
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
        return Capnp.RPC._receive_reader(t, t.socket, t.read_lock, t.max_message_size, t.max_segments)
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
    config = Reseau.TLS.Config(;
        server_name = tls_config.sni !== nothing ? tls_config.sni : host,
        verify_peer = tls_config.verify_host,
        verify_hostname = tls_config.verify_host,
        ca_file = tls_config.ca_roots,
        cert_file = tls_config.client_cert,
        key_file = tls_config.client_key,
        alpn_protocols = tls_config.alpn_protocols !== nothing ? tls_config.alpn_protocols : String[],
        handshake_timeout_ns = tls_config.handshake_timeout_ns !== nothing ? tls_config.handshake_timeout_ns : UInt64(10_000_000_000),
    )

    # Reseau.TLS.connect accepts an address string in the format "host:port"
    socket = Reseau.TLS.connect("tcp", "$host:$port", config)
    if tls_config.read_timeout_ns !== nothing
        Reseau.TLS.set_read_deadline!(socket, time_ns() + tls_config.read_timeout_ns)
    end
    if tls_config.write_timeout_ns !== nothing
        Reseau.TLS.set_write_deadline!(socket, time_ns() + tls_config.write_timeout_ns)
    end
    transport = ReseauTransport(socket; max_message_size = options.max_message_size, max_segments = options.max_segments)

    return RPC.connect(transport)
end

# Implement listen for TLSListenerConfig
function Capnp.RPC.listen(server::RPC.Server, host::AbstractString, port::Integer, tls_config::RPC.TLSListenerConfig)
    client_auth = tls_config.require_client_cert ? Reseau.TLS.ClientAuthMode.RequireAndVerifyClientCert : Reseau.TLS.ClientAuthMode.NoClientCert
    config = Reseau.TLS.Config(;
        cert_file = tls_config.server_cert,
        key_file = tls_config.server_key,
        client_ca_file = tls_config.ca_roots,
        client_auth = client_auth,
        alpn_protocols = tls_config.alpn_protocols !== nothing ? tls_config.alpn_protocols : String[],
        handshake_timeout_ns = tls_config.handshake_timeout_ns !== nothing ? tls_config.handshake_timeout_ns : UInt64(10_000_000_000),
    )

    listener = Reseau.TCP.listen("tcp", "$host:$port")

    RPC.set_running!(server, true)
    server.tcp_server = listener

    server.listener_task = @async begin
        try
            while RPC.is_running(server)
                client_sock = Reseau.TCP.accept(listener)

                @async begin
                    try
                        tls_sock = Reseau.TLS.server(client_sock, config)
                        # Handshake is performed on first read/write or explicitly via handshake!
                        Reseau.TLS.handshake!(tls_sock)

                        if tls_config.read_timeout_ns !== nothing
                            Reseau.TLS.set_read_deadline!(tls_sock, time_ns() + tls_config.read_timeout_ns)
                        end
                        if tls_config.write_timeout_ns !== nothing
                            Reseau.TLS.set_write_deadline!(tls_sock, time_ns() + tls_config.write_timeout_ns)
                        end
                        transport = ReseauTransport(tls_sock)
                        conn = RPC.Connection(transport; owns_transport = true)
                        RPC.add_client!(server, conn)
                        RPC.start_message_loop!(conn)
                    catch e
                        @error "Error accepting TLS connection" exception=(e, catch_backtrace())
                        close(client_sock)
                    end
                end
            end
        catch e
            if RPC.is_running(server)
                @error "Server listener error" exception=(e, catch_backtrace())
            end
        finally
            close(listener)
        end
    end

    return server
end

end
