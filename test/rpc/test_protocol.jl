# Tests for RPC Protocol message parsing and building (Level 2)
# T014-T015: parse_resolve() and build_resolve_message() tests

using Test
using Capnp
using Capnp.RPC

@testset "RPC Protocol Level 2" begin
    @testset "ResolveType enum" begin
        # Module-scoped enum per constitution
        @test RPC.ResolveType.CAP isa RPC.ResolveType.T
        @test RPC.ResolveType.EXCEPTION isa RPC.ResolveType.T

        # Values are distinct
        @test RPC.ResolveType.CAP != RPC.ResolveType.EXCEPTION
    end

    @testset "CapDescriptorType enum" begin
        @test RPC.CapDescriptorType.NONE isa RPC.CapDescriptorType.T
        @test RPC.CapDescriptorType.SENDER_HOSTED isa RPC.CapDescriptorType.T
        @test RPC.CapDescriptorType.SENDER_PROMISE isa RPC.CapDescriptorType.T
        @test RPC.CapDescriptorType.RECEIVER_HOSTED isa RPC.CapDescriptorType.T
        @test RPC.CapDescriptorType.RECEIVER_ANSWER isa RPC.CapDescriptorType.T
    end

    @testset "PromisedAnswerOpType enum" begin
        @test RPC.PromisedAnswerOpType.NOOP isa RPC.PromisedAnswerOpType.T
        @test RPC.PromisedAnswerOpType.GET_POINTER_FIELD isa RPC.PromisedAnswerOpType.T
    end

    @testset "ParsedResolve struct" begin
        # Test resolve with capability
        cap_descriptor = RPC.ParsedCapDescriptor(
            RPC.CapDescriptorType.SENDER_HOSTED,
            UInt32(42),  # sender_hosted export ID
            nothing,     # sender_promise
            nothing,     # receiver_hosted
            nothing,      # receiver_answer
        )

        resolve_cap = RPC.ParsedResolve(
            UInt32(1),           # promise_id
            RPC.ResolveType.CAP, # kind
            cap_descriptor,      # cap_descriptor
            nothing,             # exception_reason
            nothing,              # exception_type
        )

        @test resolve_cap.promise_id == UInt32(1)
        @test resolve_cap.kind == RPC.ResolveType.CAP
        @test resolve_cap.cap_descriptor !== nothing
        @test resolve_cap.cap_descriptor.sender_hosted == UInt32(42)

        # Test resolve with exception
        resolve_exception = RPC.ParsedResolve(
            UInt32(2),                 # promise_id
            RPC.ResolveType.EXCEPTION, # kind
            nothing,                   # cap_descriptor
            "capability failed",       # exception_reason
            RPC.ExceptionType.FAILED,   # exception_type
        )

        @test resolve_exception.promise_id == UInt32(2)
        @test resolve_exception.kind == RPC.ResolveType.EXCEPTION
        @test resolve_exception.cap_descriptor === nothing
        @test resolve_exception.exception_reason == "capability failed"
        @test resolve_exception.exception_type == RPC.ExceptionType.FAILED
    end

    @testset "ParsedCapDescriptor struct" begin
        # SENDER_HOSTED
        sender_hosted = RPC.ParsedCapDescriptor(RPC.CapDescriptorType.SENDER_HOSTED, UInt32(10), nothing, nothing, nothing)
        @test sender_hosted.kind == RPC.CapDescriptorType.SENDER_HOSTED
        @test sender_hosted.sender_hosted == UInt32(10)

        # SENDER_PROMISE
        sender_promise = RPC.ParsedCapDescriptor(RPC.CapDescriptorType.SENDER_PROMISE, nothing, UInt32(20), nothing, nothing)
        @test sender_promise.kind == RPC.CapDescriptorType.SENDER_PROMISE
        @test sender_promise.sender_promise == UInt32(20)

        # RECEIVER_HOSTED
        receiver_hosted = RPC.ParsedCapDescriptor(RPC.CapDescriptorType.RECEIVER_HOSTED, nothing, nothing, UInt32(30), nothing)
        @test receiver_hosted.kind == RPC.CapDescriptorType.RECEIVER_HOSTED
        @test receiver_hosted.receiver_hosted == UInt32(30)

        # NONE
        none_cap = RPC.ParsedCapDescriptor(RPC.CapDescriptorType.NONE, nothing, nothing, nothing, nothing)
        @test none_cap.kind == RPC.CapDescriptorType.NONE
    end

    @testset "PromisedAnswerOp struct" begin
        # NOOP operation
        noop = RPC.PromisedAnswerOp(RPC.PromisedAnswerOpType.NOOP, nothing)
        @test noop.kind == RPC.PromisedAnswerOpType.NOOP
        @test noop.get_pointer_field === nothing

        # GET_POINTER_FIELD operation
        get_field = RPC.PromisedAnswerOp(RPC.PromisedAnswerOpType.GET_POINTER_FIELD, UInt16(3))
        @test get_field.kind == RPC.PromisedAnswerOpType.GET_POINTER_FIELD
        @test get_field.get_pointer_field == UInt16(3)
    end

    @testset "ParsedPromisedAnswer struct" begin
        ops = [RPC.PromisedAnswerOp(RPC.PromisedAnswerOpType.GET_POINTER_FIELD, UInt16(0)), RPC.PromisedAnswerOp(RPC.PromisedAnswerOpType.GET_POINTER_FIELD, UInt16(1))]
        promised = RPC.ParsedPromisedAnswer(UInt32(5), ops)

        @test promised.question_id == UInt32(5)
        @test length(promised.transform) == 2
        @test promised.transform[1].get_pointer_field == UInt16(0)
        @test promised.transform[2].get_pointer_field == UInt16(1)
    end

    @testset "build_resolve_message" begin
        # Test building resolve with capability (SENDER_HOSTED)
        # These functions return raw bytes for transmission
        bytes = RPC.build_resolve_message(UInt32(42), RPC.CapDescriptorType.SENDER_HOSTED, UInt32(100))
        @test bytes isa Vector{UInt8}
        @test length(bytes) > 0
    end

    @testset "Bootstrap and Return exchange" begin
        request_bytes = RPC.build_bootstrap_request(UInt32(17))
        request = RPC.parse_rpc_message(Capnp.MessageReader(IOBuffer(request_bytes)))
        @test request.type == RPC.MessageType.BOOTSTRAP
        @test request.bootstrap.question_id == UInt32(17)

        response_bytes = RPC.build_bootstrap_return(UInt32(17), UInt32(23))
        response = RPC.parse_rpc_message(Capnp.MessageReader(IOBuffer(response_bytes)))
        @test response.type == RPC.MessageType.RETURN
        @test response.return_msg.answer_id == UInt32(17)
        @test response.return_msg.kind == RPC.ReturnType.RESULTS
        @test response.return_msg.cap_table[1].kind == RPC.CapDescriptorType.SENDER_HOSTED
        @test response.return_msg.cap_table[1].sender_hosted == UInt32(23)

        exception_bytes = RPC.build_exception_return(UInt32(17), "bootstrap denied", RPC.ExceptionType.FAILED)
        exception_response = RPC.parse_rpc_message(Capnp.MessageReader(IOBuffer(exception_bytes)))
        @test exception_response.return_msg.kind == RPC.ReturnType.EXCEPTION
        @test exception_response.return_msg.exception_reason == "bootstrap denied"
        @test exception_response.return_msg.exception_type == RPC.ExceptionType.FAILED
    end

    @testset "build_resolve_exception" begin
        # Returns raw bytes for transmission
        bytes = RPC.build_resolve_exception(UInt32(42), "Test error", RPC.ExceptionType.FAILED)
        @test bytes isa Vector{UInt8}
        @test length(bytes) > 0
    end

    @testset "build_save_call" begin
        # Test building save call message - returns raw bytes
        bytes = RPC.build_save_call(UInt32(1), UInt32(10))
        @test bytes isa Vector{UInt8}
        @test length(bytes) > 0
    end

    @testset "build_restore_call" begin
        # Test building restore call message - returns raw bytes
        sturdy_ref = RPC.DefaultSturdyRef("test-host", "test-object")
        sturdy_ref_data = RPC.serialize_sturdy_ref(sturdy_ref)
        bytes = RPC.build_restore_call(UInt32(1), UInt32(0), sturdy_ref_data)
        @test bytes isa Vector{UInt8}
        @test length(bytes) > 0
    end
end
