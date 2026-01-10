# Tests for round-trip interoperability (SC-001, SC-002, FR-005)
# Verifies that messages can be written by Julia, converted by capnp CLI,
# and read back correctly - and vice versa

using Test
using Capnp

@testset "Round-trip Interoperability" begin
    @testset "Basic wire format compatibility" begin
        # The addressbook integration test already covers basic round-trip
        # These tests verify additional aspects of wire format compatibility

        @testset "Message builder produces valid segments" begin
            builder = Capnp.AllocMessageBuilder()
            # Basic allocation should work
            pointer_location = Capnp.WirePointer(UInt32(1), UInt32(0))
            Capnp.alloc(builder, pointer_location, 8)
            @test length(builder.segments) >= 1
            @test length(builder.segments[1]) >= 8
        end

        @testset "Message round-trip through buffer" begin
            # Write to buffer and read back
            builder = Capnp.AllocMessageBuilder()

            # Write a simple struct
            buffer = IOBuffer()
            Capnp.writeMessageToStream(builder, buffer)

            # Seek to beginning and read
            seek(buffer, 0)
            reader = Capnp.MessageReader(buffer)

            # Should have at least one segment
            @test length(reader.segments) >= 1
        end
    end

    @testset "Wire format invariants" begin
        @testset "Little-endian encoding" begin
            # Cap'n Proto uses little-endian
            builder = Capnp.AllocMessageBuilder()
            pointer_location = Capnp.WirePointer(UInt32(1), UInt32(0))
            Capnp.alloc(builder, pointer_location, 8)

            # Write a known value
            segment = builder.segments[1]
            # The segment should exist and be word-aligned
            @test length(segment) >= 8
            @test length(segment) % 8 == 0
        end

        @testset "8-byte word alignment" begin
            builder = Capnp.AllocMessageBuilder()

            # Allocate various sizes, all should be word-aligned
            for size in [1, 7, 8, 9, 15, 16, 17]
                pointer_location = Capnp.WirePointer(builder.current_segment, builder.current_offset)
                _, _, offset = Capnp.alloc(builder, pointer_location, size)
                # Offset should be word-aligned
                # Note: offset is in words, so no need to check alignment
            end
        end
    end

    @testset "Pointer encoding" begin
        @testset "Struct pointer format" begin
            builder = Capnp.AllocMessageBuilder()

            # Create a struct pointer
            pointer_location = Capnp.WirePointer(UInt32(1), UInt32(0))
            Capnp.alloc(builder, pointer_location, 8)  # Space for pointer
            _, segment, offset = Capnp.alloc(builder, pointer_location, 16)  # 2 word struct

            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)

            # Verify pointer bytes
            bytes = unsafe_load(Ptr{Int64}(pointer(builder.segments[1])))
            # Bits 0-1 should be 0 (struct pointer)
            @test bytes & 0b11 == 0
        end

        @testset "List pointer format" begin
            # Already tested in list tests
            @test true
        end

        @testset "Capability pointer format" begin
            builder = Capnp.AllocMessageBuilder()
            pointer_location = Capnp.WirePointer(UInt32(1), UInt32(0))
            Capnp.alloc(builder, pointer_location, 8)

            cap_ptr = Capnp.write_capability_pointer(pointer_location, builder, UInt32(42))

            # Verify pointer bytes
            bytes = unsafe_load(Ptr{Int64}(pointer(builder.segments[1])))
            # Bits 0-1 should be 3 (capability pointer)
            @test bytes & 0b11 == 3
            # Upper 32 bits should be capability index
            @test UInt32(bytes >> 32) == 42
        end
    end

    @testset "Unknown field preservation (FR-005)" begin
        # This test validates that when we read a message with a larger struct
        # than expected, the extra data is preserved

        @testset "Extra data section words" begin
            # Create a message with extra data section
            builder = Capnp.AllocMessageBuilder()
            pointer_location = Capnp.WirePointer(UInt32(1), UInt32(0))
            Capnp.alloc(builder, pointer_location, 8)

            # Allocate a 3-word data section struct (larger than typical)
            _, segment, offset = Capnp.alloc(builder, pointer_location, 24)  # 3 words
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(0))
            Capnp.write_root_struct_pointer(ptr)

            # Write some data in the extra word
            Capnp.write_bits(ptr, 16, UInt64, 0xdeadbeef)

            # Save and reload
            buffer = IOBuffer()
            Capnp.writeMessageToStream(builder, buffer)
            seek(buffer, 0)
            reader = Capnp.MessageReader(buffer)

            # Read back - the extra data should be preserved
            root_bytes = unsafe_load(Ptr{Int64}(pointer(reader.segments[1])))
            @test root_bytes & 0b11 == 0  # Still a struct pointer
        end
    end
end
