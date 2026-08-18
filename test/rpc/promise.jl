# Tests for RPC promise infrastructure (FR-012)
# Promise state management and pipelining support

using Test
using Capnp
using Capnp.RPC

@testset "RPC Promise Infrastructure" begin
    @testset "PromiseState enum" begin
        # Module-scoped enum per constitution
        @test RPC.PromiseState.PENDING isa RPC.PromiseState.T
        @test RPC.PromiseState.RESOLVED isa RPC.PromiseState.T
        @test RPC.PromiseState.REJECTED isa RPC.PromiseState.T

        # All states are distinct
        @test RPC.PromiseState.PENDING != RPC.PromiseState.RESOLVED
        @test RPC.PromiseState.RESOLVED != RPC.PromiseState.REJECTED
        @test RPC.PromiseState.PENDING != RPC.PromiseState.REJECTED
    end

    @testset "Promise construction" begin
        # Create a pending promise
        promise = RPC.Promise{Int}()
        @test RPC.state(promise) == RPC.PromiseState.PENDING
        @test !RPC.is_resolved(promise)
        @test !RPC.is_rejected(promise)
    end

    @testset "Promise resolution" begin
        promise = RPC.Promise{Int}()

        # Resolve with a value
        RPC.resolve!(promise, 42)

        @test RPC.state(promise) == RPC.PromiseState.RESOLVED
        @test RPC.is_resolved(promise)
        @test !RPC.is_rejected(promise)
        @test fetch(promise) == 42
    end

    @testset "Promise rejection" begin
        promise = RPC.Promise{Int}()

        # Reject with an error
        RPC.reject!(promise, ErrorException("test error"))

        @test RPC.state(promise) == RPC.PromiseState.REJECTED
        @test !RPC.is_resolved(promise)
        @test RPC.is_rejected(promise)

        # Fetching a rejected promise should throw
        @test_throws ErrorException fetch(promise)
    end

    @testset "Promise double resolution" begin
        promise = RPC.Promise{Int}()
        RPC.resolve!(promise, 42)

        # Second resolution should be ignored or error
        @test_throws RPC.PromiseAlreadySettledException RPC.resolve!(promise, 100)
        @test fetch(promise) == 42  # Original value preserved
    end

    @testset "Promise waiting" begin
        promise = RPC.Promise{Int}()

        # Resolve in background task
        @async begin
            sleep(0.01)
            RPC.resolve!(promise, 123)
        end

        # Wait should block until resolved
        wait(promise)
        @test RPC.is_resolved(promise)
        @test fetch(promise) == 123

        # A level-triggered event prevents a lost wakeup when resolution races
        # with registration of the waiter.
        raced = RPC.Promise{Int}()
        RPC.resolve!(raced, 456)
        @test wait(raced) === nothing
        @test fetch(raced) == 456
    end

    @testset "Promise with question ID" begin
        # Promises can be associated with RPC questions for pipelining
        promise = RPC.Promise{Int}(question_id = UInt32(42))
        @test RPC.question_id(promise) == UInt32(42)
    end

    @testset "Promise pipelining" begin
        @testset "Pipeline operation creation" begin
            promise = RPC.Promise{Int}(question_id = UInt32(1))

            # Create a pipelined call operation
            op = RPC.PipelineOp(RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(0))
            @test op.kind == RPC.PipelineOpKind.GET_POINTER_FIELD
            @test op.pointer_index == UInt16(0)
        end

        @testset "PromisedAnswer construction" begin
            # PromisedAnswer references a pending call's result
            promised = RPC.PromisedAnswer(UInt32(5), [RPC.PipelineOp(RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(0)), RPC.PipelineOp(RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(1))])
            @test promised.question_id == UInt32(5)
            @test length(promised.transform) == 2
        end

        @testset "call_pipelined creates chained promise" begin
            # Create a promise representing a pending RPC call
            parent_promise = RPC.Promise{Any}(question_id = UInt32(10))

            # Create a pipelined call on the pending result
            # This should create a new promise with pipeline operations
            pipelined = RPC.call_pipelined(parent_promise, [RPC.PipelineOp(RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(0))])

            @test pipelined isa RPC.Promise
            @test RPC.state(pipelined) == RPC.PromiseState.PENDING
        end
    end

    @testset "Promise type parameterization" begin
        # Promises are parameterized by result type
        int_promise = RPC.Promise{Int}()
        string_promise = RPC.Promise{String}()

        RPC.resolve!(int_promise, 42)
        RPC.resolve!(string_promise, "hello")

        @test fetch(int_promise) isa Int
        @test fetch(string_promise) isa String
    end
end
