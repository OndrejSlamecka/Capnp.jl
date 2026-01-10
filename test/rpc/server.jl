# Tests for RPC server functionality (FR-015, FR-016, FR-017)
# Server startup, connection handling, and concurrent clients

using Test
using Capnp
using Capnp.RPC

@testset "RPC Server" begin
    @testset "Server construction" begin
        @testset "Server with bootstrap capability" begin
            # Create a mock implementation
            impl = "mock_implementation"
            server = RPC.Server(impl)

            @test server.bootstrap_impl == impl
            @test !RPC.is_running(server)
        end

        @testset "Server with connection handler" begin
            handler_called = Ref(false)
            impl = "mock_implementation"

            server = RPC.Server(impl) do conn
                handler_called[] = true
                return true  # Accept connection
            end

            @test server.bootstrap_impl == impl
            @test server.connection_handler !== nothing
        end
    end

    @testset "Server state" begin
        impl = "mock"
        server = RPC.Server(impl)

        @test !RPC.is_running(server)

        # Start/stop state transitions
        RPC.set_running!(server, true)
        @test RPC.is_running(server)

        RPC.set_running!(server, false)
        @test !RPC.is_running(server)
    end

    @testset "Client connection tracking" begin
        impl = "mock"
        server = RPC.Server(impl)

        @test RPC.client_count(server) == 0

        # Add mock connections
        mock1 = RPC.MockTransport()
        conn1 = RPC.Connection(mock1)
        RPC.add_client!(server, conn1)
        @test RPC.client_count(server) == 1

        mock2 = RPC.MockTransport()
        conn2 = RPC.Connection(mock2)
        RPC.add_client!(server, conn2)
        @test RPC.client_count(server) == 2

        # Remove connection
        RPC.remove_client!(server, conn1)
        @test RPC.client_count(server) == 1
    end

    @testset "ServerOptions" begin
        options = RPC.ServerOptions(
            max_connections = 100,
            connection_timeout = 30000
        )
        @test options.max_connections == 100
        @test options.connection_timeout == 30000

        # Default options
        default_opts = RPC.ServerOptions()
        @test default_opts.max_connections > 0
    end

    @testset "CallContext" begin
        @testset "CallContext construction" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            ctx = RPC.CallContext(conn, UInt32(1), UInt64(0x1234), UInt16(0))

            @test ctx.connection === conn
            @test ctx.question_id == UInt32(1)
            @test ctx.interface_id == UInt64(0x1234)
            @test ctx.method_id == UInt16(0)
        end

        @testset "CallContext result setting" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            ctx = RPC.CallContext(conn, UInt32(1), UInt64(0x1234), UInt16(0))

            # Set result
            RPC.set_result!(ctx, "test_result")
            @test ctx.result == "test_result"
            @test !ctx.has_exception
        end

        @testset "CallContext exception setting" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            ctx = RPC.CallContext(conn, UInt32(1), UInt64(0x1234), UInt16(0))

            # Set exception
            RPC.set_exception!(ctx, "error message", RPC.ExceptionType.FAILED)
            @test ctx.has_exception
            @test ctx.exception_reason == "error message"
            @test ctx.exception_type == RPC.ExceptionType.FAILED
        end
    end

    @testset "Capability export" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)
        ctx = RPC.CallContext(conn, UInt32(1), UInt64(0x1234), UInt16(0))

        # Export a capability
        impl = "sub_capability_impl"
        export_id = RPC.export_capability(ctx, impl, UInt64(0x5678))

        @test export_id isa UInt32
        @test RPC.export_count(conn) == 1
    end

    @testset "Message dispatching" begin
        @testset "Bootstrap message handling" begin
            impl = "mock_bootstrap"
            server = RPC.Server(impl)

            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)

            # Handle bootstrap - should return root capability
            cap = RPC.handle_bootstrap(server, conn)
            @test cap !== nothing
        end
    end

    @testset "Concurrent client handling" begin
        impl = "mock"
        server = RPC.Server(impl)

        # Simulate adding multiple concurrent clients
        connections = RPC.Connection[]
        for i in 1:10
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.add_client!(server, conn)
            push!(connections, conn)
        end

        @test RPC.client_count(server) == 10

        # Each client should have isolated state
        for (i, conn) in enumerate(connections)
            @test RPC.question_count(conn) == 0
            @test RPC.export_count(conn) == 0
        end
    end

    @testset "100 concurrent connections (SC-008)" begin
        impl = "mock"
        server = RPC.Server(impl; options=RPC.ServerOptions(max_connections=150))

        # Add 100 concurrent clients
        connections = RPC.Connection[]
        for i in 1:100
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.add_client!(server, conn)
            push!(connections, conn)
        end

        @test RPC.client_count(server) == 100

        # Each connection should have independent state via exports
        for (i, conn) in enumerate(connections)
            eid = RPC.next_export_id!(conn)
            cap = RPC.LocalCapability(UInt64(i), "impl_$i")
            RPC.add_export!(conn, eid, cap)
        end

        # Verify each connection has exactly one export with independent state
        for (i, conn) in enumerate(connections)
            @test RPC.export_count(conn) == 1
        end

        # Clean up
        RPC.shutdown!(server)
        @test RPC.client_count(server) == 0
    end

    @testset "Server shutdown" begin
        impl = "mock"
        server = RPC.Server(impl)

        # Add some clients
        for i in 1:3
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)
            RPC.add_client!(server, conn)
        end

        @test RPC.client_count(server) == 3

        # Shutdown should close all connections
        RPC.shutdown!(server)

        @test !RPC.is_running(server)
        @test RPC.client_count(server) == 0
    end

    @testset "Generated server dispatch" begin
        # Include generated schema
        include("../calculator_schema_helper.jl")

        @testset "Dispatch function exists" begin
            # Check that dispatch functions are generated
            @test isdefined(@__MODULE__, :Calculator_dispatch)
            @test isdefined(@__MODULE__, :Calculator_interface_dispatch)
            @test isdefined(@__MODULE__, :Calculator_interface_id)
            @test Calculator_interface_id isa UInt64
        end

        @testset "Interface dispatch structure" begin
            # Test that interface_dispatch returns false for wrong interface ID
            # We can't easily test dispatch without a proper implementation,
            # but we can verify the structure is correct

            # Check interface ID constant exists
            @test Calculator_interface_id != 0

            # Check server abstract type exists
            @test Calculator_Server isa DataType
            @test isabstracttype(Calculator_Server)

            # Check client type exists
            @test Calculator_Client isa DataType
            @test !isabstracttype(Calculator_Client)
        end
    end
end
