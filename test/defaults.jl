# Tests for default value handling (FR-002)
# Per Cap'n Proto spec, default values are XOR-encoded in the data section
# and null pointers for pointer fields default to empty/null

using Test
using Capnp

@testset "Default Values" begin
    @testset "XOR encoding utilities - integers" begin
        # Test that XOR encoding works correctly for various integer types
        @test Capnp.apply_default_xor(UInt32(0), UInt32(42)) == 42
        @test Capnp.apply_default_xor(UInt32(42), UInt32(42)) == 0
        @test Capnp.apply_default_xor(UInt32(42), UInt32(0)) == 42

        # Different integer sizes
        @test Capnp.apply_default_xor(UInt8(0), UInt8(255)) == 255
        @test Capnp.apply_default_xor(UInt16(0x1234), UInt16(0x5678)) == 0x444c
        @test Capnp.apply_default_xor(UInt64(0), UInt64(0xdeadbeef)) == 0xdeadbeef

        # Signed integers
        @test Capnp.apply_default_xor(Int32(0), Int32(-1)) == -1
        @test Capnp.apply_default_xor(Int64(0), Int64(-9223372036854775808)) == -9223372036854775808
    end

    @testset "XOR encoding utilities - floats" begin
        # Float32
        @test Capnp.apply_default_xor(Float32(0.0), Float32(0.0)) == 0.0
        # Note: XOR on floats is bitwise, so results may not be intuitive
        # This is correct per Cap'n Proto spec

        # Float64
        @test Capnp.apply_default_xor(Float64(0.0), Float64(0.0)) == 0.0
    end

    @testset "XOR encoding utilities - bool" begin
        @test Capnp.apply_default_xor(false, false) == false
        @test Capnp.apply_default_xor(true, false) == true
        @test Capnp.apply_default_xor(false, true) == true
        @test Capnp.apply_default_xor(true, true) == false
    end

    @testset "Encode with default - integers" begin
        # Encoding: value XOR default = wire value
        @test Capnp.encode_with_default(UInt32(42), UInt32(42)) == 0  # Same as default -> 0 on wire
        @test Capnp.encode_with_default(UInt32(0), UInt32(42)) == 42  # Different from default
        @test Capnp.encode_with_default(UInt32(100), UInt32(0)) == 100  # No default -> value as-is
    end

    @testset "Encode with default - bool" begin
        @test Capnp.encode_with_default(false, false) == false
        @test Capnp.encode_with_default(true, true) == false  # Same as default -> false on wire
        @test Capnp.encode_with_default(true, false) == true
        @test Capnp.encode_with_default(false, true) == true
    end

    @testset "Pointer field defaults" begin
        # Null pointer detection
        @test Capnp.is_null_pointer(nothing) == true

        # Default values for null pointers
        @test Capnp.default_text() == ""
        @test Capnp.default_data() == UInt8[]
        @test Capnp.default_list(Int32) == Int32[]
        @test Capnp.default_list(String) == String[]
    end

    @testset "Round-trip with defaults" begin
        # Test that encoding then decoding yields original value
        for default in [UInt32(0), UInt32(42), UInt32(0xffffffff)]
            for value in [UInt32(0), UInt32(1), UInt32(42), UInt32(100)]
                encoded = Capnp.encode_with_default(value, default)
                decoded = Capnp.apply_default_xor(encoded, default)
                @test decoded == value
            end
        end
    end
end
