# Packed encoding support for Cap'n Proto (FR-003)
#
# Cap'n Proto packed encoding compresses zero bytes for efficient transmission.
# The encoding works on 8-byte words:
#
# 1. Tag byte: Each bit indicates if corresponding byte in word is non-zero
# 2. Non-zero bytes: Only non-zero bytes are stored after the tag
# 3. Zero runs: After a 0x00 tag, a count byte indicates additional zero words
# 4. Literal runs: After a 0xff tag, literal bytes can follow
#
# See: https://capnproto.org/encoding.html#packing

"""
    PackedInputStream

An IO wrapper that unpacks Cap'n Proto packed data on read.
"""
mutable struct PackedInputStream <: IO
    inner::IO
    buffer::Vector{UInt8}  # Unpacked word buffer
    buffer_pos::Int        # Current position in buffer
    buffer_len::Int        # Valid bytes in buffer
    zero_words_left::Int   # Remaining zero words to emit from a 0x00 run
    literal_words_left::Int # Remaining literal words to emit from a 0xff run

    PackedInputStream(io::IO) = new(io, zeros(UInt8, 8), 9, 0, 0, 0)
end

"""
    PackedOutputStream

An IO wrapper that packs data in Cap'n Proto packed format on write.
"""
mutable struct PackedOutputStream <: IO
    inner::IO
    word_buffer::Vector{UInt8}  # Accumulate a word before packing
    word_pos::Int               # Current position in word buffer
    
    # State for runs
    state::Symbol               # :neutral, :zero_run, :literal_run
    run_count::Int              # Number of additional words in the current run
    literal_buffer::Vector{UInt8} # Buffer for literal words in a literal run

    PackedOutputStream(io::IO) = new(io, zeros(UInt8, 8), 1, :neutral, 0, UInt8[])
end

# Implement IO interface for PackedInputStream
Base.isreadable(s::PackedInputStream) = isreadable(s.inner)
Base.iswritable(s::PackedInputStream) = false
Base.eof(s::PackedInputStream) = s.buffer_pos > s.buffer_len && eof(s.inner)

function Base.read(s::PackedInputStream, ::Type{UInt8})
    if s.buffer_pos > s.buffer_len
        # Need to unpack next word
        if eof(s.inner)
            throw(EOFError())
        end
        unpack_word!(s)
    end
    byte = s.buffer[s.buffer_pos]
    s.buffer_pos += 1
    return byte
end

function Base.read(s::PackedInputStream, n::Integer)
    result = Vector{UInt8}(undef, n)
    for i = 1:n
        result[i] = read(s, UInt8)
    end
    return result
end

"""
    unpack_word!(s::PackedInputStream)

Unpack the next word from the packed stream into the buffer.
"""
function unpack_word!(s::PackedInputStream)
    if s.zero_words_left > 0
        fill!(s.buffer, 0x00)
        s.buffer_pos = 1
        s.buffer_len = 8
        s.zero_words_left -= 1
        return
    end
    if s.literal_words_left > 0
        readbytes!(s.inner, s.buffer, 8)
        s.buffer_pos = 1
        s.buffer_len = 8
        s.literal_words_left -= 1
        return
    end

    tag = read(s.inner, UInt8)

    if tag == 0x00
        fill!(s.buffer, 0x00)
        s.buffer_pos = 1
        s.buffer_len = 8
        
        # In Cap'n proto packed encoding, a 0x00 tag is ALWAYS followed by a count byte
        count = read(s.inner, UInt8)
        s.zero_words_left = count
    elseif tag == 0xff
        readbytes!(s.inner, s.buffer, 8)
        s.buffer_pos = 1
        s.buffer_len = 8

        # In Cap'n proto packed encoding, a 0xff tag is ALWAYS followed by a count byte
        count = read(s.inner, UInt8)
        s.literal_words_left = count
    else
        fill!(s.buffer, 0x00)
        for i = 0:7
            if (tag >> i) & 0x01 == 1
                s.buffer[i+1] = read(s.inner, UInt8)
            end
        end
        s.buffer_pos = 1
        s.buffer_len = 8
    end
end

# Implement IO interface for PackedOutputStream
Base.isreadable(s::PackedOutputStream) = false
Base.iswritable(s::PackedOutputStream) = iswritable(s.inner)

function Base.write(s::PackedOutputStream, byte::UInt8)
    s.word_buffer[s.word_pos] = byte
    s.word_pos += 1

    if s.word_pos > 8
        # Word complete, pack and write it
        pack_word!(s)
        s.word_pos = 1
    end

    return 1
end

function _write_bytes(s::PackedOutputStream, bytes::AbstractVector{UInt8})
    for byte in bytes
        write(s, byte)
    end
    return length(bytes)
end

# Use concrete vector families to remain unambiguous with the IO methods in
# every supported Julia release.
Base.write(s::PackedOutputStream, bytes::Vector{UInt8}) = _write_bytes(s, bytes)
Base.write(s::PackedOutputStream, bytes::SubArray{UInt8,1}) = _write_bytes(s, bytes)
Base.write(s::PackedOutputStream, bytes::Base.CodeUnits{UInt8}) = _write_bytes(s, bytes)

"""
    pack_word!(s::PackedOutputStream)

Pack the current word buffer and write to the inner stream.
"""
function pack_word!(s::PackedOutputStream)
    # Build tag byte
    tag = UInt8(0)
    non_zero_bytes = UInt8[]

    for i = 1:8
        if s.word_buffer[i] != 0x00
            tag |= UInt8(1) << (i - 1)
            push!(non_zero_bytes, s.word_buffer[i])
        end
    end

    if s.state == :zero_run
        if tag == 0x00 && s.run_count < 255
            s.run_count += 1
            fill!(s.word_buffer, 0x00)
            return
        else
            # End of zero run
            write(s.inner, UInt8(0x00))
            write(s.inner, UInt8(s.run_count))
            s.state = :neutral
            s.run_count = 0
            # Process current word below
        end
    elseif s.state == :literal_run
        if tag == 0x00 || s.run_count == 255
            # End of literal run
            write(s.inner, UInt8(0xff))
            write(s.inner, s.literal_buffer[1:8])
            write(s.inner, UInt8(s.run_count))
            if s.run_count > 0
                write(s.inner, s.literal_buffer[9:end])
            end
            empty!(s.literal_buffer)
            s.state = :neutral
            s.run_count = 0
            # Process current word below
        else
            s.run_count += 1
            append!(s.literal_buffer, s.word_buffer)
            fill!(s.word_buffer, 0x00)
            return
        end
    end

    # Neutral state processing
    if tag == 0x00
        s.state = :zero_run
        s.run_count = 0
    elseif tag == 0xff
        s.state = :literal_run
        s.run_count = 0
        append!(s.literal_buffer, s.word_buffer)
    else
        # Mixed - write tag + non-zero bytes
        write(s.inner, tag)
        write(s.inner, non_zero_bytes)
    end

    # Clear buffer for next word
    fill!(s.word_buffer, 0x00)
end

"""
    Base.flush(s::PackedOutputStream)

Flush any remaining buffered data. Pads incomplete words with zeros.
"""
function Base.flush(s::PackedOutputStream)
    if s.word_pos > 1
        # Pad remaining bytes with zeros and pack
        for i = s.word_pos:8
            s.word_buffer[i] = 0x00
        end
        pack_word!(s)
        s.word_pos = 1
    end
    
    # Flush any active runs
    if s.state == :zero_run
        write(s.inner, UInt8(0x00))
        write(s.inner, UInt8(s.run_count))
        s.state = :neutral
        s.run_count = 0
    elseif s.state == :literal_run
        write(s.inner, UInt8(0xff))
        write(s.inner, s.literal_buffer[1:8])
        write(s.inner, UInt8(s.run_count))
        if s.run_count > 0
            write(s.inner, s.literal_buffer[9:end])
        end
        empty!(s.literal_buffer)
        s.state = :neutral
        s.run_count = 0
    end
    
    flush(s.inner)
end

Base.close(s::PackedInputStream) = close(s.inner)
Base.close(s::PackedOutputStream) = (flush(s); close(s.inner))

# Convenience functions

"""
    pack(data::AbstractVector{UInt8}) -> Vector{UInt8}

Pack data using Cap'n Proto packed encoding.
"""
function pack(data::AbstractVector{UInt8})
    output = IOBuffer()
    packed = PackedOutputStream(output)
    write(packed, data)
    flush(packed)
    return take!(output)
end

"""
    unpack(data::AbstractVector{UInt8}) -> Vector{UInt8}

Unpack Cap'n Proto packed data.
"""
function unpack(data::AbstractVector{UInt8})
    input = PackedInputStream(IOBuffer(data))
    result = UInt8[]
    while !eof(input)
        push!(result, read(input, UInt8))
    end
    return result
end

# Export public API
export PackedInputStream, PackedOutputStream, pack, unpack
