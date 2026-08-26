# Cap'n Proto RPC transport boundary.

using Sockets

"""
    Transport

Abstract full-duplex transport used by the RPC engine. A transport must provide
`isopen`, `close`, `send_raw_message`, and `receive_message`. Writes must either
send the complete framed message or throw; reads must return exactly one framed
Cap'n Proto message or throw `DisconnectedException` when the peer closes.
"""
abstract type Transport end

"""An IO operation required by the transport contract is not available."""
struct TransportContractError <: Exception
    operation::Symbol
    transport_type::DataType
end

function Base.showerror(io::IO, err::TransportContractError)
    print(io, "transport ", err.transport_type, " does not implement ", err.operation)
end

function send_message end
function receive_message end
function send_raw_message end

Base.isopen(t::Transport) = throw(TransportContractError(:isopen, typeof(t)))
Base.close(t::Transport) = throw(TransportContractError(:close, typeof(t)))

supports_unix_sockets() = !Sys.iswindows()
default_transport_type() = supports_unix_sockets() ? UnixTransport : TcpTransport

function _check_open(t::Transport)
    isopen(t) || throw(DisconnectedException("Transport is closed"))
    return nothing
end

function _write_all(io, data::AbstractVector{UInt8})
    offset = firstindex(data)
    final = lastindex(data)
    while offset <= final
        written = write(io, @view(data[offset:final]))
        written > 0 || throw(EOFError())
        offset += written
    end
    flush(io)
    return nothing
end

function _send_builder(t::Transport, builder::Capnp.AllocMessageBuilder)
    buffer = IOBuffer()
    Capnp.writeMessageToStream(builder, buffer)
    send_raw_message(t, take!(buffer))
end

function _validate_outbound_frame(data::AbstractVector{UInt8}, max_message_size::Int, max_segments::Int)
    length(data) >= 8 || throw(Capnp.InvalidMessageError("message is shorter than the minimum framing header"))
    segment_count = Int(Capnp._read_le_uint32(data, 1)) + 1
    segment_count <= max_segments || throw(Capnp.InvalidMessageError("segment count $segment_count exceeds limit $max_segments"))
    header_size = 4 * (1 + segment_count + (iseven(segment_count) ? 1 : 0))
    header_size <= length(data) || throw(Capnp.InvalidMessageError("truncated framing header"))
    total_size = header_size
    for index = 1:segment_count
        segment_size = Base.checked_mul(Int(Capnp._read_le_uint32(data, 5 + 4 * (index - 1))), 8)
        total_size = Base.checked_add(total_size, segment_size)
        total_size <= max_message_size || throw(Capnp.InvalidMessageError("message size $total_size exceeds limit $max_message_size"))
    end
    iseven(segment_count) && Capnp._read_le_uint32(data, header_size - 3) != 0 && throw(Capnp.InvalidMessageError("non-zero framing padding"))
    total_size == length(data) || throw(Capnp.InvalidMessageError("framed message has trailing or missing bytes"))
    return nothing
end

function _receive_reader(t::Transport, io, read_lock::ReentrantLock, max_message_size::Int, max_segments::Int, traversal_limit_words::Int, nesting_limit::Int)
    _check_open(t)
    lock(read_lock) do
        try
            eof(io) && throw(DisconnectedException("Connection closed by peer"))
            return Capnp.MessageReader(io; max_message_size, max_segments, traversal_limit_words, nesting_limit)
        catch err
            if err isa EOFError
                throw(DisconnectedException("Connection closed by peer"))
            end
            rethrow()
        end
    end
end

function _send_bytes(t::Transport, io, write_lock::ReentrantLock, data::AbstractVector{UInt8})
    _check_open(t)
    lock(write_lock) do
        try
            _write_all(io, data)
        catch err
            if err isa EOFError || err isa Base.IOError
                throw(DisconnectedException("Connection closed while writing"))
            end
            rethrow()
        end
    end
    return nothing
end

"""
    IOTransport(stream; owns_stream=true, max_message_size, max_segments,
                traversal_limit_words, nesting_limit)

Adapt an already-connected, IO-compatible full-duplex stream to the RPC
transport contract. This is the extension point used by optional transports
such as Reseau TLS. Set `owns_stream=false` when another component owns the
stream lifecycle. Reader traversal and nesting limits are applied to every
inbound RPC message.
"""
mutable struct IOTransport{S} <: Transport
    stream::S
    owns_stream::Bool
    is_open::Bool
    max_message_size::Int
    max_segments::Int
    traversal_limit_words::Int
    nesting_limit::Int
    read_lock::ReentrantLock
    write_lock::ReentrantLock

    function IOTransport(stream::S; owns_stream::Bool = true, max_message_size::Int = Capnp.DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = Capnp.DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = Capnp.DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = Capnp.DEFAULT_NESTING_LIMIT) where {S}
        Capnp._validate_reader_limits(max_message_size, max_segments)
        Capnp._validate_traversal_limits(traversal_limit_words, nesting_limit)
        new{S}(stream, owns_stream, isopen(stream), max_message_size, max_segments, traversal_limit_words, nesting_limit, ReentrantLock(), ReentrantLock())
    end
end

Base.isopen(t::IOTransport) = t.is_open && isopen(t.stream)

function Base.close(t::IOTransport)
    was_open = t.is_open
    t.is_open = false
    if was_open && t.owns_stream && isopen(t.stream)
        close(t.stream)
    end
    return nothing
end

send_message(t::IOTransport, builder::Capnp.AllocMessageBuilder) = _send_builder(t, builder)
receive_message(t::IOTransport) = _receive_reader(t, t.stream, t.read_lock, t.max_message_size, t.max_segments, t.traversal_limit_words, t.nesting_limit)
function send_raw_message(t::IOTransport, data::AbstractVector{UInt8})
    _validate_outbound_frame(data, t.max_message_size, t.max_segments)
    return _send_bytes(t, t.stream, t.write_lock, data)
end

"""Transport implemented with Julia's `Sockets` TCP stream."""
mutable struct TcpTransport <: Transport
    socket::TCPSocket
    is_open::Bool
    max_message_size::Int
    max_segments::Int
    traversal_limit_words::Int
    nesting_limit::Int
    read_lock::ReentrantLock
    write_lock::ReentrantLock

    function TcpTransport(socket::TCPSocket; max_message_size::Int = Capnp.DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = Capnp.DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = Capnp.DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = Capnp.DEFAULT_NESTING_LIMIT)
        Capnp._validate_reader_limits(max_message_size, max_segments)
        Capnp._validate_traversal_limits(traversal_limit_words, nesting_limit)
        new(socket, isopen(socket), max_message_size, max_segments, traversal_limit_words, nesting_limit, ReentrantLock(), ReentrantLock())
    end
end

function TcpTransport(host::AbstractString, port::Integer; max_message_size::Int = Capnp.DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = Capnp.DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = Capnp.DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = Capnp.DEFAULT_NESTING_LIMIT)
    TcpTransport(Sockets.connect(host, port); max_message_size, max_segments, traversal_limit_words, nesting_limit)
end

Base.isopen(t::TcpTransport) = t.is_open && isopen(t.socket)

function Base.close(t::TcpTransport)
    was_open = t.is_open
    t.is_open = false
    if was_open && isopen(t.socket)
        close(t.socket)
    end
    return nothing
end

send_message(t::TcpTransport, builder::Capnp.AllocMessageBuilder) = _send_builder(t, builder)
receive_message(t::TcpTransport) = _receive_reader(t, t.socket, t.read_lock, t.max_message_size, t.max_segments, t.traversal_limit_words, t.nesting_limit)
function send_raw_message(t::TcpTransport, data::AbstractVector{UInt8})
    _validate_outbound_frame(data, t.max_message_size, t.max_segments)
    return _send_bytes(t, t.socket, t.write_lock, data)
end

"""Transport implemented with a Unix-domain socket on supported platforms."""
mutable struct UnixTransport{S} <: Transport
    socket::S
    is_open::Bool
    path::String
    max_message_size::Int
    max_segments::Int
    traversal_limit_words::Int
    nesting_limit::Int
    read_lock::ReentrantLock
    write_lock::ReentrantLock

    function UnixTransport(path::AbstractString; max_message_size::Int = Capnp.DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = Capnp.DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = Capnp.DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = Capnp.DEFAULT_NESTING_LIMIT)
        supports_unix_sockets() || throw(ArgumentError("Unix-domain sockets are not supported on this platform"))
        Capnp._validate_reader_limits(max_message_size, max_segments)
        Capnp._validate_traversal_limits(traversal_limit_words, nesting_limit)
        socket = Sockets.connect(path)
        return new{typeof(socket)}(socket, isopen(socket), String(path), max_message_size, max_segments, traversal_limit_words, nesting_limit, ReentrantLock(), ReentrantLock())
    end

    function UnixTransport(socket::S, path::AbstractString; max_message_size::Int = Capnp.DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = Capnp.DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = Capnp.DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = Capnp.DEFAULT_NESTING_LIMIT) where {S}
        Capnp._validate_reader_limits(max_message_size, max_segments)
        Capnp._validate_traversal_limits(traversal_limit_words, nesting_limit)
        new{S}(socket, isopen(socket), String(path), max_message_size, max_segments, traversal_limit_words, nesting_limit, ReentrantLock(), ReentrantLock())
    end
end

Base.isopen(t::UnixTransport) = t.is_open && isopen(t.socket)

function Base.close(t::UnixTransport)
    was_open = t.is_open
    t.is_open = false
    if was_open && isopen(t.socket)
        close(t.socket)
    end
    return nothing
end

send_message(t::UnixTransport, builder::Capnp.AllocMessageBuilder) = _send_builder(t, builder)
receive_message(t::UnixTransport) = _receive_reader(t, t.socket, t.read_lock, t.max_message_size, t.max_segments, t.traversal_limit_words, t.nesting_limit)
function send_raw_message(t::UnixTransport, data::AbstractVector{UInt8})
    _validate_outbound_frame(data, t.max_message_size, t.max_segments)
    return _send_bytes(t, t.socket, t.write_lock, data)
end

"""In-memory transport with explicit incoming and outgoing queues for tests."""
mutable struct MockTransport <: Transport
    sent_messages::Vector{Vector{UInt8}}
    receive_queue::Vector{Vector{UInt8}}
    is_open::Bool
    max_message_size::Int
    max_segments::Int
    traversal_limit_words::Int
    nesting_limit::Int

    function MockTransport(; max_message_size::Int = Capnp.DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = Capnp.DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = Capnp.DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = Capnp.DEFAULT_NESTING_LIMIT)
        Capnp._validate_reader_limits(max_message_size, max_segments)
        Capnp._validate_traversal_limits(traversal_limit_words, nesting_limit)
        new(Vector{UInt8}[], Vector{UInt8}[], true, max_message_size, max_segments, traversal_limit_words, nesting_limit)
    end
end

Base.isopen(t::MockTransport) = t.is_open
Base.close(t::MockTransport) = (t.is_open = false; nothing)
send_message(t::MockTransport, builder::Capnp.AllocMessageBuilder) = _send_builder(t, builder)

function receive_message(t::MockTransport)
    _check_open(t)
    isempty(t.receive_queue) && throw(DisconnectedException("No queued message"))
    data = popfirst!(t.receive_queue)
    return Capnp.MessageReader(IOBuffer(data); max_message_size = t.max_message_size, max_segments = t.max_segments, traversal_limit_words = t.traversal_limit_words, nesting_limit = t.nesting_limit)
end

function send_raw_message(t::MockTransport, data::AbstractVector{UInt8})
    _check_open(t)
    _validate_outbound_frame(data, t.max_message_size, t.max_segments)
    push!(t.sent_messages, Vector{UInt8}(data))
    return nothing
end

function inject_message!(t::MockTransport, builder::Capnp.AllocMessageBuilder)
    buffer = IOBuffer()
    Capnp.writeMessageToStream(builder, buffer)
    push!(t.receive_queue, take!(buffer))
    return nothing
end

inject_message!(t::MockTransport, data::AbstractVector{UInt8}) = (push!(t.receive_queue, Vector{UInt8}(data)); nothing)
get_sent_messages(t::MockTransport) = t.sent_messages
clear_sent_messages!(t::MockTransport) = (empty!(t.sent_messages); nothing)

export Transport, TransportContractError, IOTransport, TcpTransport, UnixTransport, MockTransport
export send_message, receive_message, send_raw_message
export inject_message!, get_sent_messages, clear_sent_messages!
export supports_unix_sockets, default_transport_type

# Deadline API
function set_read_deadline!(t::Transport, deadline_ns::Union{UInt64,Nothing})
    # Fallback does nothing
    return nothing
end

function set_write_deadline!(t::Transport, deadline_ns::Union{UInt64,Nothing})
    # Fallback does nothing
    return nothing
end
"""
    closewrite(t::Transport)

Half-close the transport, indicating no more data will be written.
"""
function Base.closewrite(t::Transport)
    # Fallback does nothing
    nothing
end

Base.closewrite(t::TcpTransport) = Sockets.closewrite(t.socket)
Base.closewrite(t::UnixTransport) = Sockets.closewrite(t.socket)
