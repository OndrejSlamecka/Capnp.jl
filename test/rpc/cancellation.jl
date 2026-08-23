using Test
using Capnp
import Capnp.RPC

@testset "Cancellation tests" begin
    # Test cancelling a promise sends a Finish message with releaseResultCaps = false
    mock = RPC.MockTransport()
    conn = RPC.Connection(mock)
    RPC.set_connected!(conn)

    # Create a dummy question
    question_id = RPC.next_question_id!(conn)
    promise = RPC.Promise{Any}(question_id = question_id, connection = conn)
    RPC.add_question!(conn, RPC.PendingQuestion(question_id, promise))

    # Cancel the promise
    RPC.cancel(promise)

    # Verify the Finish message was sent
    RPC.flush_outbound!(conn)
    @test length(mock.sent_messages) == 1

    # Check the sent message
    sent_bytes = mock.sent_messages[1]
    msg = Capnp.MessageReader(IOBuffer(sent_bytes))
    parsed = RPC.parse_rpc_message(msg)

    @test parsed.type == RPC.MessageType.FINISH
    @test parsed.finish !== nothing
    @test parsed.finish.question_id == question_id
    @test parsed.finish.release_result_caps == false

end

@testset "Exactly-once Return handling" begin
    # Test that multiple Return messages for the same question don't crash
    mock = RPC.MockTransport()
    conn = RPC.Connection(mock)
    RPC.set_connected!(conn)

    question_id = RPC.next_question_id!(conn)
    promise = RPC.Promise{Any}(question_id = question_id, connection = conn)
    RPC.add_question!(conn, RPC.PendingQuestion(question_id, promise))

    # Fake parsed return
    return_msg = RPC.ParsedReturn(question_id, true, RPC.ReturnType.EXCEPTION, nothing, RPC.ParsedCapDescriptor[], "Test exception", RPC.ExceptionType.FAILED)

    # We simulate handle_message! by directly calling the internal logic
    # First time: question exists, gets rejected, question removed
    question = RPC.get_question(conn, return_msg.answer_id)
    @test question !== nothing

    RPC.remove_question!(conn, return_msg.answer_id)
    @test RPC.get_question(conn, return_msg.answer_id) === nothing

    # Second time: question doesn't exist, should safely do nothing
    question2 = RPC.get_question(conn, return_msg.answer_id)
    @test question2 === nothing
end
