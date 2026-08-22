# Tests for capability types and capability table

using Test
using Capnp
using Capnp.RPC

@testset "CapabilityPointer" begin
    @testset "Wire format encoding" begin
        # Test is_capability_pointer
        @test Capnp.is_capability_pointer(Int64(0b11)) == true
        @test Capnp.is_capability_pointer(Int64(0b00)) == false
        @test Capnp.is_capability_pointer(Int64(0b01)) == false
        @test Capnp.is_capability_pointer(Int64(0b10)) == false

        # Capability pointer with index 5 in upper 32 bits
        cap_ptr_bytes = Int64(5) << 32 | Int64(0b11)
        @test Capnp.is_capability_pointer(cap_ptr_bytes) == true
    end

    @testset "Read/write capability pointer" begin
        # Create a message builder
        builder = Capnp.AllocMessageBuilder()

        # Allocate space for a pointer
        pointer_location = Capnp.WirePointer(UInt32(1), UInt32(0))
        Capnp.alloc(builder, pointer_location, 8)

        # Write a capability pointer with index 42
        cap_index = UInt32(42)
        cap_ptr = Capnp.write_capability_pointer(pointer_location, builder, cap_index)

        @test cap_ptr.cap_index == 42
        @test cap_ptr.segment == pointer_location.segment
        @test cap_ptr.offset == pointer_location.offset

        # Verify the raw bytes
        segment = builder.segments[pointer_location.segment]
        bytes = unsafe_load(Ptr{Int64}(pointer(segment) + pointer_location.offset * 8))
        @test bytes & 0b11 == 3  # Type 3 pointer
        @test UInt32(bytes >> 32) == cap_index
    end
end

@testset "CapDescriptorKind" begin
    @test CapDescriptorKind.NONE isa CapDescriptorKind.T
    @test CapDescriptorKind.SENDER_HOSTED isa CapDescriptorKind.T
    @test CapDescriptorKind.SENDER_PROMISE isa CapDescriptorKind.T
    @test CapDescriptorKind.RECEIVER_HOSTED isa CapDescriptorKind.T
    @test CapDescriptorKind.RECEIVER_ANSWER isa CapDescriptorKind.T
    @test CapDescriptorKind.THIRD_PARTY isa CapDescriptorKind.T
end

@testset "CapDescriptor" begin
    @testset "Construction" begin
        # Null descriptor
        null_desc = CapDescriptor(CapDescriptorKind.NONE)
        @test null_desc.kind == CapDescriptorKind.NONE
        @test null_desc.sender_hosted_id === nothing

        # Sender-hosted
        hosted_desc = sender_hosted(UInt32(123))
        @test hosted_desc.kind == CapDescriptorKind.SENDER_HOSTED
        @test hosted_desc.sender_hosted_id == 123
        @test hosted_desc.receiver_hosted_id === nothing

        # Sender-promise
        promise_desc = sender_promise(UInt32(456))
        @test promise_desc.kind == CapDescriptorKind.SENDER_PROMISE
        @test promise_desc.sender_promise_id == 456

        # Receiver-hosted
        recv_desc = receiver_hosted(UInt32(789))
        @test recv_desc.kind == CapDescriptorKind.RECEIVER_HOSTED
        @test recv_desc.receiver_hosted_id == 789
    end
end

@testset "CapabilityTable" begin
    @testset "Basic operations" begin
        table = CapabilityTable()

        @test length(table) == 0
        @test isempty(table)

        # Add a sender-hosted capability
        idx1 = add_sender_hosted!(table, UInt32(100))
        @test idx1 == 0  # 0-based index
        @test length(table) == 1
        @test !isempty(table)

        # Add another capability
        idx2 = add_receiver_hosted!(table, UInt32(200))
        @test idx2 == 1  # Second entry
        @test length(table) == 2

        # Add a null capability
        idx3 = add_null!(table)
        @test idx3 == 2
        @test length(table) == 3
    end

    @testset "Get descriptor" begin
        table = CapabilityTable()

        add_sender_hosted!(table, UInt32(100))
        add_receiver_hosted!(table, UInt32(200))
        add_null!(table)

        # Get descriptors
        desc0 = get_descriptor(table, UInt32(0))
        @test desc0.kind == CapDescriptorKind.SENDER_HOSTED
        @test desc0.sender_hosted_id == 100

        desc1 = get_descriptor(table, UInt32(1))
        @test desc1.kind == CapDescriptorKind.RECEIVER_HOSTED
        @test desc1.receiver_hosted_id == 200

        desc2 = get_descriptor(table, UInt32(2))
        @test desc2.kind == CapDescriptorKind.NONE

        # Out of bounds
        @test_throws BoundsError get_descriptor(table, UInt32(3))
    end

    @testset "Clear table" begin
        table = CapabilityTable()

        add_sender_hosted!(table, UInt32(100))
        add_sender_hosted!(table, UInt32(200))
        @test length(table) == 2

        clear!(table)
        @test length(table) == 0
        @test isempty(table)
    end

    @testset "Add arbitrary descriptor" begin
        table = CapabilityTable()

        # Create a custom descriptor
        custom_desc = CapDescriptor(CapDescriptorKind.SENDER_PROMISE, nothing, UInt32(999), nothing)

        idx = add_descriptor!(table, custom_desc)
        @test idx == 0

        retrieved = get_descriptor(table, UInt32(0))
        @test retrieved.kind == CapDescriptorKind.SENDER_PROMISE
        @test retrieved.sender_promise_id == 999
    end
end
