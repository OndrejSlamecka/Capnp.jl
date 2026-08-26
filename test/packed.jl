# Tests for packed encoding (FR-003)
# Cap'n Proto packed encoding compresses zero bytes for efficient transmission

using Test
using Capnp

@testset "Packed Encoding" begin
    @testset "PackedInputStream basics" begin
        @testset "All zeros word" begin
            # A word of all zeros: tag 0x00 + count 0x00 (1 zero word)
            packed = UInt8[0x00, 0x00]
            stream = Capnp.PackedInputStream(IOBuffer(packed))
            unpacked = read(stream, 8)
            @test unpacked == zeros(UInt8, 8)
        end

        @testset "All non-zeros word" begin
            # A word with no zeros: 0xff (tag) + 8 literal bytes
            packed = UInt8[0xff, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x00]
            stream = Capnp.PackedInputStream(IOBuffer(packed))
            unpacked = read(stream, 8)
            @test unpacked == UInt8[0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]
        end

        @testset "Mixed pattern" begin
            # Tag byte indicates which bytes are non-zero
            # 0b00010001 = 0x11 means bytes 0 and 4 are non-zero
            packed = UInt8[0x11, 0xab, 0xcd]
            stream = Capnp.PackedInputStream(IOBuffer(packed))
            unpacked = read(stream, 8)
            @test unpacked == UInt8[0xab, 0x00, 0x00, 0x00, 0xcd, 0x00, 0x00, 0x00]
        end

        @testset "Single byte non-zero" begin
            # Only first byte non-zero: tag 0x01
            packed = UInt8[0x01, 0xff]
            stream = Capnp.PackedInputStream(IOBuffer(packed))
            unpacked = read(stream, 8)
            @test unpacked == UInt8[0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        end
    end

    @testset "PackedOutputStream basics" begin
        @testset "Compress all zeros" begin
            unpacked = zeros(UInt8, 8)
            buffer = IOBuffer()
            stream = Capnp.PackedOutputStream(buffer)
            write(stream, unpacked)
            flush(stream)
            packed = take!(buffer)
            @test packed == UInt8[0x00, 0x00]
        end

        @testset "Compress all non-zeros" begin
            unpacked = UInt8[0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]
            buffer = IOBuffer()
            stream = Capnp.PackedOutputStream(buffer)
            write(stream, unpacked)
            flush(stream)
            packed = take!(buffer)
            @test packed == UInt8[0xff, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x00]
        end

        @testset "Compress mixed pattern" begin
            unpacked = UInt8[0xab, 0x00, 0x00, 0x00, 0xcd, 0x00, 0x00, 0x00]
            buffer = IOBuffer()
            stream = Capnp.PackedOutputStream(buffer)
            write(stream, unpacked)
            flush(stream)
            packed = take!(buffer)
            @test packed == UInt8[0x11, 0xab, 0xcd]
        end

        @testset "Compress a byte view" begin
            source = UInt8[0xff, 0xab, 0x00, 0x00, 0x00, 0xcd, 0x00, 0x00, 0x00, 0xff]
            unpacked = @view source[2:9]
            buffer = IOBuffer()
            stream = Capnp.PackedOutputStream(buffer)
            @test write(stream, unpacked) == length(unpacked)
            flush(stream)
            @test take!(buffer) == UInt8[0x11, 0xab, 0xcd]
        end
    end

    @testset "Round-trip pack/unpack" begin
        @testset "All zeros" begin
            original = zeros(UInt8, 8)
            packed = Capnp.pack(original)
            unpacked = Capnp.unpack(packed)
            @test unpacked == original
        end

        @testset "All non-zeros" begin
            original = UInt8[0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]
            packed = Capnp.pack(original)
            unpacked = Capnp.unpack(packed)
            @test unpacked == original
        end

        @testset "Mixed pattern" begin
            original = UInt8[0xab, 0x00, 0x00, 0x00, 0xcd, 0x00, 0x00, 0x00]
            packed = Capnp.pack(original)
            unpacked = Capnp.unpack(packed)
            @test unpacked == original
        end

        @testset "Multiple words" begin
            # 16 bytes = 2 words
            original = UInt8[
                0x01,
                0x00,
                0x00,
                0x00,
                0x00,
                0x00,
                0x00,
                0x00,  # word 1: sparse
                0xff,
                0xfe,
                0xfd,
                0xfc,
                0xfb,
                0xfa,
                0xf9,
                0xf8,   # word 2: dense
            ]
            packed = Capnp.pack(original)
            unpacked = Capnp.unpack(packed)
            @test unpacked == original
        end

        @testset "Random data" begin
            original = rand(UInt8, 64)  # 8 words
            packed = Capnp.pack(original)
            unpacked = Capnp.unpack(packed)
            @test unpacked == original
        end
    end

    @testset "Compression efficiency" begin
        @testset "Zeros compress well" begin
            zeros_data = zeros(UInt8, 64)  # 8 words
            packed = Capnp.pack(zeros_data)
            # Each zero word becomes 2 bytes (tag + count)
            @test length(packed) < length(zeros_data)
        end

        @testset "Dense data minimal overhead" begin
            dense_data = fill(UInt8(0xff), 64)  # 8 words, all non-zero
            packed = Capnp.pack(dense_data)
            # Each dense word becomes 9 bytes (tag + 8 bytes)
            # 8 words * 9 = 72 bytes
            @test length(packed) <= 72
        end
    end
end
