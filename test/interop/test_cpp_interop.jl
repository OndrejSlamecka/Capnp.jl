# Test C++ client interoperability with Julia server
# This tests T081: SC-004 - C++ client works with Julia calculator server

using Capnp
using Capnp.RPC
using Sockets

# Start server in background
println("Starting Julia Calculator server...")

# Include the calculator schema  
include("../../example/calculator.capnp.jl")

# Implement the Calculator server
struct TestCalculator <: Calculator_Server end

function Calculator_add(::TestCalculator, ctx::RPC.CallContext, params)
    left = Capnp.read_bits(params, 0, Float64)
    right = Capnp.read_bits(params, 8, Float64)
    result = left + right
    RPC.set_result!(ctx, result)
end

function Calculator_subtract(::TestCalculator, ctx::RPC.CallContext, params)
    left = Capnp.read_bits(params, 0, Float64)
    right = Capnp.read_bits(params, 8, Float64)
    result = left - right
    RPC.set_result!(ctx, result)
end

function Calculator_multiply(::TestCalculator, ctx::RPC.CallContext, params)
    left = Capnp.read_bits(params, 0, Float64)
    right = Capnp.read_bits(params, 8, Float64)
    result = left * right
    RPC.set_result!(ctx, result)
end

function Calculator_divide(::TestCalculator, ctx::RPC.CallContext, params)
    left = Capnp.read_bits(params, 0, Float64)
    right = Capnp.read_bits(params, 8, Float64)
    if right == 0.0
        RPC.set_exception!(ctx, "Division by zero", RPC.ExceptionType.FAILED)
    else
        result = left / right
        RPC.set_result!(ctx, result)
    end
end

function Calculator_getSubCalculator(impl::TestCalculator, context::RPC.CallContext, params)
    sub_calc = TestCalculator()
    export_id = RPC.export_capability(context, sub_calc, Calculator_interface_id)
    RPC.set_result!(context, export_id)
    return nothing
end

# Find available port
function find_free_port()
    server = Sockets.listen(0)
    _, port = getsockname(server)
    close(server)
    return port
end

port = find_free_port()
println("Using port: $port")

# Create and start server
calculator = TestCalculator()
server = RPC.Server(calculator)
RPC.listen(server, "127.0.0.1", port)

# Start server in background task
server_task = @async begin
    try
        RPC.serve(server)
    catch e
        if !(e isa InterruptException)
            @error "Server error" exception=e
        end
    end
end

# Give server time to start
sleep(0.5)

println("Server running, testing C++ client...")

# Run C++ client
cpp_client = joinpath(@__DIR__, "cpp_client_test")
if isfile(cpp_client)
    result = run(pipeline(`$cpp_client 127.0.0.1:$port`, stderr = stderr), wait = true)
    println("\nC++ client exit code: ", result.exitcode)
else
    println("C++ client not found at: $cpp_client")
end

# Shutdown server
println("\nShutting down server...")
RPC.shutdown!(server)

println("Test complete!")
