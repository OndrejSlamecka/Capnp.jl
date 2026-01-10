# Tests for RPC client functionality (FR-010, FR-013, FR-014)
# Client connection, method calls, and capability handling

using Test
using Capnp
using Capnp.RPC

@testset "RPC Client" begin
    @testset "ConnectionState enum" begin
        # Module-scoped enum per constitution
        @test RPC.ConnectionState.CONNECTING isa RPC.ConnectionState.T
        @test RPC.ConnectionState.CONNECTED isa RPC.ConnectionState.T
        @test RPC.ConnectionState.DISCONNECTING isa RPC.ConnectionState.T
        @test RPC.ConnectionState.DISCONNECTED isa RPC.ConnectionState.T
        @test RPC.ConnectionState.FAILED isa RPC.ConnectionState.T
    end

    @testset "Connection construction" begin
        @testset "Mock transport connection" begin
            # Create a mock transport for testing
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)

            @test RPC.state(conn) == RPC.ConnectionState.CONNECTING
            @test !RPC.is_connected(conn)
        end
    end

    @testset "Connection tables" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)

        @testset "Questions table" begin
            # Initially empty
            @test RPC.question_count(conn) == 0

            # Generate question IDs
            qid1 = RPC.next_question_id!(conn)
            qid2 = RPC.next_question_id!(conn)
            @test qid1 != qid2
        end

        @testset "Imports table" begin
            @test RPC.import_count(conn) == 0
        end

        @testset "Exports table" begin
            @test RPC.export_count(conn) == 0
        end
    end

    @testset "Exception types" begin
        @testset "DisconnectedException" begin
            ex = RPC.DisconnectedException("connection lost")
            @test ex.reason == "connection lost"
            @test ex isa Exception
        end

        @testset "ConnectionFailedException" begin
            ex = RPC.ConnectionFailedException("refused")
            @test ex.reason == "refused"
            @test ex isa Exception
        end

        @testset "RemoteException" begin
            ex = RPC.RemoteException("server error", RPC.ExceptionType.FAILED)
            @test ex.reason == "server error"
            @test ex.type == RPC.ExceptionType.FAILED
        end

        @testset "InvalidCapabilityException" begin
            ex = RPC.InvalidCapabilityException("null capability")
            @test ex.reason == "null capability"
        end
    end

    @testset "ExceptionType enum" begin
        @test RPC.ExceptionType.FAILED isa RPC.ExceptionType.T
        @test RPC.ExceptionType.OVERLOADED isa RPC.ExceptionType.T
        @test RPC.ExceptionType.DISCONNECTED isa RPC.ExceptionType.T
        @test RPC.ExceptionType.UNIMPLEMENTED isa RPC.ExceptionType.T
    end

    @testset "LocalCapability" begin
        # A capability exported by us
        impl = "dummy implementation"
        cap = RPC.LocalCapability(UInt64(0x1234), impl)
        @test cap.interface_id == UInt64(0x1234)
        @test cap.impl == impl
        @test cap.ref_count == UInt32(1)

        # Reference counting
        RPC.incref!(cap)
        @test cap.ref_count == UInt32(2)
        RPC.decref!(cap)
        @test cap.ref_count == UInt32(1)
    end

    @testset "RemoteCapability" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)

        # A capability imported from remote
        cap = RPC.RemoteCapability(UInt32(1), UInt64(0x5678), conn)
        @test cap.import_id == UInt32(1)
        @test cap.interface_id == UInt64(0x5678)
        @test cap.ref_count == UInt32(1)
    end

    @testset "PendingQuestion" begin
        promise = RPC.Promise{Any}(question_id=UInt32(1))
        pq = RPC.PendingQuestion(UInt32(1), promise, UInt32[])

        @test pq.question_id == UInt32(1)
        @test pq.promise === promise
        @test isempty(pq.param_caps)
    end

    @testset "PendingAnswer" begin
        pa = RPC.PendingAnswer(UInt32(2), UInt32[], UInt32(0))

        @test pa.answer_id == UInt32(2)
        @test isempty(pa.result_caps)
        @test pa.pipeline_refs == UInt32(0)
    end

    @testset "Connection state machine" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)

        # Initial state
        @test RPC.state(conn) == RPC.ConnectionState.CONNECTING

        # Transition to connected
        RPC.set_connected!(conn)
        @test RPC.state(conn) == RPC.ConnectionState.CONNECTED
        @test RPC.is_connected(conn)

        # Transition to disconnecting
        RPC.set_disconnecting!(conn)
        @test RPC.state(conn) == RPC.ConnectionState.DISCONNECTING

        # Transition to disconnected
        RPC.set_disconnected!(conn)
        @test RPC.state(conn) == RPC.ConnectionState.DISCONNECTED
        @test !RPC.is_connected(conn)
    end

    @testset "Connection failure" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)

        # Fail the connection
        RPC.set_failed!(conn, "test error")
        @test RPC.state(conn) == RPC.ConnectionState.FAILED
        @test !RPC.is_connected(conn)
    end

    @testset "Connection close" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)
        RPC.set_connected!(conn)

        close(conn)
        @test RPC.state(conn) == RPC.ConnectionState.DISCONNECTED
    end
end
