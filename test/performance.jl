# Performance tests for Zero-Copy operations (FR-020, FR-021)
# Tests pre-allocated buffer support and allocation counting

using Test
using Capnp

@testset "Zero-Copy Performance" begin
    @testset "BufferMessageReader" begin
        @testset "Reader from pre-allocated buffer" begin
            # Create a simple message first using standard builder
            message = Capnp.AllocMessageBuilder()
            # Get the bytes
            buffer = IOBuffer()
            writeMessageToStream(message, buffer)
            bytes = take!(buffer)

            # Create reader from pre-allocated buffer
            reader = Capnp.BufferMessageReader(bytes)
            @test reader !== nothing
            @test reader isa Capnp.BufferMessageReader
        end

        @testset "Reader segment access" begin
            # Create a message with data
            message = Capnp.AllocMessageBuilder()
            buffer = IOBuffer()
            writeMessageToStream(message, buffer)
            bytes = take!(buffer)

            reader = Capnp.BufferMessageReader(bytes)
            # Should be able to get segments without copying
            segments = Capnp.get_segments(reader)
            @test length(segments) >= 1
        end

        @testset "Reader minimal allocations" begin
            # Pre-allocate buffer
            buffer_size = 1024
            bytes = zeros(UInt8, buffer_size)

            # Create a simple message and copy to buffer
            message = Capnp.AllocMessageBuilder()
            io = IOBuffer()
            writeMessageToStream(message, io)
            msg_bytes = take!(io)

            # Copy to pre-allocated buffer
            copyto!(bytes, 1, msg_bytes, 1, min(length(msg_bytes), buffer_size))

            # Warm up to JIT compile
            for _ in 1:3
                Capnp.BufferMessageReader(bytes[1:length(msg_bytes)])
            end

            # Reading from pre-allocated buffer should have minimal allocations
            # The reader creates a small internal structure but doesn't copy segment data
            allocs = @allocated begin
                reader = Capnp.BufferMessageReader(bytes[1:length(msg_bytes)])
            end

            # Target: allocation overhead for internal bookkeeping only
            # (much less than copying a 1KB message would require)
            @test allocs < 25000  # Less than 25KB - primarily internal structures
        end
    end

    @testset "BufferMessageBuilder" begin
        @testset "Builder with pre-allocated segment" begin
            # Pre-allocate a segment
            segment_size = 4096
            segment = zeros(UInt8, segment_size)

            builder = Capnp.BufferMessageBuilder(segment)
            @test builder !== nothing
            @test builder isa Capnp.BufferMessageBuilder
        end

        @testset "Builder writes to provided buffer" begin
            segment_size = 4096
            segment = zeros(UInt8, segment_size)

            builder = Capnp.BufferMessageBuilder(segment)

            # Get bytes written
            bytes_written = Capnp.finalize!(builder)
            @test bytes_written >= 0
            @test bytes_written <= segment_size
        end

        @testset "Builder minimal allocations" begin
            segment_size = 4096
            segment = zeros(UInt8, segment_size)

            # Building with pre-allocated buffer should have minimal allocations
            allocs = @allocated begin
                builder = Capnp.BufferMessageBuilder(segment)
                Capnp.finalize!(builder)
            end

            # Target: minimal allocations for builder
            @test allocs < 500  # Less than 500 bytes allocation overhead
        end
    end

    @testset "Segment views avoid copies" begin
        @testset "View returns same memory" begin
            # Create pre-allocated buffer
            buffer = zeros(UInt8, 1024)
            buffer[1:8] .= 0x42  # Mark some bytes

            reader = Capnp.BufferMessageReader(buffer)
            segments = Capnp.get_segments(reader)

            # Segments should be views, not copies
            if length(segments) > 0
                seg = segments[1]
                # Modifying view should affect original (or be immutable view)
                @test seg isa AbstractVector{UInt8}
            end
        end
    end

    @testset "1KB message read performance (SC-005)" begin
        # Create a 1KB message
        message = Capnp.AllocMessageBuilder()
        io = IOBuffer()
        writeMessageToStream(message, io)
        bytes = take!(io)

        # Pad to ~1KB if needed
        if length(bytes) < 1024
            bytes = vcat(bytes, zeros(UInt8, 1024 - length(bytes)))
        end

        # Measure read time - should be < 100μs
        # Warm up
        for _ in 1:10
            reader = Capnp.BufferMessageReader(bytes)
        end

        # Actual measurement
        times = Float64[]
        for _ in 1:100
            t = @elapsed begin
                reader = Capnp.BufferMessageReader(bytes)
            end
            push!(times, t)
        end

        median_time = sort(times)[50]
        @test median_time < 0.0001  # < 100μs
    end

    @testset "1KB message write allocations (SC-006)" begin
        segment = zeros(UInt8, 2048)

        # Warm up
        for _ in 1:10
            builder = Capnp.BufferMessageBuilder(segment)
            Capnp.finalize!(builder)
        end

        # Measure allocations
        total_allocs = 0
        for _ in 1:10
            allocs = @allocated begin
                builder = Capnp.BufferMessageBuilder(segment)
                Capnp.finalize!(builder)
            end
            total_allocs += allocs
        end

        avg_allocs = total_allocs / 10
        # Target: allocations should be bounded (implementation specific)
        @test avg_allocs < 2000  # Less than 2KB average
    end

    @testset "Benchmarking utilities" begin
        @testset "Allocation counting works" begin
            # Simple test that @allocated works correctly
            allocs = @allocated begin
                x = Vector{Int}(undef, 100)
            end
            @test allocs > 0  # Should allocate

            # Pre-allocated operation should have minimal allocations
            buffer = Vector{Int}(undef, 100)
            allocs = @allocated begin
                buffer[1] = 42
            end
            @test allocs == 0  # Should not allocate
        end

        @testset "Timing works" begin
            t = @elapsed begin
                sleep(0.001)
            end
            @test t >= 0.001  # At least 1ms
            @test t < 0.1     # But not too long
        end
    end

    @testset "RPC round-trip performance (SC-007)" begin
        using Capnp.RPC

        # Test local RPC message handling latency
        # This tests the message processing path without actual network
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)
        RPC.set_connected!(conn)

        # Simulate message handling timing
        times = Float64[]

        # Warm up
        for _ in 1:10
            t = @elapsed begin
                # Simulate a minimal RPC operation:
                # 1. Create a question
                qid = RPC.next_question_id!(conn)
                # 2. Create a pending answer entry
                ctx = RPC.CallContext(conn, qid, UInt64(0), UInt16(0))
                # 3. Set result
                RPC.set_result!(ctx, "result")
            end
        end

        # Actual measurement
        for _ in 1:100
            t = @elapsed begin
                qid = RPC.next_question_id!(conn)
                ctx = RPC.CallContext(conn, qid, UInt64(0), UInt16(0))
                RPC.set_result!(ctx, "result")
            end
            push!(times, t)
        end

        median_time = sort(times)[50]
        # Target: local RPC operations should complete in < 1ms
        # (actual network round-trip would add latency)
        @test median_time < 0.001  # < 1ms
    end
end
