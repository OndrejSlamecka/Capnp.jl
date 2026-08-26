# Shared functionality used by generated code.

const Segment = Vector{UInt8}
const DEFAULT_MAX_MESSAGE_SIZE = 64 * 1024 * 1024
const DEFAULT_MAX_SEGMENTS = 512
const DEFAULT_TRAVERSAL_LIMIT_WORDS = 8 * 1024 * 1024
const DEFAULT_NESTING_LIMIT = 64

"""Raised when a byte stream is not a valid, safely bounded Cap'n Proto message."""

struct InvalidMessageError <: Exception
    message::String
end

Base.showerror(io::IO, error::InvalidMessageError) = print(io, "Invalid Cap'n Proto message: ", error.message)

function _validate_reader_limits(max_message_size::Int, max_segments::Int)
    max_message_size >= 8 || throw(ArgumentError("max_message_size must be at least 8 bytes"))
    max_segments >= 1 || throw(ArgumentError("max_segments must be positive"))
    return nothing
end

function _read_le_uint32(buffer::AbstractVector{UInt8}, offset::Int)
    offset >= 1 && offset <= length(buffer) - 3 || throw(InvalidMessageError("truncated framing header"))
    return UInt32(buffer[offset]) | UInt32(buffer[offset+1]) << 8 | UInt32(buffer[offset+2]) << 16 | UInt32(buffer[offset+3]) << 24
end

function _read_le_uint32(io::IO)
    bytes = read(io, 4)
    length(bytes) == 4 || throw(InvalidMessageError("truncated framing header"))
    return _read_le_uint32(bytes, 1)
end

function _write_le_uint32(io::IO, value::Integer)
    word = UInt32(value)
    write(io, UInt8(word & 0xff))
    write(io, UInt8((word >> 8) & 0xff))
    write(io, UInt8((word >> 16) & 0xff))
    write(io, UInt8((word >> 24) & 0xff))
    return 4
end

function _store_le_uint32!(buffer::AbstractVector{UInt8}, offset::Integer, value::Integer)
    index = Int(offset)
    _checked_byte_range(buffer, index - 1, 4)
    word = UInt32(value)
    buffer[index] = UInt8(word & 0xff)
    buffer[index+1] = UInt8((word >> 8) & 0xff)
    buffer[index+2] = UInt8((word >> 16) & 0xff)
    buffer[index+3] = UInt8((word >> 24) & 0xff)
    return word
end

_decode_signed_word_offset(bytes::Int64) = Int(reinterpret(Int32, UInt32(reinterpret(UInt64, bytes) & typemax(UInt32)))) >> 2

function _checked_word_target(pointer_position::Int, relative_offset::Int)
    target = pointer_position + 1 + relative_offset
    0 <= target <= typemax(UInt32) || throw(InvalidMessageError("pointer resolves outside the supported word range"))
    return UInt32(target)
end

abstract type MessageTraverser end
abstract type Reader <: MessageTraverser end
abstract type Writer <: MessageTraverser end

_decrement_traversal_limit!(traverser::Writer, words::Integer) = nothing
function _decrement_traversal_limit!(traverser::Reader, words::Integer)
    traverser.traversal_limit_words -= Int(words)
    traverser.traversal_limit_words >= 0 || throw(InvalidMessageError("Message traversal limit exceeded"))
end


abstract type CapnpPointer end

struct WirePointer <: CapnpPointer
    segment::UInt32
    offset::UInt32
end

function _checked_segment(segments, segment_index::Integer)
    index = Int(segment_index)
    1 <= index <= length(segments) || throw(InvalidMessageError("segment index $index is out of bounds"))
    return segments[index]
end

function _checked_byte_range(segment::AbstractVector{UInt8}, byte_offset::Integer, byte_count::Integer)
    offset = Int(byte_offset)
    count = Int(byte_count)
    offset >= 0 || throw(InvalidMessageError("negative byte offset $offset"))
    count >= 0 || throw(InvalidMessageError("negative byte count $count"))
    offset <= length(segment) && count <= length(segment) - offset || throw(InvalidMessageError("byte range $offset:$(offset + count) exceeds a $(length(segment))-byte segment"))
    return offset
end

function _checked_load(::Type{T}, segment::AbstractVector{UInt8}, byte_offset::Integer) where {T}
    offset = _checked_byte_range(segment, byte_offset, sizeof(T))
    GC.@preserve segment return unsafe_load(Ptr{T}(pointer(segment) + offset))
end

function _checked_load(::Type{T}, segments, segment_index::Integer, byte_offset::Integer) where {T}
    return _checked_load(T, _checked_segment(segments, segment_index), byte_offset)
end

function _checked_store!(segment::AbstractVector{UInt8}, byte_offset::Integer, value::T) where {T}
    offset = _checked_byte_range(segment, byte_offset, sizeof(T))
    GC.@preserve segment unsafe_store!(Ptr{T}(pointer(segment) + offset), value)
    return value
end

function _checked_store!(segments, segment_index::Integer, byte_offset::Integer, value)
    return _checked_store!(_checked_segment(segments, segment_index), byte_offset, value)
end

# Structures for reading
# TODO: think about a variant that uses a preallocated buffer
mutable struct MessageReader <: Reader
    capabilities::Vector{Any}
    segments::Vector{Segment}
    traversal_limit_words::Int
    nesting_limit::Int

    function MessageReader(io::IO; max_message_size::Int = DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = DEFAULT_NESTING_LIMIT)
        _validate_reader_limits(max_message_size, max_segments)

        # num segments
        num_segments = Int(_read_le_uint32(io)) + 1
        num_segments <= max_segments || throw(InvalidMessageError("segment count $num_segments exceeds limit $max_segments"))

        header_size = 4 * (1 + num_segments + (iseven(num_segments) ? 1 : 0))
        header_size <= max_message_size || throw(InvalidMessageError("framing header exceeds the message-size limit"))

        # size of each segment
        segment_sizes = Vector{Int}(undef, num_segments)
        total_size = header_size
        for i = 1:num_segments
            size_bytes = Base.checked_mul(Int(_read_le_uint32(io)), 8)
            total_size = Base.checked_add(total_size, size_bytes)
            total_size <= max_message_size || throw(InvalidMessageError("message size $total_size exceeds limit $max_message_size"))
            segment_sizes[i] = size_bytes
        end

        # padding
        if iseven(num_segments)
            _read_le_uint32(io) == 0 || throw(InvalidMessageError("non-zero framing padding"))
        end

        # copy them all to memory
        segments = Vector{Segment}(undef, num_segments)
        for (i, size_bytes) in enumerate(segment_sizes)
            data = read(io, size_bytes)
            length(data) == size_bytes || throw(InvalidMessageError("segment $i is truncated"))
            segments[i] = data
        end

        new(Any[], segments, traversal_limit_words, nesting_limit)
    end
end

"""
    BufferMessageReader <: Reader

Zero-copy message reader that operates on pre-allocated byte buffers.
Uses views into the provided buffer instead of copying data.

# Usage
```julia
bytes = read("message.bin")
reader = BufferMessageReader(bytes)
# Access data without copying
```
"""
mutable struct BufferMessageReader <: Reader
    capabilities::Vector{Any}
    segments::Vector{SubArray{UInt8,1,Vector{UInt8},Tuple{UnitRange{Int64}},true}}
    _buffer::Vector{UInt8}  # Keep reference to prevent GC
    traversal_limit_words::Int
    nesting_limit::Int

    function BufferMessageReader(buffer::Vector{UInt8}; max_message_size::Int = DEFAULT_MAX_MESSAGE_SIZE, max_segments::Int = DEFAULT_MAX_SEGMENTS, traversal_limit_words::Int = DEFAULT_TRAVERSAL_LIMIT_WORDS, nesting_limit::Int = DEFAULT_NESTING_LIMIT)
        _validate_reader_limits(max_message_size, max_segments)

        length(buffer) >= 8 || throw(InvalidMessageError("message is shorter than the minimum framing header"))

        # Parse header from buffer (same format as MessageReader)
        # First 4 bytes: number of segments - 1
        num_segments = Int(_read_le_uint32(buffer, 1)) + 1
        num_segments <= max_segments || throw(InvalidMessageError("segment count $num_segments exceeds limit $max_segments"))

        header_size = 4 + 4 * num_segments
        if iseven(num_segments)
            header_size += 4  # padding
        end
        header_size <= max_message_size || throw(InvalidMessageError("framing header exceeds the message-size limit"))
        length(buffer) >= header_size || throw(InvalidMessageError("truncated framing header"))

        # Read segment sizes
        segment_sizes = Vector{Int}(undef, num_segments)
        total_size = header_size
        for i = 1:num_segments
            offset = 4 + (i - 1) * 4
            size_bytes = Base.checked_mul(Int(_read_le_uint32(buffer, offset + 1)), 8)
            total_size = Base.checked_add(total_size, size_bytes)
            total_size <= max_message_size || throw(InvalidMessageError("message size $total_size exceeds limit $max_message_size"))
            segment_sizes[i] = size_bytes
        end
        iseven(num_segments) && _read_le_uint32(buffer, header_size - 3) != 0 && throw(InvalidMessageError("non-zero framing padding"))
        length(buffer) >= total_size || throw(InvalidMessageError("message declares $total_size bytes but only $(length(buffer)) are available"))

        # Create views into buffer for each segment (zero-copy)
        segments = Vector{SubArray{UInt8,1,Vector{UInt8},Tuple{UnitRange{Int64}},true}}()
        current_offset = header_size

        for size_bytes in segment_sizes
            push!(segments, view(buffer, (current_offset+1):(current_offset+size_bytes)))
            current_offset += size_bytes
        end

        new(Any[], segments, buffer, traversal_limit_words, nesting_limit)
    end
end

"""
    get_segments(reader::BufferMessageReader)

Get the segment views from a BufferMessageReader.
Returns views into the original buffer (zero-copy).
"""
get_segments(reader::BufferMessageReader) = reader.segments

# Structures for writing
mutable struct AllocMessageBuilder <: Writer
    segments::Vector{Segment}

    current_segment::UInt32
    current_offset::UInt32

    capabilities::Vector{Any}

    AllocMessageBuilder() = new([zeros(1024)], 1, 0, Any[]) # the c++ lib uses 1024
end

function writeMessageToStream(builder::AllocMessageBuilder, io)
    _write_le_uint32(io, length(builder.segments) - 1)
    halfwords = 1

    for (i, segment) in enumerate(builder.segments)
        size = length(segment)
        if i == builder.current_segment # last
            size = 8 * builder.current_offset
        end
        _write_le_uint32(io, size ÷ 8)
        halfwords += 1
    end

    if halfwords % 2 == 1 # padding
        _write_le_uint32(io, 0)
    end

    for (i, segment) in enumerate(builder.segments)
        if i == builder.current_segment # last
            write(io, segment[1:(8*builder.current_offset)])
        else
            write(io, segment)
        end
    end
end

"""
    BufferMessageBuilder <: Writer

Zero-allocation message builder that writes directly to a pre-allocated buffer.
Does not allocate new segments - all data must fit in the provided buffer.

# Usage
```julia
buffer = zeros(UInt8, 4096)
builder = BufferMessageBuilder(buffer)
# ... build message ...
bytes_written = finalize!(builder)
# buffer[1:bytes_written] contains the message
```

# Notes
- The buffer must be large enough to hold the entire message
- If the message exceeds buffer capacity, an error is thrown
- Use `finalize!(builder)` to get the number of bytes written
"""
mutable struct BufferMessageBuilder <: Writer
    segments::Vector{SubArray{UInt8,1,Vector{UInt8},Tuple{UnitRange{Int64}},true}}
    _buffer::Vector{UInt8}
    current_segment::UInt32
    current_offset::UInt32
    _header_size::Int
    capabilities::Vector{Any}

    function BufferMessageBuilder(buffer::Vector{UInt8})
        # Reserve 8 bytes for header (4 bytes num_segments + 4 bytes segment_size)
        header_size = 8
        if length(buffer) < header_size + 8
            error("Buffer too small for BufferMessageBuilder (minimum $(header_size + 8) bytes)")
        end

        # Create a view for the single segment (after header)
        segment_view = view(buffer, (header_size+1):length(buffer))
        segments = [segment_view]

        new(segments, buffer, 1, 0, header_size, Any[])
    end
end

"""
    finalize!(builder::BufferMessageBuilder) -> Int

Finalize the message and return the total number of bytes written.
Writes the message header to the beginning of the buffer.

# Returns
- Number of bytes written (header + data)
"""
function finalize!(builder::BufferMessageBuilder)
    buffer = builder._buffer
    header_size = builder._header_size

    # Write header: number of segments - 1
    _store_le_uint32!(buffer, 1, 0)

    # Write segment size in words
    segment_size_words = builder.current_offset
    _store_le_uint32!(buffer, 5, segment_size_words)

    # Total bytes = header + segment data
    total_bytes = header_size + 8 * builder.current_offset
    return total_bytes
end

"""
    get_segments(builder::BufferMessageBuilder)

Get the segment views from a BufferMessageBuilder.
"""
get_segments(builder::BufferMessageBuilder) = builder.segments

function alloc(builder::Writer, pointer_location::WirePointer, size_bytes)
    # recall cld(x,y) = div(x,y,RoundUp)

    # TODO: This implementation is of course very wasteful of space; improve

    if size_bytes == 0
        # println("alloc 0, special case")
        return (pointer_location, pointer_location.segment, pointer_location.offset) # TODO: maybe this isn't the right default?
    end

    remaining_bytes = length(builder.segments[builder.current_segment]) - 8 * builder.current_offset
    if size_bytes > remaining_bytes
        next_size = length(builder.segments[end])
        if length(builder.segments) > 1
            next_size *= 2
        end

        # +8 for landing pointer
        while size_bytes + 8 > next_size # what does the C++ implementation do?
            next_size *= 2
        end

        push!(builder.segments, zeros(next_size))
        builder.current_segment += 1
        builder.current_offset = 0
    end

    landing_pad_space = UInt32(0)
    if pointer_location.segment != builder.current_segment
        size_bytes += 8 # need 1 word more for landing pointer

        # make pointer_location into a far pointer
        landing_location = WirePointer(builder.current_segment, builder.current_offset)
        write_far_pointer(builder, pointer_location, landing_location)
        pointer_location = landing_location

        landing_pad_space = UInt32(1)
    end

    segment, offset = builder.current_segment, builder.current_offset + landing_pad_space
    # println("alloc ", size_bytes, " bytes in segment ", segment, " starting from ", 8*offset)
    builder.current_offset += cld(size_bytes, 8)
    (pointer_location, segment, offset)
end

# Bools
function read_bool(ptr, from_bits)
    byte_position = from_bits >> 3
    in_byte_position = from_bits & 0b111

    byte = _checked_load(Int8, ptr.traverser.segments, ptr.segment, 8 * Int(ptr.offset) + byte_position)
    Bool((byte >> in_byte_position) & 0b1)
end

function write_bool(ptr, from_bits, value)
    byte_position = from_bits >> 3
    in_byte_position = from_bits & 0b111

    segment = _checked_segment(ptr.traverser.segments, ptr.segment)
    position = 8 * Int(ptr.offset) + byte_position
    # println("Writing value ", value, " at segment ", ptr.segment, ", byte ", ptr.offset * 8 + from ÷ 8)
    byte = _checked_load(UInt8, segment, position)
    # make the desired position zero and then place `value` to it
    byte = byte & ~(UInt8(1) << in_byte_position) | (value << in_byte_position)
    _checked_store!(segment, position, byte)
end

# "Bits" types except for bool.
# For example Int32, see `is_capnp_bits`. In general it should be those that are "plain data" and so `isbits` in Julia.
# Bool is an exception (it is "bits" in Julia but Capnp.jl's CapnpTypeBool is not) because capnp fits 8 bools into one byte.
function read_bits(ptr, from, type)
    _checked_load(type, ptr.traverser.segments, ptr.segment, 8 * Int(ptr.offset) + from)
end

function write_bits(ptr, from, type, value)
    # println("Writing value ", value, " at segment ", ptr.segment, ", byte ", ptr.offset * 8 + from ÷ 8)
    _checked_store!(ptr.traverser.segments, ptr.segment, 8 * Int(ptr.offset) + from, convert(type, value))
end

# Pointer tooling, especially for far (=inter-segment) pointers
is_far_pointer(bytes::Int64) = bytes & 0b11 == 2

"""
Returns bytes of the pointer at the given position and the location it points to.
"""
function resolve_pointer(ptr, byte_section_words, ptrix)::Tuple{Int64,UInt32,UInt32}
    position_words = Int(ptr.offset) + Int(byte_section_words) + Int(ptrix)
    bytes = _checked_load(Int64, ptr.traverser.segments, ptr.segment, 8 * position_words)

    if is_far_pointer(bytes)
        # landing pad
        far_offset = Int((UInt64(bytes) >> 3) & 0x1fff_ffff)
        segment_id = Int(UInt32(UInt64(bytes) >> 32)) + 1 # numbered from zero -> need +1 for Julia
        far_bytes = _checked_load(Int64, ptr.traverser.segments, segment_id, 8 * far_offset)

        if bytes & 0b100 == 0 # B == 0
            # far_bytes is the pointer, it tells us the absolute address within segment too (pointed_to_offset)
            local_ptr_offset = _decode_signed_word_offset(far_bytes)
            pointed_to_offset = _checked_word_target(far_offset, local_ptr_offset)

            (far_bytes, UInt32(segment_id), pointed_to_offset)
        else # B == 1
            # in this case we need to read the far bytes as another far pointer and use its segment_id and pointed_to_offset
            # furthermore behind this another far pointer there's the struct description (the bytes to read)
            is_far_pointer(far_bytes) || throw(InvalidMessageError("Expected far pointer landing pad"))
            (far_bytes & 0b100) == 0 || throw(InvalidMessageError("Double far pointer landing pad cannot be another double far pointer"))

            far_far_offset = Int((UInt64(far_bytes) >> 3) & 0x1fff_ffff)
            far_segment_id = Int(UInt32(UInt64(far_bytes) >> 32)) + 1 # numbered from zero -> need +1 for Julia

            far_bytes_struct = _checked_load(Int64, ptr.traverser.segments, segment_id, 8 * (far_offset + 1))

            _decode_signed_word_offset(far_bytes_struct) == 0 || throw(InvalidMessageError("Double far pointer landing pad second word offset must be 0"))

            (far_bytes_struct, UInt32(far_segment_id), UInt32(far_far_offset))
        end
    else
        offset = _decode_signed_word_offset(bytes)
        (bytes, ptr.segment, _checked_word_target(position_words, offset))
    end
end

function write_far_pointer(builder::Writer, pointer_location::WirePointer, landing_location::WirePointer)
    A = Int64(0b10)
    B = Int64(0) # TODO: 0 is for 1 word landing pad variant, two word landing pad not yet supported
    C = Int64(landing_location.offset)
    D = Int64(landing_location.segment - 1) # 1 based in jl, 0 based in capnp

    bytes = (D << 32) | (C << 3) | (B << 2) | A
    # println("Writing far pointer located in segment $(pointer_location.segment), offset $(pointer_location.offset); $(A) $(B) $(C) $(D)")
    _checked_store!(builder.segments, pointer_location.segment, 8 * Int(pointer_location.offset), bytes)
end

# Structs
struct StructPointer{T} <: CapnpPointer where {T<:MessageTraverser}
    traverser::T

    segment::UInt32
    offset::UInt32 # absolute address within segment, in words

    data_word_count::UInt16
    pointer_count::UInt16
end

function read_struct_pointer(ptr, byte_section_words, ptrix)
    (bytes, segment, offset) = resolve_pointer(ptr, byte_section_words, ptrix)

    if bytes == 0
        # It's up to readers to default
        nothing
    elseif bytes & 0b11 == 0
        data_words = UInt16((bytes >> 32) & 0xffff)
        ptr_words = UInt16((bytes >> 48) & 0xffff)

        _checked_byte_range(_checked_segment(ptr.traverser.segments, segment), 8 * offset, 8 * (Int(data_words) + Int(ptr_words)))
        _decrement_traversal_limit!(ptr.traverser, Int(data_words) + Int(ptr_words))
        StructPointer(ptr.traverser, segment, offset, data_words, ptr_words)
    else
        throw(InvalidMessageError("Not a struct at byte $offset of segment $segment, A = $(bytes & 0b11)"))
    end
end

function write_root_struct_pointer(ptr)
    A = 0
    B = 0
    C = Int64(ptr.data_word_count)
    D = Int64(ptr.pointer_count)

    bytes = (D << 48) | (C << 32) | (B << 2) | A

    # println("Writing root struct pointer at pos 0 ", bytes)
    _checked_store!(ptr.traverser.segments, 1, 0, Int64(bytes))
    ptr
end

function write_struct_pointer(pointer_location::WirePointer, ptr)
    @assert pointer_location.segment == ptr.segment
    position_words = pointer_location.offset
    position_bytes = 8 * position_words

    bytes = _checked_load(Int64, ptr.traverser.segments, pointer_location.segment, position_bytes)
    (bytes & 0b11) == 0 || throw(InvalidMessageError("Invalid list tag"))

    A = Int64(0)
    B = Int64(ptr.offset) - Int64(position_words) - 1 # the difference between position and allocated space
    C = Int64(ptr.data_word_count)
    D = Int64(ptr.pointer_count)

    bytes = (D << 48) | (C << 32) | (B << 2) | A

    # println("Writing struct pointer at pos ", position_bytes, " ", bytes, " ", B, " ", C, " " , D)
    _checked_store!(ptr.traverser.segments, pointer_location.segment, position_bytes, bytes)
    ptr
end

## Lists
abstract type ListPointer <: CapnpPointer end

struct SimpleListPointer{ElType,T} <: ListPointer where {ElType<:CapnpType,T<:MessageTraverser}
    traverser::T

    segment::UInt32
    offset::UInt32 # absolute address within segment, in words

    element_size::ElementSize
    length::UInt32 # list size, number of elements
end

struct CompositeListPointer{T} <: ListPointer where {T<:MessageTraverser}
    traverser::T

    segment::UInt32
    offset::UInt32 # absolute address within segment, in words

    length::UInt32 # list size, number of elements
    data_word_count::UInt16
    pointer_count::UInt16
end

function validate_struct_pointer(ptr, minimum_data_words::Integer, minimum_pointer_words::Integer, type_name)
    ptr === nothing && return ptr
    ptr isa StructPointer || throw(InvalidMessageError("$type_name must be encoded as a struct pointer"))
    ptr.data_word_count >= minimum_data_words && ptr.pointer_count >= minimum_pointer_words ||
        throw(InvalidMessageError("$type_name struct is smaller than required by its schema"))
    return ptr
end

function validate_struct_list_pointer(ptr::ListPointer, minimum_data_words::Integer, minimum_pointer_words::Integer, type_name)
    isempty(ptr) && return ptr
    ptr isa SimpleListPointer && return ptr
    ptr isa CompositeListPointer || throw(InvalidMessageError("$type_name list has an unsupported pointer representation"))
    ptr.data_word_count >= minimum_data_words && ptr.pointer_count >= minimum_pointer_words ||
        throw(InvalidMessageError("$type_name list elements are smaller than required by their schema"))
    return ptr
end

# [] operator
function Base.getindex(ptr::SimpleListPointer{ElType,Traverser}, i) where {ElType<:CapnpType,Traverser<:MessageTraverser}
    1 <= i <= ptr.length || throw(BoundsError(ptr, i))
    is_capnp_bits(ElType) || throw(ArgumentError("list element type $ElType is not a scalar type"))

    # i-1 for 1-based indices
    position = 8 * Int(ptr.offset) + (i - 1) * capnp_sizeof(ElType)
    # println("getting ", i, " ", position)
    _checked_load(capnp_type_to_bits_type(ElType), ptr.traverser.segments, ptr.segment, position)
end

function Base.setindex!(ptr::SimpleListPointer{ElType,Traverser}, value, i) where {ElType<:CapnpType,Traverser<:MessageTraverser}
    1 <= i <= ptr.length || throw(BoundsError(ptr, i))
    is_capnp_bits(ElType) || throw(ArgumentError("list element type $ElType is not a scalar type"))

    # i-1 for 1-based indices
    position = 8 * Int(ptr.offset) + (i - 1) * capnp_sizeof(ElType)
    # println("setting ", i, " ", position)
    _checked_store!(ptr.traverser.segments, ptr.segment, position, convert(capnp_type_to_bits_type(ElType), value))
end

function Base.getindex(ptr::CompositeListPointer, i)
    1 <= i <= ptr.length || throw(BoundsError(ptr, i))

    # +1 for tag
    # i-1 for 1-based indices
    position = UInt32(ptr.offset + 1 + (i - 1) * (ptr.data_word_count + ptr.pointer_count))
    # println("getting ", i, " ", position)
    StructPointer(ptr.traverser, ptr.segment, position, ptr.data_word_count, ptr.pointer_count)
end

# Iterator interface
function Base.iterate(ptr::CompositeListPointer, state = 0)
    if state >= ptr.length
        nothing
    else
        position = ptr.offset + UInt32(1) + UInt32(state) * (ptr.data_word_count + ptr.pointer_count)
        (StructPointer(ptr.traverser, ptr.segment, position, ptr.data_word_count, ptr.pointer_count), state + 1)
    end
end

function Base.iterate(ptr::SimpleListPointer{T}, state = 0) where {T<:CapnpType}
    if state >= ptr.length
        nothing
    else
        item = nothing
        if is_capnp_bits(T)
            item = read_bits(ptr, capnp_sizeof(T) * state, capnp_type_to_bits_type(T))
        elseif ptr.element_size == Pointer
            if T === CapnpData
                pointer_container = StructPointer(
                    ptr.traverser, ptr.segment, UInt32(Int(ptr.offset) + state), UInt16(0), UInt16(1),
                )
                item = read_data(read_list_pointer(pointer_container, 0, 0, CapnpUInt8))
                return (item, state + 1)
            end
            pointer_word_offset = Int(ptr.offset) + state
            pointer_container = StructPointer(
                ptr.traverser, ptr.segment, UInt32(pointer_word_offset), UInt16(0), UInt16(1),
            )
            item = read_struct_pointer(pointer_container, 0, 0)
        else
            throw(InvalidMessageError("Iteration over simple lists only supports bits types or pointer types (element_size=$(ptr.element_size))."))
        end

        (item, state + 1)
    end
end

Base.length(ptr::ListPointer) = ptr.length
Base.isempty(ptr::ListPointer) = iszero(ptr.length)

# Tags for composite lists
struct ListTag
    length::UInt32
    data_word_count::UInt16
    pointer_count::UInt16
end

function read_list_tag(segment, offset)
    bytes = _checked_load(Int64, segment, Int(offset) * 8)

    (bytes & 0b11) == 0 || throw(InvalidMessageError("Invalid list tag"))

    length = (bytes & 0xff_ff) >> 2
    data_word_count = (bytes >> 32) & 0xffff
    ptr_count = (bytes >> 48) & 0xffff

    ListTag(length, data_word_count, ptr_count)
end

_expected_element_size(::Type{CapnpVoid}) = Empty
_expected_element_size(::Type{CapnpBool}) = Bit
_expected_element_size(::Type{CapnpInt8}) = Byte
_expected_element_size(::Type{CapnpUInt8}) = Byte
_expected_element_size(::Type{CapnpInt16}) = TwoBytes
_expected_element_size(::Type{CapnpUInt16}) = TwoBytes
_expected_element_size(::Type{CapnpInt32}) = FourBytes
_expected_element_size(::Type{CapnpUInt32}) = FourBytes
_expected_element_size(::Type{CapnpFloat32}) = FourBytes
_expected_element_size(::Type{CapnpInt64}) = EightBytes
_expected_element_size(::Type{CapnpUInt64}) = EightBytes
_expected_element_size(::Type{CapnpFloat64}) = EightBytes
_expected_element_size(::Type{CapnpData}) = Pointer
_expected_element_size(::Type{CapnpStruct}) = nothing

function _simple_list_byte_count(element_size::ElementSize, length::UInt32)
    count = Int(length)
    element_size == Empty && return 0
    element_size == Bit && return cld(count, 8)
    element_size == Byte && return count
    element_size == TwoBytes && return 2 * count
    element_size == FourBytes && return 4 * count
    (element_size == EightBytes || element_size == Pointer) && return 8 * count
    throw(InvalidMessageError("inline-composite list requires a list tag"))
end

function write_list_tag(pointer_location::WirePointer, ptr::CompositeListPointer)
    # TODO: check bytes are 0 at location

    # list tag
    A = Int64(0)
    B = ptr.length
    C = Int64(ptr.data_word_count)
    D = Int64(ptr.pointer_count)
    tag_bytes = (D << 48) | (C << 32) | (B << 2) | A
    # println("Writing composite list tag at segment ", pointer_location.segment, ", byte ", 8*ptr.offset)
    _checked_store!(ptr.traverser.segments, pointer_location.segment, 8 * Int(ptr.offset), tag_bytes)
end

# Text is a special kind of list
function read_text(ptr::SimpleListPointer)
    ptr.element_size == Byte || throw(InvalidMessageError("Text pointer must point to a list of bytes"))
    if ptr.length == 0
        ""
    else
        segment = _checked_segment(ptr.traverser.segments, ptr.segment)
        byte_offset = 8 * Int(ptr.offset)
        byte_count = Int(ptr.length)
        _checked_byte_range(segment, byte_offset, byte_count)
        segment[byte_offset+byte_count] == 0 || throw(InvalidMessageError("text is not NUL-terminated"))
        byte_count == 1 ? "" : String(copy(@view segment[(byte_offset+1):(byte_offset+byte_count-1)]))
    end
end

function write_text(ptr::ListPointer, text)
    ptr.element_size == Byte || throw(InvalidMessageError("Text pointer must point to a list of bytes"))
    segment = _checked_segment(ptr.traverser.segments, ptr.segment)
    bytes = codeunits(String(text))
    byte_offset = 8 * Int(ptr.offset)
    byte_count = length(bytes) + 1
    byte_count <= Int(ptr.length) || throw(ArgumentError("text does not fit in the allocated list"))
    _checked_byte_range(segment, byte_offset, byte_count)
    copyto!(segment, byte_offset + 1, bytes, 1, length(bytes))
    segment[byte_offset+byte_count] = 0
    return ptr
end

# List pointer read/write
function read_list_pointer(ptr, byte_section_words, ptrix, element_type = CapnpVoid)
    (bytes, segment, offset) = resolve_pointer(ptr, byte_section_words, ptrix)

    if bytes == 0
        SimpleListPointer{element_type,typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, 0)
    elseif bytes & 0b11 == 1
        element_size = ElementSize((bytes >> 32) & 0b111)
        list_size = UInt32(bytes >> 35)

        if element_size == InlineComposite
            segment_bytes = _checked_segment(ptr.traverser.segments, segment)
            _checked_byte_range(segment_bytes, 8 * offset, 8 * (Int(list_size) + 1))
            tag = read_list_tag(segment_bytes, offset)
            element_words = Int(tag.data_word_count) + Int(tag.pointer_count)
            required_words = Int(tag.length) * element_words
            required_words <= Int(list_size) || throw(InvalidMessageError("composite-list elements exceed the declared word count"))
            _decrement_traversal_limit!(ptr.traverser, Int(list_size) + 1)
            CompositeListPointer(ptr.traverser, segment, offset, tag.length, tag.data_word_count, tag.pointer_count)
        else
            expected_size = _expected_element_size(element_type)
            expected_size === nothing || element_type === CapnpVoid || element_size == expected_size ||
                throw(InvalidMessageError("list element size $element_size does not match requested type $element_type"))
            byte_count = _simple_list_byte_count(element_size, list_size)
            _checked_byte_range(_checked_segment(ptr.traverser.segments, segment), 8 * offset, byte_count)
            _decrement_traversal_limit!(ptr.traverser, cld(byte_count, 8))
            SimpleListPointer{element_type,typeof(ptr.traverser)}(ptr.traverser, segment, offset, element_size, list_size)
        end
    else
        throw(InvalidMessageError("Not a list $(bytes & 0b11) at offset $(ptr.offset) and after $(byte_section_words) word byte section and at $(ptrix) pointer index of segment $(ptr.segment)"))
    end
end


encode_list_element_size(x::ElementSize) = UInt16(x)
# since the above definition is relying on the enum's definition let's make sure the values are right:
@assert encode_list_element_size(Empty) == 0
@assert encode_list_element_size(Bit) == 1
@assert encode_list_element_size(Byte) == 2
@assert encode_list_element_size(TwoBytes) == 3
@assert encode_list_element_size(FourBytes) == 4
@assert encode_list_element_size(EightBytes) == 5
@assert encode_list_element_size(Pointer) == 6
@assert encode_list_element_size(InlineComposite) == 7

function write_list_pointer(pointer_location::WirePointer, ptr::SimpleListPointer{ElementT}) where {ElementT}
    @assert pointer_location.segment == ptr.segment "location segment $(pointer_location.segment), pointer segment $(ptr.segment)"
    position_words = pointer_location.offset
    position_bytes = 8 * position_words

    bytes = _checked_load(Int64, ptr.traverser.segments, pointer_location.segment, position_bytes)
    (bytes & 0b11) == 0 || throw(InvalidMessageError("Non-empty pointer type bits at segment $(pointer_location.segment), byte $(position_bytes), $(Int64(bytes))"))

    A = Int64(1) # list pointer indicator
    B = Int64(ptr.offset) - Int64(position_words) - 1 # offset, the difference between position and allocated space
    C = Int64(encode_list_element_size(ptr.element_size))
    D = Int64(ptr.length)

    bytes = (D << 35) | (C << 32) | (B << 2) | A

    # println("Writing simple list pointer at segment=", ptr.segment, "; offset=", position_bytes)
    _checked_store!(ptr.traverser.segments, pointer_location.segment, position_bytes, bytes)
end

function write_list_pointer(pointer_location::WirePointer, ptr::CompositeListPointer)
    @assert pointer_location.segment == ptr.segment
    position_words = pointer_location.offset
    position_bytes = 8 * position_words

    bytes = _checked_load(Int64, ptr.traverser.segments, pointer_location.segment, position_bytes)
    (bytes & 0b11) == 0 || throw(InvalidMessageError("Non-empty pointer type bits at segment $(pointer_location.segment), byte $(position_bytes)"))

    A = Int64(1) # list pointer
    B = Int64(ptr.offset) - Int64(position_words) - 1 # offset, the difference between position and allocated space
    C = Int64(7)
    D = Int64(ptr.length * (ptr.data_word_count + ptr.pointer_count))

    bytes = (D << 35) | (C << 32) | (B << 2) | A

    # println("Writing composite list pointer at pos ", position_bytes, " ", bytes, " ", B, " ", C, " " , D)
    _checked_store!(ptr.traverser.segments, pointer_location.segment, position_bytes, bytes)

    write_list_tag(pointer_location, ptr)

    ptr
end

## Capability Pointers (type 3)
# Cap'n Proto capability pointers reference entries in a capability table.
# These are used for RPC to pass object references between processes.

"""
    CapabilityPointer{T} <: CapnpPointer

A pointer to a capability (type 3 pointer in Cap'n Proto wire format).
Capabilities are references to remote or local objects that can be called via RPC.

# Fields
- `traverser::T`: The message traverser (reader or writer)
- `segment::UInt32`: Segment containing the pointer
- `offset::UInt32`: Word offset within the segment where the pointer is located
- `cap_index::UInt32`: Index into the message's capability table

# Wire Format
- Bits 0-1: Must be 3 (capability pointer type)
- Bits 2-31: Must be 0 (reserved)
- Bits 32-63: Capability table index
"""
struct CapabilityPointer{T} <: CapnpPointer where {T<:MessageTraverser}
    traverser::T
    segment::UInt32
    offset::UInt32
    cap_index::UInt32
end

"""
    is_capability_pointer(bytes::Int64) -> Bool

Check if the pointer bytes indicate a capability pointer (type 3).
"""
is_capability_pointer(bytes::Int64) = bytes & 0b11 == 3

"""
    read_capability_pointer(ptr, byte_section_words, ptrix) -> Union{CapabilityPointer, Nothing}

Read a capability pointer from the given struct pointer at the specified pointer index.

# Arguments
- `ptr`: Parent struct pointer
- `byte_section_words`: Number of data section words in the parent struct
- `ptrix`: Index within the pointer section (0-based)

# Returns
- `CapabilityPointer` if a valid capability pointer is found
- `nothing` if the pointer is null (all zeros)
- Throws if the pointer is not a capability pointer
"""
function read_capability_pointer(ptr, byte_section_words, ptrix)
    position_bytes = 8 * (ptr.offset + byte_section_words + ptrix)
    bytes = _checked_load(Int64, ptr.traverser.segments, ptr.segment, position_bytes)

    if bytes == 0
        # Null capability
        nothing
    elseif is_capability_pointer(bytes)
        # Bits 2-31 must be 0
        (bytes & 0x_ff_ff_ff_fc) == 0 || throw(InvalidMessageError("Invalid capability pointer: bits 2-31 must be 0"))

        # Capability index is in the upper 32 bits
        cap_index = UInt32(bytes >> 32)

        CapabilityPointer(ptr.traverser, ptr.segment, ptr.offset + byte_section_words + ptrix, cap_index)
    else
        throw(InvalidMessageError("Not a capability pointer at segment $(ptr.segment), offset $(ptr.offset + byte_section_words + ptrix)"))
    end
end

"""
    write_capability_pointer(pointer_location::WirePointer, traverser, cap_index::UInt32) -> CapabilityPointer

Write a capability pointer at the specified location.

# Arguments
- `pointer_location`: Where to write the pointer
- `traverser`: The message traverser (writer)
- `cap_index`: Index into the capability table

# Returns
- The created `CapabilityPointer`
"""
function write_capability_pointer(pointer_location::WirePointer, traverser, cap_index::UInt32)
    position_bytes = 8 * pointer_location.offset

    # Type 3 pointer: lower 32 bits are 0b11, upper 32 bits are capability index
    A = Int64(0b11)  # Capability pointer type
    D = Int64(cap_index)

    bytes = (D << 32) | A

    _checked_store!(traverser.segments, pointer_location.segment, position_bytes, bytes)

    CapabilityPointer(traverser, pointer_location.segment, pointer_location.offset, cap_index)
end

"""Read an untyped pointer while preserving its concrete wire-pointer kind."""
function read_any_pointer(ptr, byte_section_words, ptrix)
    position_words = Int(ptr.offset) + Int(byte_section_words) + Int(ptrix)
    original = _checked_load(Int64, ptr.traverser.segments, ptr.segment, 8 * position_words)
    original == 0 && return nothing
    original & 0b11 == 3 && return read_capability_pointer(ptr, byte_section_words, ptrix)

    bytes, segment, offset = resolve_pointer(ptr, byte_section_words, ptrix)
    kind = bytes & 0b11
    if kind == 0
        data_words = UInt16((bytes >> 32) & 0xffff)
        pointer_words = UInt16((bytes >> 48) & 0xffff)
        _checked_byte_range(_checked_segment(ptr.traverser.segments, segment), 8 * offset, 8 * (Int(data_words) + Int(pointer_words)))
        _decrement_traversal_limit!(ptr.traverser, Int(data_words) + Int(pointer_words))
        return StructPointer(ptr.traverser, segment, offset, data_words, pointer_words)
    elseif kind == 1
        element_size = ElementSize((bytes >> 32) & 0b111)
        list_size = UInt32(bytes >> 35)
        if element_size == InlineComposite
            segment_bytes = _checked_segment(ptr.traverser.segments, segment)
            _checked_byte_range(segment_bytes, 8 * offset, 8 * (Int(list_size) + 1))
            tag = read_list_tag(segment_bytes, offset)
            element_words = Int(tag.data_word_count) + Int(tag.pointer_count)
            Int(tag.length) * element_words <= Int(list_size) ||
                throw(InvalidMessageError("composite-list elements exceed the declared word count"))
            _decrement_traversal_limit!(ptr.traverser, Int(list_size) + 1)
            return CompositeListPointer(ptr.traverser, segment, offset, tag.length, tag.data_word_count, tag.pointer_count)
        end
        byte_count = _simple_list_byte_count(element_size, list_size)
        _checked_byte_range(_checked_segment(ptr.traverser.segments, segment), 8 * offset, byte_count)
        _decrement_traversal_limit!(ptr.traverser, cld(byte_count, 8))
        return SimpleListPointer{CapnpVoid,typeof(ptr.traverser)}(ptr.traverser, segment, offset, element_size, list_size)
    end
    throw(InvalidMessageError("Unsupported any-pointer kind $kind"))
end

function read_data(ptr::SimpleListPointer)
    ptr.element_size == Byte || throw(InvalidMessageError("Data pointer must point to a list of bytes"))
    if ptr.length == 0
        UInt8[]
    else
        segment = _checked_segment(ptr.traverser.segments, ptr.segment)
        byte_offset = 8 * Int(ptr.offset)
        byte_count = Int(ptr.length)
        _checked_byte_range(segment, byte_offset, byte_count)
        copy(@view segment[(byte_offset+1):(byte_offset+byte_count)])
    end
end
function read_data(ptr::Nothing)
    UInt8[]
end
function write_data(ptr::SimpleListPointer, data::AbstractVector{UInt8})
    ptr.element_size == Byte || throw(InvalidMessageError("Data pointer must point to a list of bytes"))
    ptr.length == length(data) || throw(InvalidMessageError("List size must match data length"))

    segment = _checked_segment(ptr.traverser.segments, ptr.segment)
    byte_offset = 8 * Int(ptr.offset)
    byte_count = length(data)
    _checked_byte_range(segment, byte_offset, byte_count)
    segment[(byte_offset+1):(byte_offset+byte_count)] .= data
    ptr
end
