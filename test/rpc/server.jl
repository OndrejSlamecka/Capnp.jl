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

        @testset "Function bootstrap with connection handler" begin
            bootstrap = () -> nothing
            handler = _ -> true

            server = RPC.Server(bootstrap; handler = handler)
            @test server.bootstrap_impl === bootstrap
            @test server.connection_handler === handler

            do_block_server = RPC.Server(bootstrap) do _
                true
            end
            @test do_block_server.bootstrap_impl === bootstrap
            @test do_block_server.connection_handler !== nothing
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
        options = RPC.ServerOptions(max_connections = 100, max_message_size = 1024, max_segments = 8, traversal_limit_words = 256, nesting_limit = 12, max_questions = 6, max_answers = 7, max_exports = 8, max_imports = 9)
        @test options.max_connections == 100
        @test options.max_message_size == 1024
        @test options.max_segments == 8
        @test options.traversal_limit_words == 256
        @test options.nesting_limit == 12
        @test options.max_questions == 6
        @test options.max_answers == 7
        @test options.max_exports == 8
        @test options.max_imports == 9

        # Default options
        default_opts = RPC.ServerOptions()
        @test default_opts.max_connections > 0

        @test_throws ArgumentError RPC.ServerOptions(max_connections = 0)
        @test_throws ArgumentError RPC.ServerOptions(max_message_size = 7)
        @test_throws ArgumentError RPC.ServerOptions(max_segments = 0)
        @test_throws ArgumentError RPC.ServerOptions(traversal_limit_words = -1)
        @test_throws ArgumentError RPC.ServerOptions(nesting_limit = -1)
        @test_throws ArgumentError RPC.ServerOptions(inbound_queue_size = 0)
        @test_throws ArgumentError RPC.ServerOptions(outbound_queue_size = 0)
        @test_throws ArgumentError RPC.ServerOptions(max_questions = 0)
        @test_throws ArgumentError RPC.ServerOptions(max_answers = 0)
        @test_throws ArgumentError RPC.ServerOptions(max_exports = 0)
        @test_throws ArgumentError RPC.ServerOptions(max_imports = 0)
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
        for i = 1:10
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
        server = RPC.Server(impl; options = RPC.ServerOptions(max_connections = 150))

        # Add 100 concurrent clients
        connections = RPC.Connection[]
        for i = 1:100
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
        for i = 1:3
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

    @testset "Level 2: Server persistence" begin
        @testset "Restorer configuration" begin
            impl = "mock"
            server = RPC.Server(impl)

            # Initially no restorer
            @test RPC.get_restorer(server) === nothing

            # Set a restorer
            restorer = RPC.DefaultRestorer("my-server")
            RPC.set_restorer!(server, restorer)
            @test RPC.get_restorer(server) === restorer
        end

        @testset "PersistentCapability trait detection" begin
            # Non-persistent capability
            regular = "RegularCapability"
            @test RPC.is_persistent(regular) == false
            @test RPC.can_save(regular, RPC.DefaultOwner()) == false

            # SimplePersistentCapability
            persistent = RPC.SimplePersistentCapability("PersistentCap", "cap-id")
            @test RPC.is_persistent(persistent) == true
            @test RPC.can_save(persistent, RPC.DefaultOwner()) == true
        end

        @testset "is_save_call detection" begin
            # Save method has specific interface and method IDs
            @test isdefined(RPC, :is_save_call)

            # The Persistent interface ID
            @test isdefined(RPC, :PERSISTENT_INTERFACE_ID)
        end

        @testset "ExportEntry with promise flag" begin
            @test isdefined(RPC, :ExportEntry)

            # Test creating a regular ExportEntry (uses default ref_count)
            cap = RPC.LocalCapability(UInt64(0x1234), "impl")
            entry = RPC.ExportEntry(cap)

            @test entry.capability === cap
            @test entry.is_promise == false
            @test entry.ref_count == UInt32(1)

            # Promise export entry
            promise_entry = RPC.promise_export_entry(cap, UInt32(42))
            @test promise_entry.is_promise == true
            @test promise_entry.promise_id == UInt32(42)
        end

        @testset "PromisedExport tracking" begin
            @test isdefined(RPC, :PromisedExport)

            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)

            # Add a promised export (takes promise directly, creates PromisedExport internally)
            promise = RPC.Promise{Any}()
            RPC.add_promised_export!(conn, UInt32(1), promise)

            # Should be able to retrieve it
            promised = RPC.get_promised_export(conn, UInt32(1))
            @test promised !== nothing
            @test promised.export_id == UInt32(1)
            @test promised.promise === promise

            RPC.remove_promised_export!(conn, UInt32(1))
            @test RPC.get_promised_export(conn, UInt32(1)) === nothing
        end

        @testset "handle_save_call! with non-persistent capability" begin
            impl = "mock"
            server = RPC.Server(impl)
            restorer = RPC.DefaultRestorer("server")
            RPC.set_restorer!(server, restorer)

            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            ctx = RPC.CallContext(conn, UInt32(1), UInt64(0x1234), UInt16(0))

            # Call with non-persistent capability
            non_persistent = "RegularCap"
            cap = RPC.LocalCapability(UInt64(0x1234), non_persistent)

            RPC.handle_save_call!(server, conn, ctx, cap, RPC.ParsedCall(UInt32(1), RPC.ParsedMessageTarget(RPC.MessageTargetType.IMPORTED_CAP, UInt32(1)), UInt64(1), UInt16(1), nothing))

            # Should set exception (capability not persistent)
            @test ctx.has_exception == true
        end

        @testset "handle_save_call! without restorer" begin
            impl = "mock"
            server = RPC.Server(impl)
            # No restorer configured

            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            ctx = RPC.CallContext(conn, UInt32(1), UInt64(0x1234), UInt16(0))

            persistent = RPC.SimplePersistentCapability("PersistentCap", "cap-id")
            cap = RPC.LocalCapability(UInt64(0x1234), persistent)

            RPC.handle_save_call!(server, conn, ctx, cap, RPC.ParsedCall(UInt32(1), RPC.ParsedMessageTarget(RPC.MessageTargetType.IMPORTED_CAP, UInt32(1)), UInt64(1), UInt16(1), nothing))

            # Should set exception (no restorer)
            @test ctx.has_exception == true
        end

        @testset "handle_save_call! with persistent capability" begin
            impl = "mock"
            server = RPC.Server(impl)
            restorer = RPC.DefaultRestorer("server")
            RPC.set_restorer!(server, restorer)

            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            ctx = RPC.CallContext(conn, UInt32(1), UInt64(0x1234), UInt16(0))

            persistent = RPC.SimplePersistentCapability("PersistentCap", "cap-id")
            cap = RPC.LocalCapability(UInt64(0x1234), persistent)

            RPC.handle_save_call!(server, conn, ctx, cap, RPC.ParsedCall(UInt32(1), RPC.ParsedMessageTarget(RPC.MessageTargetType.IMPORTED_CAP, UInt32(1)), UInt64(1), UInt16(1), nothing))

            # Should have a result (SturdyRef data)
            @test ctx.has_exception == false || error("Exception: ", ctx.exception_reason)
            @test ctx.result !== nothing
        end

        @testset "handle_restore_call!" begin
            impl = "mock"
            server = RPC.Server(impl)
            restorer = RPC.DefaultRestorer("server")
            RPC.set_restorer!(server, restorer)

            # Register a capability for restoration
            object_id = Vector{UInt8}("known-cap")
            RPC.register!(restorer, object_id, "RestoredCapability", RPC.DefaultOwner())

            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            ctx = RPC.CallContext(conn, UInt32(1), UInt64(0x1234), UInt16(0))

            # Create and serialize a SturdyRef - pass raw bytes to handle_restore_call!
            sturdy_ref = RPC.DefaultSturdyRef("server", "known-cap")
            sturdy_ref_data = RPC.serialize_sturdy_ref(sturdy_ref)

            RPC.handle_restore_call!(server, conn, ctx, sturdy_ref_data)

            # Should have exported a capability
            @test RPC.export_count(conn) >= 1
        end

        @testset "register_persistent!" begin
            impl = "mock"
            server = RPC.Server(impl)
            restorer = RPC.DefaultRestorer("server")
            RPC.set_restorer!(server, restorer)

            # register_persistent! takes object_id and capability directly
            object_id = Vector{UInt8}("my-cap")
            capability = "MySavedCapability"
            sturdy_ref = RPC.register_persistent!(server, object_id, capability, RPC.DefaultOwner())

            @test sturdy_ref isa RPC.DefaultSturdyRef
            @test sturdy_ref.object_id == object_id

            # Should be restorable
            restored = RPC.restore(restorer, sturdy_ref)
            @test restored === capability
        end

        @testset "send_resolve!" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            # Send a resolve message
            RPC.send_resolve!(conn, UInt32(42), UInt32(100))
            RPC.flush_outbound!(conn)

            # Should have sent a message
            sent = RPC.get_sent_messages(mock)
            sent = RPC.get_sent_messages(mock)
            @test length(sent) >= 1
        end

        @testset "send_resolve_exception!" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            # Send a resolve exception message
            RPC.send_resolve_exception!(conn, UInt32(42), "Error", RPC.ExceptionType.FAILED)
            RPC.flush_outbound!(conn)

            # Should have sent a message
            sent = RPC.get_sent_messages(mock)
            sent = RPC.get_sent_messages(mock)
            @test length(sent) >= 1
        end
    end
end
