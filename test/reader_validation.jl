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
end
