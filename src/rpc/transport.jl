# Cap'n Proto RPC Transport layer (FR-010, FR-011)
# Provides pluggable transport abstraction for TCP and Unix sockets
# Cross-platform: Unix sockets on Linux/macOS, TCP fallback on Windows

using Sockets

"""
    supports_unix_sockets() -> Bool

Check if the current platform supports Unix domain sockets.
Returns `true` on Linux and macOS, `false` on Windows.
"""
supports_unix_sockets() = !Sys.iswindows()

"""
    default_transport_type() -> Type{<:Transport}

Returns the recommended transport type for the current platform.
- On Linux/macOS: Returns `UnixTransport` (Unix domain sockets)
- On Windows: Returns `TcpTransport` (TCP sockets)

This enables automatic platform-appropriate transport selection.
"""
default_transport_type() = supports_unix_sockets() ? UnixTransport : TcpTransport

"""
    Transport

Abstract base type for RPC transports.
Implementations must provide send_message, receive_message, isopen, and close.
"""
abstract type Transport end

"""
    send_message(transport::Transport, builder::AllocMessageBuilder)

Send a Cap'n Proto message over the transport.
"""
function send_message end

"""
    receive_message(transport::Transport) -> MessageReader

Receive a Cap'n Proto message from the transport.
"""
function receive_message end

# IO interface
Base.isopen(t::Transport) = error("isopen not implemented for $(typeof(t))")
Base.close(t::Transport) = error("close not implemented for $(typeof(t))")

"""
    TcpTransport

Transport implementation using TCP sockets.
"""
mutable struct TcpTransport <: Transport
    socket::TCPSocket
    is_open::Bool

    function TcpTransport(socket::TCPSocket)
        new(socket, isopen(socket))
    end
end

# Connect to a TCP server
function TcpTransport(host::AbstractString, port::Integer)
    socket = connect(host, port)
    TcpTransport(socket)
end

Base.isopen(t::TcpTransport) = t.is_open && isopen(t.socket)

function Base.close(t::TcpTransport)
    t.is_open = false
    if isopen(t.socket)
        close(t.socket)
    end
end

function send_message(t::TcpTransport, builder::Capnp.AllocMessageBuilder)
    if !isopen(t)
        throw(DisconnectedException("Transport is closed"))
    end
    Capnp.writeMessageToStream(builder, t.socket)
end

function receive_message(t::TcpTransport)
    if !isopen(t)
        throw(DisconnectedException("Transport is closed"))
    end
    try
        return Capnp.MessageReader(t.socket)
    catch e
        if e isa EOFError
            t.is_open = false
            throw(DisconnectedException("Connection closed by peer"))
        end
        rethrow()
    end
end

"""
    UnixTransport

Transport implementation using Unix domain sockets.

**Platform Support**: Unix domain sockets work on Linux and macOS only.
On Windows, use `TcpTransport` instead, or call `default_transport_type()`
to automatically select the appropriate transport for the current platform.

See also: `supports_unix_sockets()`, `default_transport_type()`
"""
mutable struct UnixTransport <: Transport
    socket::Any  # PipeEndpoint or similar
    is_open::Bool
    path::String

    function UnixTransport(path::AbstractString)
        # Connect to Unix domain socket
        # Julia's Sockets stdlib supports Unix sockets via connect()
        socket = connect(path)
        new(socket, true, path)
    end

    function UnixTransport(socket, path::AbstractString)
        new(socket, isopen(socket), path)
    end
end

Base.isopen(t::UnixTransport) = t.is_open && isopen(t.socket)

function Base.close(t::UnixTransport)
    t.is_open = false
    if isopen(t.socket)
        close(t.socket)
    end
end

function send_message(t::UnixTransport, builder::Capnp.AllocMessageBuilder)
    if !isopen(t)
        throw(DisconnectedException("Transport is closed"))
    end
    Capnp.writeMessageToStream(builder, t.socket)
end

function receive_message(t::UnixTransport)
    if !isopen(t)
        throw(DisconnectedException("Transport is closed"))
    end
    try
        return Capnp.MessageReader(t.socket)
    catch e
        if e isa EOFError
            t.is_open = false
            throw(DisconnectedException("Connection closed by peer"))
        end
        rethrow()
    end
end

"""
    MockTransport

Mock transport for testing purposes.
Stores sent messages and allows injecting received messages.
"""
mutable struct MockTransport <: Transport
    sent_messages::Vector{Vector{UInt8}}
    receive_queue::Vector{Vector{UInt8}}
    is_open::Bool

    MockTransport() = new(Vector{UInt8}[], Vector{UInt8}[], true)
end

Base.isopen(t::MockTransport) = t.is_open

function Base.close(t::MockTransport)
    t.is_open = false
end

function send_message(t::MockTransport, builder::Capnp.AllocMessageBuilder)
    if !isopen(t)
        throw(DisconnectedException("Transport is closed"))
    end
    # Serialize to bytes and store
    buf = IOBuffer()
    Capnp.writeMessageToStream(builder, buf)
    push!(t.sent_messages, take!(buf))
end

function receive_message(t::MockTransport)
    if !isopen(t)
        throw(DisconnectedException("Transport is closed"))
    end
    if isempty(t.receive_queue)
        throw(EOFError())
    end
    data = popfirst!(t.receive_queue)
    return Capnp.MessageReader(IOBuffer(data))
end

"""
    inject_message!(transport::MockTransport, builder::AllocMessageBuilder)

Inject a message into the mock transport's receive queue for testing.
"""
function inject_message!(t::MockTransport, builder::Capnp.AllocMessageBuilder)
    buf = IOBuffer()
    Capnp.writeMessageToStream(builder, buf)
    push!(t.receive_queue, take!(buf))
end

"""
    get_sent_messages(transport::MockTransport) -> Vector{Vector{UInt8}}

Get all messages that were sent over the mock transport.
"""
get_sent_messages(t::MockTransport) = t.sent_messages

"""
    clear_sent_messages!(transport::MockTransport)

Clear the list of sent messages.
"""
function clear_sent_messages!(t::MockTransport)
    empty!(t.sent_messages)
end

"""
    send_raw_message(transport::Transport, data::Vector{UInt8})

Send raw bytes over the transport. Used for pre-built messages.
"""
function send_raw_message end

function send_raw_message(t::TcpTransport, data::Vector{UInt8})
    if !isopen(t)
        throw(DisconnectedException("Transport is closed"))
    end
    write(t.socket, data)
    flush(t.socket)
end

function send_raw_message(t::UnixTransport, data::Vector{UInt8})
    if !isopen(t)
        throw(DisconnectedException("Transport is closed"))
    end
    write(t.socket, data)
    flush(t.socket)
end

function send_raw_message(t::MockTransport, data::Vector{UInt8})
    if !isopen(t)
        throw(DisconnectedException("Transport is closed"))
    end
    push!(t.sent_messages, copy(data))
end

# Exports
export Transport, TcpTransport, UnixTransport, MockTransport
export send_message, receive_message, send_raw_message
export inject_message!, get_sent_messages, clear_sent_messages!
export supports_unix_sockets, default_transport_type
