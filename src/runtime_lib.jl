# Shared functionality used by generated code.

const Segment = Vector{UInt8}

abstract type MessageTraverser end
abstract type Reader <: MessageTraverser end
abstract type Writer <: MessageTraverser end

abstract type CapnpPointer end

struct WirePointer <: CapnpPointer
    segment::UInt32
    offset::UInt32
end

# Structures for reading
# TODO: think about a variant that uses a preallocated buffer
struct MessageReader <: Reader
    segments::Vector{Segment}

    function MessageReader(io::IO)
        # num segments
        num_segments = read(io, UInt32) + 1

        # size of each segment
        segments_sizes = zeros(UInt32, num_segments)
        for i = 1:num_segments
            segments_sizes[i] = read(io, UInt32)
        end

        # padding
        pad = 0
        if num_segments % 2 == 0
            pad = 1
            read(io, UInt32)
        end
        # println("stream header took ", (1+num_segments+pad)*4, " bytes, segments are ", segments_sizes)

        # copy them all to memory
        segments = Vector{Segment}()
        for size_words in segments_sizes
            data = UInt8[]
            readbytes!(io, data, 8 * size_words)
            push!(segments, data)
        end

        new(segments)
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
struct BufferMessageReader <: Reader
    segments::Vector{SubArray{UInt8, 1, Vector{UInt8}, Tuple{UnitRange{Int64}}, true}}
    _buffer::Vector{UInt8}  # Keep reference to prevent GC

    function BufferMessageReader(buffer::Vector{UInt8})
        if length(buffer) < 8
            # Minimum: 4 bytes header + 4 bytes segment size
            return new([view(buffer, 1:0)], buffer)
        end

        # Parse header from buffer (same format as MessageReader)
        # First 4 bytes: number of segments - 1
        num_segments = reinterpret(UInt32, buffer[1:4])[1] + 1

        header_size = 4 + 4 * num_segments
        if num_segments % 2 == 0
            header_size += 4  # padding
        end

        if length(buffer) < header_size
            return new([view(buffer, 1:0)], buffer)
        end

        # Read segment sizes
        segment_sizes = Vector{UInt32}(undef, num_segments)
        for i in 1:num_segments
            offset = 4 + (i - 1) * 4
            segment_sizes[i] = reinterpret(UInt32, buffer[offset+1:offset+4])[1]
        end

        # Create views into buffer for each segment (zero-copy)
        segments = Vector{SubArray{UInt8, 1, Vector{UInt8}, Tuple{UnitRange{Int64}}, true}}()
        current_offset = header_size

        for size_words in segment_sizes
            size_bytes = 8 * size_words
            if current_offset + size_bytes > length(buffer)
                size_bytes = max(0, length(buffer) - current_offset)
            end
            push!(segments, view(buffer, (current_offset + 1):(current_offset + size_bytes)))
            current_offset += size_bytes
        end

        new(segments, buffer)
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

    AllocMessageBuilder() = new([zeros(1024)], 1, 0) # the c++ lib uses 1024
end

function writeMessageToStream(builder::AllocMessageBuilder, io)
    write(io, UInt32(length(builder.segments) - 1))
    halfwords = 1

    for (i, segment) in enumerate(builder.segments)
        size = length(segment)
        if i == builder.current_segment # last
            size = 8 * builder.current_offset
        end
        write(io, UInt32(size ÷ 8)) # TODO: make sure this division is sensible, i.e. every segment is divisible by word size
        halfwords += 1
    end

    if halfwords % 2 == 1 # padding
        write(io, UInt32(0))
    end

    for (i, segment) in enumerate(builder.segments)
        if i == builder.current_segment # last
            write(io, segment[1:8*builder.current_offset])
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
    segments::Vector{SubArray{UInt8, 1, Vector{UInt8}, Tuple{UnitRange{Int64}}, true}}
    _buffer::Vector{UInt8}
    current_segment::UInt32
    current_offset::UInt32
    _header_size::Int

    function BufferMessageBuilder(buffer::Vector{UInt8})
        # Reserve 8 bytes for header (4 bytes num_segments + 4 bytes segment_size)
        header_size = 8
        if length(buffer) < header_size + 8
            error("Buffer too small for BufferMessageBuilder (minimum $(header_size + 8) bytes)")
        end

        # Create a view for the single segment (after header)
        segment_view = view(buffer, (header_size + 1):length(buffer))
        segments = [segment_view]

        new(segments, buffer, 1, 0, header_size)
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
    buffer[1:4] .= reinterpret(UInt8, [UInt32(0)])  # 1 segment, so write 0

    # Write segment size in words
    segment_size_words = builder.current_offset
    buffer[5:8] .= reinterpret(UInt8, [UInt32(segment_size_words)])

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

    segment = ptr.traverser.segments[ptr.segment]
    byte = unsafe_load(Ptr{Int8}(pointer(segment) + 8 * ptr.offset + byte_position))
    Bool((byte >> in_byte_position) & 0b1)
end

function write_bool(ptr, from_bits, value)
    byte_position = from_bits >> 3
    in_byte_position = from_bits & 0b111

    segment = ptr.traverser.segments[ptr.segment]
    # println("Writing value ", value, " at segment ", ptr.segment, ", byte ", ptr.offset * 8 + from ÷ 8)
    byte = unsafe_load(Ptr{UInt8}(pointer(segment) + 8 * ptr.offset + byte_position))
    # make the desired position zero and then place `value` to it
    byte = byte & ~(UInt8(1) << in_byte_position) | (value << in_byte_position)
    unsafe_store!(Ptr{UInt8}(pointer(segment) + 8 * ptr.offset + byte_position), byte)
end

# "Bits" types except for bool.
# For example Int32, see `is_capnp_bits`. In general it should be those that are "plain data" and so `isbits` in Julia.
# Bool is an exception (it is "bits" in Julia but Capnp.jl's CapnpTypeBool is not) because capnp fits 8 bools into one byte.
function read_bits(ptr, from, type)
    segment = ptr.traverser.segments[ptr.segment]
    unsafe_load(Ptr{type}(pointer(segment) + ptr.offset * 8 + from))
end

function write_bits(ptr, from, type, value)
    segment = ptr.traverser.segments[ptr.segment]
    # println("Writing value ", value, " at segment ", ptr.segment, ", byte ", ptr.offset * 8 + from ÷ 8)
    unsafe_store!(Ptr{type}(pointer(segment) + ptr.offset * 8 + from), value)
end

# Pointer tooling, especially for far (=inter-segment) pointers
is_far_pointer(bytes::Int64) = bytes & 0b11 == 2

"""
Returns bytes of the pointer at the given position and the location it points to.
"""
function resolve_pointer(ptr, byte_section_words, ptrix)::Tuple{Int64,UInt32,UInt32}
    position_bytes = 8 * (ptr.offset + byte_section_words + ptrix)
    bytes = unsafe_load(Ptr{Int64}(pointer(ptr.traverser.segments[ptr.segment]) + position_bytes))

    if is_far_pointer(bytes)
        # landing pad
        far_offset = (bytes & 0xff_ff_ff_ff) >> 3
        segment_id = (bytes >> 32) + 1 # numbered from zero -> need +1 for Julia
        far_bytes = unsafe_load(Ptr{Int64}(pointer(ptr.traverser.segments[segment_id]) + far_offset * 8))

        if bytes & 0b100 == 0 # B == 0
            # far_bytes is the pointer, it tells us the absolute address within segment too (pointed_to_offset)
            local_ptr_offset = (far_bytes & 0xff_ff_ff_ff) >> 2

            pointed_to_offset = far_offset + local_ptr_offset + 1

            (far_bytes, segment_id, pointed_to_offset)
        else # B == 1
            # in this case we need to read the far bytes as another far pointer and use its segment_id and pointed_to_offset
            # furthermore behind this another far pointer there's the struct description (the bytes to read)
            @assert is_far_pointer(far_bytes)
            @assert far_bytes & 0b100 == 0

            far_far_offset = (far_bytes & 0xff_ff_ff_ff) >> 3
            far_segment_id = (far_bytes >> 32) + 1 # numbered from zero -> need +1 for Julia

            far_bytes_struct = unsafe_load(Ptr{Int64}(pointer(ptr.traverser.segments[segment_id]) + (far_offset + 1) * 8))

            # TODO: assert far_bytes_struct's offset is 0

            (far_bytes_struct, far_segment_id, far_far_offset)
        end
    else
        offset = (bytes & 0xff_ff_ff_ff) >> 2
        (bytes, ptr.segment, ptr.offset + byte_section_words + (ptrix + 1) + offset)
    end
end

function write_far_pointer(builder::Writer, pointer_location::WirePointer, landing_location::WirePointer)
    A = Int64(0b10)
    B = Int64(0) # TODO: 0 is for 1 word landing pad variant, two word landing pad not yet supported
    C = Int64(landing_location.offset)
    D = Int64(landing_location.segment - 1) # 1 based in jl, 0 based in capnp

    bytes = (D << 32) | (C << 3) | (B << 2) | A
    # println("Writing far pointer located in segment $(pointer_location.segment), offset $(pointer_location.offset); $(A) $(B) $(C) $(D)")
    unsafe_store!(Ptr{Int64}(pointer(builder.segments[pointer_location.segment]) + 8 * pointer_location.offset), bytes)
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
        data_words = UInt16((bytes >> 32) & 0xff)
        ptr_words = UInt16((bytes >> 48) & 0xff)

        StructPointer(ptr.traverser, segment, offset, data_words, ptr_words)
    else
        throw("Not a struct at byte $offset of segment $segment, A = $(bytes & 0b11)")
    end
end

function write_root_struct_pointer(ptr)
    A = 0
    B = 0
    C = Int64(ptr.data_word_count)
    D = Int64(ptr.pointer_count)

    bytes = (D << 48) | (C << 32) | (B << 2) | A

    # println("Writing root struct pointer at pos 0 ", bytes)
    unsafe_store!(Ptr{Int64}(pointer(ptr.traverser.segments[1])), bytes)
    ptr
end

function write_struct_pointer(pointer_location::WirePointer, ptr)
    @assert pointer_location.segment == ptr.segment
    position_words = pointer_location.offset
    position_bytes = 8 * position_words

    bytes = unsafe_load(Ptr{Int64}(pointer(ptr.traverser.segments[pointer_location.segment]) + position_bytes))
    @assert bytes & 0b11 == 0

    A = Int64(0)
    B = Int64(ptr.offset - (position_words + 1)) # the difference between position and allocated space
    C = Int64(ptr.data_word_count)
    D = Int64(ptr.pointer_count)

    bytes = (D << 48) | (C << 32) | (B << 2) | A

    # println("Writing struct pointer at pos ", position_bytes, " ", bytes, " ", B, " ", C, " " , D)
    unsafe_store!(Ptr{Int64}(pointer(ptr.traverser.segments[pointer_location.segment]) + position_bytes), bytes)
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

# [] operator
function Base.getindex(ptr::SimpleListPointer{ElType,Traverser}, i) where {ElType<:CapnpType,Traverser<:MessageTraverser}
    @assert 1 <= i <= ptr.length
    @assert is_capnp_bits(ElType)

    # i-1 for 1-based indices
    position = UInt32(8 * ptr.offset + (i - 1) * capnp_sizeof(ElType))
    # println("getting ", i, " ", position)
    unsafe_load(Ptr{capnp_type_to_bits_type(ElType)}(pointer(ptr.traverser.segments[ptr.segment]) + position))
end

function Base.setindex!(ptr::SimpleListPointer{ElType,Traverser}, value, i) where {ElType<:CapnpType,Traverser<:MessageTraverser}
    @assert 1 <= i <= ptr.length
    @assert is_capnp_bits(ElType)

    # i-1 for 1-based indices
    position = UInt32(8 * ptr.offset + (i - 1) * capnp_sizeof(ElType))
    # println("setting ", i, " ", position)
    unsafe_store!(Ptr{capnp_type_to_bits_type(ElType)}(pointer(ptr.traverser.segments[ptr.segment]) + position), value)
end

function Base.getindex(ptr::CompositeListPointer, i)
    @assert 1 <= i <= ptr.length

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
            # Each element is a pointer to a struct (Cap'n Proto 1.3.0+ encoding)
            # Read the pointer at position state (each pointer is 1 word = 8 bytes)
            pointer_word_offset = ptr.offset + state
            bytes = unsafe_load(Ptr{Int64}(pointer(ptr.traverser.segments[ptr.segment]) + pointer_word_offset * 8))

            if bytes == 0
                # Null pointer
                item = nothing
            elseif bytes & 0b11 == 0
                # Struct pointer: decode offset, data_word_count, pointer_count
                offset_delta = (bytes % Int32) >> 2  # signed offset in words
                struct_offset = UInt32(pointer_word_offset + 1 + offset_delta)
                data_words = UInt16((bytes >> 32) & 0xff)
                ptr_words = UInt16((bytes >> 48) & 0xff)
                item = StructPointer(ptr.traverser, ptr.segment, struct_offset, data_words, ptr_words)
            elseif bytes & 0b11 == 2
                # Far pointer - follow indirection
                far_offset = (bytes >> 3) & 0x1f_ff_ff_ff_ff
                segment_id = UInt32((bytes >> 32) + 1)  # 0-based in wire format, 1-based in Julia
                # Read the landing pad
                landing_bytes = unsafe_load(Ptr{Int64}(pointer(ptr.traverser.segments[segment_id]) + far_offset * 8))
                if landing_bytes & 0b11 == 0
                    # Struct pointer at landing pad
                    landing_offset_delta = (landing_bytes % Int32) >> 2
                    struct_offset = UInt32(far_offset + 1 + landing_offset_delta)
                    data_words = UInt16((landing_bytes >> 32) & 0xff)
                    ptr_words = UInt16((landing_bytes >> 48) & 0xff)
                    item = StructPointer(ptr.traverser, segment_id, struct_offset, data_words, ptr_words)
                else
                    throw("Far pointer landing pad is not a struct pointer")
                end
            else
                throw("Expected struct or far pointer in list, got type $(bytes & 0b11)")
            end
        else
            throw("Iteration over simple lists only supports bits types or pointer types (element_size=$(ptr.element_size)).")
        end

        (item, state + 1)
    end
end

Base.length(ptr::ListPointer) = ptr.length

# Tags for composite lists
struct ListTag
    length::UInt32
    data_word_count::UInt16
    pointer_count::UInt16
end

function read_list_tag(segment, offset)
    bytes = unsafe_load(Ptr{Int64}(pointer(segment) + offset * 8))

    @assert bytes & 0b11 == 0

    length = (bytes & 0xff_ff) >> 2
    data_word_count = (bytes >> 32) & 0xff
    ptr_count = (bytes >> 48) & 0xff

    ListTag(length, data_word_count, ptr_count)
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
    unsafe_store!(Ptr{Int64}(pointer(ptr.traverser.segments[pointer_location.segment]) + 8 * ptr.offset), tag_bytes)
end

# Text is a special kind of list
function read_text(ptr::SimpleListPointer)
    @assert ptr.element_size == Byte
    if ptr.length == 0
        ""
    else
        segment = ptr.traverser.segments[ptr.segment]
        # TODO: this likely creates a copy -- is there a way to make this more like reinterpret_cast<...*>?
        unsafe_string(Ptr{UInt8}(pointer(segment) + ptr.offset * 8), ptr.length - 1)
    end
end

function write_text(ptr::ListPointer, text)
    @assert ptr.element_size == Byte
    segment = ptr.traverser.segments[ptr.segment]
    # TODO: this relies on internal text representation... add some safety
    # println("TEXT. segment=", ptr.segment, "; offset=", ptr.offset * 8, "; length=", length(text), "; text=LEFT OUT")
    unsafe_copyto!(Ptr{UInt8}(pointer(segment) + ptr.offset * 8), pointer(text), length(text) + 1)
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
            tag = read_list_tag(ptr.traverser.segments[segment], offset)
            CompositeListPointer(ptr.traverser, segment, offset, tag.length, tag.data_word_count, tag.pointer_count)
        else
            SimpleListPointer{element_type,typeof(ptr.traverser)}(ptr.traverser, segment, offset, element_size, list_size)
        end
    else
        throw("Not a list $(bytes & 0b11) at offset $(ptr.offset) and after $(byte_section_words) word byte section and at $(ptrix) pointer index of segment $(ptr.segment)")
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

    bytes = unsafe_load(Ptr{Int64}(pointer(ptr.traverser.segments[pointer_location.segment]) + position_bytes))
    @assert bytes & 0b11 == 0 "Non-empty pointer type bits at segment $(pointer_location.segment), byte $(position_bytes), $(Int64(bytes))"

    A = Int64(1) # list pointer indicator
    B = ptr.offset - (position_words + 1) # offset, the difference between position and allocated space
    C = Int64(encode_list_element_size(ptr.element_size))
    D = Int64(ptr.length)

    bytes = (D << 35) | (C << 32) | (B << 2) | A

    # println("Writing simple list pointer at segment=", ptr.segment, "; offset=", position_bytes)
    unsafe_store!(Ptr{Int64}(pointer(ptr.traverser.segments[pointer_location.segment]) + position_bytes), bytes)
end

function write_list_pointer(pointer_location::WirePointer, ptr::CompositeListPointer)
    @assert pointer_location.segment == ptr.segment
    position_words = pointer_location.offset
    position_bytes = 8 * position_words

    bytes = unsafe_load(Ptr{Int64}(pointer(ptr.traverser.segments[pointer_location.segment]) + position_bytes))
    @assert bytes & 0b11 == 0 "Non-empty pointer type bits at segment $(pointer_location.segment), byte $(position_bytes)"

    A = Int64(1) # list pointer
    B = ptr.offset - (position_words + 1) # offset, the difference between position and allocated space
    C = Int64(7)
    D = Int64(ptr.length * (ptr.data_word_count + ptr.pointer_count))

    bytes = (D << 35) | (C << 32) | (B << 2) | A

    # println("Writing composite list pointer at pos ", position_bytes, " ", bytes, " ", B, " ", C, " " , D)
    unsafe_store!(Ptr{Int64}(pointer(ptr.traverser.segments[pointer_location.segment]) + position_bytes), bytes)

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
    bytes = unsafe_load(Ptr{Int64}(pointer(ptr.traverser.segments[ptr.segment]) + position_bytes))

    if bytes == 0
        # Null capability
        nothing
    elseif is_capability_pointer(bytes)
        # Bits 2-31 must be 0
        @assert (bytes & 0x_ff_ff_ff_fc) == 0 "Invalid capability pointer: bits 2-31 must be 0"

        # Capability index is in the upper 32 bits
        cap_index = UInt32(bytes >> 32)

        CapabilityPointer(ptr.traverser, ptr.segment, ptr.offset + byte_section_words + ptrix, cap_index)
    else
        throw("Not a capability pointer at segment $(ptr.segment), offset $(ptr.offset + byte_section_words + ptrix)")
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

    unsafe_store!(Ptr{Int64}(pointer(traverser.segments[pointer_location.segment]) + position_bytes), bytes)

    CapabilityPointer(traverser, pointer_location.segment, pointer_location.offset, cap_index)
end
