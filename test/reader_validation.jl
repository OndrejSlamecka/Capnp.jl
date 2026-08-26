using Test
using Capnp

@testset "Message reader validation" begin
    @testset "Buffer framing" begin
        @test_throws Capnp.InvalidMessageError Capnp.BufferMessageReader(UInt8[])
        @test_throws Capnp.InvalidMessageError Capnp.BufferMessageReader(zeros(UInt8, 7))

        # One segment declares one word, but only seven data bytes follow.
        truncated = UInt8[0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, zeros(UInt8, 7)...]
        @test_throws Capnp.InvalidMessageError Capnp.BufferMessageReader(truncated)

        # Two segments require a zero padding word in the framing header.
        nonzero_padding = UInt8[0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00]
        @test_throws Capnp.InvalidMessageError Capnp.BufferMessageReader(nonzero_padding)

        too_many_segments = UInt8[0x02, 0x00, 0x00, 0x00, zeros(UInt8, 12)...]
        @test_throws Capnp.InvalidMessageError Capnp.BufferMessageReader(too_many_segments; max_segments = 2)

        io = IOBuffer()
        @test Capnp._write_le_uint32(io, 0x12345678) == 4
        @test take!(io) == UInt8[0x78, 0x56, 0x34, 0x12]
        header = zeros(UInt8, 4)
        @test Capnp._store_le_uint32!(header, 1, 0x89abcdef) == 0x89abcdef
        @test header == UInt8[0xef, 0xcd, 0xab, 0x89]
    end

    @testset "Declared size limits" begin
        message = UInt8[0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, zeros(UInt8, 8)...]
        @test_throws Capnp.InvalidMessageError Capnp.BufferMessageReader(message; max_message_size = 15)
        @test length(Capnp.BufferMessageReader(message; max_message_size = 16).segments[1]) == 8

        @test_throws Capnp.InvalidMessageError Capnp.MessageReader(IOBuffer(message); max_message_size = 15)
        @test length(Capnp.MessageReader(IOBuffer(message); max_message_size = 16).segments[1]) == 8
    end

    @testset "Streaming reader rejects truncated segments" begin
        @test_throws Capnp.InvalidMessageError Capnp.MessageReader(IOBuffer(UInt8[]))
        @test_throws Capnp.InvalidMessageError Capnp.MessageReader(IOBuffer(zeros(UInt8, 7)))

        truncated = UInt8[0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, zeros(UInt8, 7)...]
        @test_throws Capnp.InvalidMessageError Capnp.MessageReader(IOBuffer(truncated))
    end

    @testset "Limit configuration" begin
        valid_empty_message = zeros(UInt8, 8)
        @test_throws ArgumentError Capnp.BufferMessageReader(valid_empty_message; max_message_size = 7)
        @test_throws ArgumentError Capnp.BufferMessageReader(valid_empty_message; max_segments = 0)
        @test_throws ArgumentError Capnp.BufferMessageReader(valid_empty_message; traversal_limit_words = -1)
        @test_throws ArgumentError Capnp.BufferMessageReader(valid_empty_message; nesting_limit = -1)
    end

    @testset "Pointer bounds" begin
        message = UInt8[0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, zeros(UInt8, 8)...]
        reader = Capnp.BufferMessageReader(message)

        outside_segment = Capnp.StructPointer(reader, UInt32(1), UInt32(2), UInt16(1), UInt16(0))
        @test_throws Capnp.InvalidMessageError Capnp.read_bits(outside_segment, 0, UInt64)

        unknown_segment = Capnp.StructPointer(reader, UInt32(2), UInt32(0), UInt16(1), UInt16(0))
        @test_throws Capnp.InvalidMessageError Capnp.read_bits(unknown_segment, 0, UInt64)
    end

    @testset "Signed pointer offsets" begin
        builder = Capnp.AllocMessageBuilder()
        target = Capnp.StructPointer(builder, UInt32(1), UInt32(1), UInt16(0), UInt16(0))
        pointer_location = Capnp.WirePointer(UInt32(1), UInt32(2))
        Capnp.write_struct_pointer(pointer_location, target)

        parent = Capnp.StructPointer(builder, UInt32(1), UInt32(0), UInt16(2), UInt16(1))
        _, segment, offset = Capnp.resolve_pointer(parent, 2, 0)
        @test segment == UInt32(1)
        @test offset == UInt32(1)
    end

    @testset "Pointer extent validation" begin
        reader = Capnp.MessageReader(IOBuffer(zeros(UInt8, 8)))
        root = Capnp.StructPointer(reader, UInt32(1), UInt32(0), UInt16(0), UInt16(1))

        # A one-byte list targeting the word immediately beyond its segment.
        reader.segments = [zeros(UInt8, 8)]
        list_bytes = (Int64(1) << 35) | (Int64(Capnp.Byte) << 32) | Int64(1)
        Capnp._checked_store!(reader.segments, 1, 0, list_bytes)
        @test_throws Capnp.InvalidMessageError Capnp.read_list_pointer(root, 0, 0, Capnp.CapnpUInt8)

        # The wire element width must agree with the requested scalar type.
        reader.segments = [zeros(UInt8, 16)]
        Capnp._checked_store!(reader.segments, 1, 0, list_bytes)
        @test_throws Capnp.InvalidMessageError Capnp.read_list_pointer(root, 0, 0, Capnp.CapnpUInt64)

        # A composite tag cannot describe more element words than the list pointer declares.
        reader.segments = [zeros(UInt8, 24)]
        composite_bytes = (Int64(1) << 35) | (Int64(Capnp.InlineComposite) << 32) | Int64(1)
        tag_bytes = (Int64(1) << 32) | (Int64(2) << 2)
        Capnp._checked_store!(reader.segments, 1, 0, composite_bytes)
        Capnp._checked_store!(reader.segments, 1, 8, tag_bytes)
        @test_throws Capnp.InvalidMessageError Capnp.read_list_pointer(root, 0, 0, Capnp.CapnpStruct)

        # Struct section sizes use the full 16-bit fields and must fit in the segment.
        reader.segments = [zeros(UInt8, 8)]
        Capnp._checked_store!(reader.segments, 1, 0, Int64(256) << 32)
        @test_throws Capnp.InvalidMessageError Capnp.read_struct_pointer(root, 0, 0)

        undersized = Capnp.StructPointer(reader, UInt32(1), UInt32(0), UInt16(0), UInt16(0))
        @test_throws Capnp.InvalidMessageError Capnp.validate_struct_pointer(undersized, 1, 0, "Example")
    end

    @testset "Nesting limits" begin
        # Two nested non-null struct pointers followed by a null pointer.
        segment = zeros(UInt8, 24)
        pointer_with_child = Int64(1) << 48
        Capnp._checked_store!(segment, 0, pointer_with_child)
        Capnp._checked_store!(segment, 8, pointer_with_child)

        shallow_reader = Capnp.MessageReader(IOBuffer(zeros(UInt8, 8)); nesting_limit = 1)
        shallow_reader.segments = [copy(segment)]
        shallow_root = Capnp.StructPointer(shallow_reader, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
        shallow_child = Capnp.read_struct_pointer(shallow_root, 0, 0)
        @test shallow_child.nesting_limit == 0
        @test_throws Capnp.InvalidMessageError Capnp.read_struct_pointer(shallow_child, 0, 0)

        deep_reader = Capnp.MessageReader(IOBuffer(zeros(UInt8, 8)); nesting_limit = 2)
        deep_reader.segments = [copy(segment)]
        deep_root = Capnp.StructPointer(deep_reader, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
        deep_child = Capnp.read_struct_pointer(deep_root, 0, 0)
        deep_grandchild = Capnp.read_struct_pointer(deep_child, 0, 0)
        @test deep_grandchild.nesting_limit == 0
        @test Capnp.read_struct_pointer(deep_grandchild, 0, 0) === nothing

        # A far pointer consumes the same nesting budget as a direct pointer.
        far_segment = zeros(UInt8, 8)
        landing_segment = copy(segment)
        far_pointer = (Int64(1) << 32) | Int64(0b10)
        Capnp._checked_store!(far_segment, 0, far_pointer)
        far_reader = Capnp.MessageReader(IOBuffer(zeros(UInt8, 8)); nesting_limit = 1)
        far_reader.segments = [far_segment, landing_segment]
        far_root = Capnp.StructPointer(far_reader, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
        far_child = Capnp.read_struct_pointer(far_root, 0, 0)
        @test far_child.segment == UInt32(2)
        @test_throws Capnp.InvalidMessageError Capnp.read_struct_pointer(far_child, 0, 0)
    end
end
