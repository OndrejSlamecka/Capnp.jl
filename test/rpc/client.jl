# Tests for RPC client functionality (FR-010, FR-013, FR-014)
# Client connection, method calls, and capability handling

using Test
using Capnp
using Capnp.RPC
using Sockets

struct BootstrapTestClient
    cap::RPC.RemoteCapability
end

mutable struct PartialWriteIO <: IO
    buffer::IOBuffer
    chunk_size::Int
    open::Bool
end

Base.isopen(io::PartialWriteIO) = io.open
Base.close(io::PartialWriteIO) = (io.open = false; nothing)
Base.flush(io::PartialWriteIO) = flush(io.buffer)
function Base.write(io::PartialWriteIO, data::AbstractVector{UInt8})
    count = min(length(data), io.chunk_size)
    return write(io.buffer, @view(data[1:count]))
end
function Base.write(io::PartialWriteIO, data::SubArray{UInt8,1,<:Array})
    count = min(length(data), io.chunk_size)
    return write(io.buffer, @view(data[1:count]))
end

println(stderr, "RUNNING TESTSET: ");
@testset "RPC Client" begin
    println(stderr, "RUNNING TESTSET: ")
    @testset "ConnectionState enum" begin
        # Module-scoped enum per constitution
        @test RPC.ConnectionState.CONNECTING isa RPC.ConnectionState.T
        @test RPC.ConnectionState.CONNECTED isa RPC.ConnectionState.T
        @test RPC.ConnectionState.DISCONNECTING isa RPC.ConnectionState.T
        @test RPC.ConnectionState.DISCONNECTED isa RPC.ConnectionState.T
        @test RPC.ConnectionState.FAILED isa RPC.ConnectionState.T
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "Connection construction" begin
        println(stderr, "RUNNING TESTSET: ")
        @testset "Mock transport connection" begin
            # Create a mock transport for testing
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)

            @test RPC.state(conn) == RPC.ConnectionState.CONNECTING
            @test !RPC.is_connected(conn)
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "IO transport adapter" begin
            stream = PartialWriteIO(IOBuffer(), 3, true)
            transport = RPC.IOTransport(stream)
            bytes = RPC.build_bootstrap_request(UInt32(12))
            RPC.send_raw_message(transport, bytes)
            @test take!(stream.buffer) == bytes

            close(transport)
            close(transport)
            @test !isopen(transport)

            external_stream = IOBuffer()
            external = RPC.IOTransport(external_stream; owns_stream = false)
            close(external)
            @test isopen(external_stream)
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "Outbound framing limits" begin
            message = RPC.build_bootstrap_request(UInt32(1))
            size_limited = RPC.MockTransport(max_message_size = length(message) - 1)
            @test_throws Capnp.InvalidMessageError RPC.send_raw_message(size_limited, message)

            segment_limited = RPC.MockTransport(max_segments = 1)
            two_empty_segments = UInt8[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            @test_throws Capnp.InvalidMessageError RPC.send_raw_message(segment_limited, two_empty_segments)

            with_trailing_byte = [message; 0x00]
            @test_throws Capnp.InvalidMessageError RPC.send_raw_message(RPC.MockTransport(), with_trailing_byte)
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "Connection options" begin
            options = RPC.ConnectionOptions(max_message_size = 1024, max_segments = 8, traversal_limit_words = 256, nesting_limit = 12, inbound_queue_size = 4, outbound_queue_size = 5, max_questions = 6, max_answers = 7, max_exports = 8, max_imports = 9)
            @test options.max_message_size == 1024
            @test options.max_segments == 8
            @test options.traversal_limit_words == 256
            @test options.nesting_limit == 12
            @test options.inbound_queue_size == 4
            @test options.outbound_queue_size == 5
            @test options.max_questions == 6
            @test options.max_answers == 7
            @test options.max_exports == 8
            @test options.max_imports == 9

            mock = RPC.MockTransport(max_message_size = options.max_message_size, max_segments = options.max_segments, traversal_limit_words = options.traversal_limit_words, nesting_limit = options.nesting_limit)
            @test mock.max_message_size == 1024
            @test mock.max_segments == 8
            @test mock.traversal_limit_words == 256
            @test mock.nesting_limit == 12

            @test_throws ArgumentError RPC.ConnectionOptions(max_message_size = 7)
            @test_throws ArgumentError RPC.ConnectionOptions(max_segments = 0)
            @test_throws ArgumentError RPC.ConnectionOptions(traversal_limit_words = -1)
            @test_throws ArgumentError RPC.ConnectionOptions(nesting_limit = -1)
            @test_throws ArgumentError RPC.ConnectionOptions(inbound_queue_size = 0)
            @test_throws ArgumentError RPC.ConnectionOptions(outbound_queue_size = 0)
            @test_throws ArgumentError RPC.ConnectionOptions(max_questions = 0)
            @test_throws ArgumentError RPC.ConnectionOptions(max_answers = 0)
            @test_throws ArgumentError RPC.ConnectionOptions(max_exports = 0)
            @test_throws ArgumentError RPC.ConnectionOptions(max_imports = 0)
            @test_throws ArgumentError RPC.MockTransport(max_message_size = 7)
        end
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "Connection tables" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)

        println(stderr, "RUNNING TESTSET: ")
        @testset "Questions table" begin
            # Initially empty
            @test RPC.question_count(conn) == 0

            # Generate question IDs
            qid1 = RPC.next_question_id!(conn)
            qid2 = RPC.next_question_id!(conn)
            @test qid1 != qid2
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "Imports table" begin
            @test RPC.import_count(conn) == 0
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "Exports table" begin
            @test RPC.export_count(conn) == 0
        end
    end

    @testset "Connection resource limits" begin
        conn = RPC.Connection(RPC.MockTransport(); max_questions = 1, max_answers = 1, max_exports = 1, max_imports = 1)

        question1 = RPC.PendingQuestion(UInt32(1), RPC.Promise{Any}(question_id = UInt32(1)))
        question2 = RPC.PendingQuestion(UInt32(2), RPC.Promise{Any}(question_id = UInt32(2)))
        RPC.add_question!(conn, question1)
        @test RPC.add_question!(conn, question1) === question1
        @test_throws RPC.ResourceLimitError RPC.add_question!(conn, question2)
        RPC.remove_question!(conn, UInt32(1))
        @test RPC.add_question!(conn, question2) === question2

        answer1 = RPC.PendingAnswer(UInt32(1))
        answer2 = RPC.PendingAnswer(UInt32(2))
        RPC.add_answer!(conn, answer1)
        @test RPC.add_answer!(conn, answer1) === answer1
        @test_throws RPC.ResourceLimitError RPC.add_answer!(conn, answer2)
        RPC.remove_answer!(conn, UInt32(1))
        @test RPC.add_answer!(conn, answer2) === answer2

        export1 = RPC.LocalCapability(UInt64(1), "one")
        export2 = RPC.LocalCapability(UInt64(2), "two")
        RPC.add_export!(conn, UInt32(1), export1)
        @test RPC.add_export!(conn, UInt32(1), export2) === export2
        @test_throws RPC.ResourceLimitError RPC.add_export!(conn, UInt32(2), export2)
        RPC.remove_export!(conn, UInt32(1))
        @test RPC.add_export!(conn, UInt32(2), export2) === export2

        import1 = RPC.RemoteCapability(UInt32(1), UInt64(1), conn)
        import2 = RPC.RemoteCapability(UInt32(2), UInt64(2), conn)
        RPC.add_import!(conn, UInt32(1), import1)
        @test RPC.add_import!(conn, UInt32(1), import2) === import2
        @test_throws RPC.ResourceLimitError RPC.add_import!(conn, UInt32(2), import2)
        RPC.remove_import!(conn, UInt32(1))
        @test RPC.add_import!(conn, UInt32(2), import2) === import2

        promised1 = RPC.Promise{Any}()
        promised2 = RPC.Promise{Any}()
        RPC.add_promised_export!(conn, UInt32(1), promised1)
        @test_throws RPC.ResourceLimitError RPC.add_promised_export!(conn, UInt32(2), promised2)
        RPC.remove_promised_export!(conn, UInt32(1))
        RPC.add_promised_export!(conn, UInt32(2), promised2)

        remote1 = RPC.Promise{Any}()
        remote2 = RPC.Promise{Any}()
        RPC.add_remote_promise!(conn, UInt32(1), remote1)
        @test_throws RPC.ResourceLimitError RPC.add_remote_promise!(conn, UInt32(2), remote2)
        RPC.remove_remote_promise!(conn, UInt32(1))
        RPC.add_remote_promise!(conn, UInt32(2), remote2)

        error = RPC.ResourceLimitError(:questions, 1)
        @test occursin("questions", sprint(showerror, error))
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "Exception types" begin
        println(stderr, "RUNNING TESTSET: ")
        @testset "DisconnectedException" begin
            ex = RPC.DisconnectedException("connection lost")
            @test ex.reason == "connection lost"
            @test ex isa Exception
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "ConnectionFailedException" begin
            ex = RPC.ConnectionFailedException("refused")
            @test ex.reason == "refused"
            @test ex isa Exception
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "RemoteException" begin
            ex = RPC.RemoteException("server error", RPC.ExceptionType.FAILED)
            @test ex.reason == "server error"
            @test ex.type == RPC.ExceptionType.FAILED
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "InvalidCapabilityException" begin
            ex = RPC.InvalidCapabilityException("null capability")
            @test ex.reason == "null capability"
        end
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "ExceptionType enum" begin
        @test RPC.ExceptionType.FAILED isa RPC.ExceptionType.T
        @test RPC.ExceptionType.OVERLOADED isa RPC.ExceptionType.T
        @test RPC.ExceptionType.DISCONNECTED isa RPC.ExceptionType.T
        @test RPC.ExceptionType.UNIMPLEMENTED isa RPC.ExceptionType.T
    end

    println(stderr, "RUNNING TESTSET: ")
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

    println(stderr, "RUNNING TESTSET: ")
    @testset "RemoteCapability" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)

        # A capability imported from remote
        cap = RPC.RemoteCapability(UInt32(1), UInt64(0x5678), conn)
        @test cap.import_id == UInt32(1)
        @test cap.interface_id == UInt64(0x5678)
        @test cap.ref_count == UInt32(1)
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "PendingQuestion" begin
        promise = RPC.Promise{Any}(question_id = UInt32(1))
        pq = RPC.PendingQuestion(UInt32(1), promise, UInt32[])

        @test pq.question_id == UInt32(1)
        @test pq.promise === promise
        @test isempty(pq.param_caps)
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "PendingAnswer" begin
        pa = RPC.PendingAnswer(UInt32(2), UInt32[], UInt32(0))

        @test pa.answer_id == UInt32(2)
        @test isempty(pa.result_caps)
        @test pa.pipeline_refs == UInt32(0)
    end

    println(stderr, "RUNNING TESTSET: ")
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

    println(stderr, "RUNNING TESTSET: ")
    @testset "Connection failure" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)

        # Fail the connection
        RPC.set_failed!(conn, "test error")
        @test RPC.state(conn) == RPC.ConnectionState.FAILED
        @test !RPC.is_connected(conn)
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "Connection close" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock)
        RPC.set_connected!(conn)

        close(conn)
        close(conn)
        @test RPC.state(conn) == RPC.ConnectionState.DISCONNECTED
        @test !isopen(mock)
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "Connection close rejects and clears pending state" begin
        mock = RPC.MockTransport()
        conn = RPC.Connection(mock; owns_transport = false)
        RPC.set_connected!(conn)
        promise = RPC.Promise{Any}(question_id = UInt32(4))
        RPC.add_question!(conn, RPC.PendingQuestion(UInt32(4), promise))
        RPC.add_export!(conn, UInt32(1), RPC.LocalCapability(UInt64(1), :impl))
        RPC.add_import!(conn, UInt32(2), RPC.RemoteCapability(UInt32(2), UInt64(2), conn))

        close(conn)
        @test RPC.is_rejected(promise)
        @test RPC.question_count(conn) == 0
        @test RPC.export_count(conn) == 0
        @test RPC.import_count(conn) == 0
        @test isopen(mock)
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "Typed bootstrap exchange" begin
        mock = RPC.MockTransport()
        conn = RPC.connect(mock; owns_transport = false, start_message_loop = false)
        promise = RPC.bootstrap_async(conn, BootstrapTestClient)
        RPC.flush_outbound!(conn)

        @test length(RPC.get_sent_messages(mock)) == 1
        request = RPC.parse_rpc_message(Capnp.MessageReader(IOBuffer(only(RPC.get_sent_messages(mock)))))
        @test request.type == RPC.MessageType.BOOTSTRAP
        @test request.bootstrap.question_id == RPC.question_id(promise)

        response = RPC.build_bootstrap_return(request.bootstrap.question_id, UInt32(9))
        RPC.handle_message!(conn, Capnp.MessageReader(IOBuffer(response)))
        client = fetch(promise)
        @test client isa BootstrapTestClient
        @test client.cap.import_id == UInt32(9)
        @test RPC.get_import(conn, UInt32(9)) === client.cap
        @test RPC.question_count(conn) == 0

        # A duplicate/late Return is ignored and does not create another import.
        RPC.handle_message!(conn, Capnp.MessageReader(IOBuffer(response)))
        @test client.cap.ref_count == UInt32(1)
        @test RPC.import_count(conn) == 1

        close(conn)
        @test isopen(mock)
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "TCP bootstrap end-to-end" begin
        server = RPC.Server(:bootstrap_root)
        RPC.listen(server, "127.0.0.1", 0)
        port = Int(Sockets.getsockname(server.tcp_server)[2])
        server_task = RPC.serve_async(server)
        conn = nothing
        try
            conn = RPC.connect("127.0.0.1", port)
            capability = RPC.bootstrap(conn, RPC.RemoteCapability)
            @test capability.import_id == UInt32(0)
            @test capability.connection === conn
        finally
            conn === nothing || close(conn)
            RPC.shutdown!(server)
            wait(server_task)
        end
    end

    if RPC.supports_unix_sockets()
        println(stderr, "RUNNING TESTSET: ")
        @testset "Unix bootstrap end-to-end" begin
            mktempdir() do directory
                server = RPC.Server(:bootstrap_root)
                socket_path = joinpath(directory, "capnp-rpc.sock")
                RPC.listen(server, socket_path)
                server_task = RPC.serve_async(server)
                conn = nothing
                try
                    conn = RPC.connect(socket_path)
                    capability = RPC.bootstrap(conn, RPC.RemoteCapability)
                    @test capability.import_id == UInt32(0)
                    @test capability.connection === conn
                finally
                    conn === nothing || close(conn)
                    RPC.shutdown!(server)
                    wait(server_task)
                end
            end
        end
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "Level 2: Promise tracking" begin
        println(stderr, "RUNNING TESTSET: ")
        @testset "RemotePromise struct" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            promise = RPC.Promise{Any}(question_id = UInt32(1))

            remote = RPC.RemotePromise(UInt32(10), promise)
            @test remote.import_id == UInt32(10)
            @test remote.local_promise === promise
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "Remote promise tracking" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            promise = RPC.Promise{Any}(question_id = UInt32(1))

            # Add remote promise (takes promise directly, creates RemotePromise internally)
            RPC.add_remote_promise!(conn, UInt32(10), promise)

            # Retrieve it
            retrieved = RPC.get_remote_promise(conn, UInt32(10))
            @test retrieved !== nothing
            @test retrieved.import_id == UInt32(10)
            @test retrieved.local_promise === promise

            # Remove it
            RPC.remove_remote_promise!(conn, UInt32(10))
            @test RPC.get_remote_promise(conn, UInt32(10)) === nothing
        end
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "Level 2: handle_resolve!" begin
        println(stderr, "RUNNING TESTSET: ")
        @testset "Resolve with capability" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            # Create a pending promise and track it
            promise = RPC.Promise{Any}(question_id = UInt32(1))
            RPC.add_remote_promise!(conn, UInt32(5), promise)

            # Create a resolve message with SENDER_HOSTED
            cap_descriptor = RPC.ParsedCapDescriptor(
                RPC.CapDescriptorType.SENDER_HOSTED,
                UInt32(100),  # export_id
                nothing,
                nothing,
                nothing,
            )
            resolve = RPC.ParsedResolve(
                UInt32(5),           # promise_id
                RPC.ResolveType.CAP,
                cap_descriptor,
                nothing,
                nothing,
            )

            # Handle the resolve
            result = RPC.handle_resolve!(conn, resolve)

            # Promise should be resolved
            @test RPC.is_resolved(promise)
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "Resolve with exception" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            # Create a pending promise
            promise = RPC.Promise{Any}(question_id = UInt32(2))
            RPC.add_remote_promise!(conn, UInt32(6), promise)

            # Create a resolve with exception
            resolve = RPC.ParsedResolve(
                UInt32(6),                 # promise_id
                RPC.ResolveType.EXCEPTION,
                nothing,
                "Capability failed",
                RPC.ExceptionType.FAILED,
            )

            # Handle the resolve
            result = RPC.handle_resolve!(conn, resolve)

            # Promise should be rejected
            @test RPC.is_rejected(promise)
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "Resolve unknown promise" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            # Resolve for unknown promise ID
            resolve = RPC.ParsedResolve(UInt32(999), RPC.ResolveType.CAP, RPC.ParsedCapDescriptor(RPC.CapDescriptorType.NONE, nothing, nothing, nothing, nothing), nothing, nothing)

            # Should not throw, just log warning
            result = RPC.handle_resolve!(conn, resolve)
            @test result === nothing
        end
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "Level 2: Save capability" begin
        println(stderr, "RUNNING TESTSET: ")
        @testset "NotPersistentException" begin
            ex = RPC.NotPersistentException("capability does not support save")
            @test ex.reason == "capability does not support save"
            @test ex isa Exception
        end

        println(stderr, "RUNNING TESTSET: ")
        @testset "call_save creates message" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            # call_save should create a pending question
            promise = RPC.call_save(conn, UInt32(1))
            @test promise isa RPC.Promise
            @test RPC.state(promise) == RPC.PromiseState.PENDING

            # A question should have been added
            @test RPC.question_count(conn) >= 1
        end
    end

    println(stderr, "RUNNING TESTSET: ")
    @testset "Level 2: Restore capability" begin
        println(stderr, "RUNNING TESTSET: ")
        @testset "call_restore creates message" begin
            mock = RPC.MockTransport()
            conn = RPC.Connection(mock)
            RPC.set_connected!(conn)

            sturdy_ref = RPC.DefaultSturdyRef("test-host", "test-object")
            restorer_import_id = UInt32(0)  # Bootstrap capability

            # call_restore should create a pending question
            promise = RPC.call_restore(conn, restorer_import_id, sturdy_ref)
            @test promise isa RPC.Promise
            @test RPC.state(promise) == RPC.PromiseState.PENDING

            # A question should have been added
            @test RPC.question_count(conn) >= 1
        end
    end
end

@testset "Disconnection semantics" begin
    # Test that in-flight questions are rejected when connection drops
    mock = RPC.MockTransport()
    conn = RPC.Connection(mock)
    RPC.set_connected!(conn)

    # Add a pending question
    qid = RPC.next_question_id!(conn)
    promise = RPC.Promise{Any}(question_id = qid, connection = conn)
    RPC.add_question!(conn, RPC.PendingQuestion(qid, promise))

    @test RPC.question_count(conn) == 1
    @test promise.state == RPC.PromiseState.PENDING

    # Simulate connection drop (which should trigger _reject_pending_questions!)
    RPC._reject_pending_questions!(conn, RPC.DisconnectedException("transport closed"))

    @test RPC.question_count(conn) == 0
    @test promise.state == RPC.PromiseState.REJECTED
    @test promise.error isa RPC.DisconnectedException
end
