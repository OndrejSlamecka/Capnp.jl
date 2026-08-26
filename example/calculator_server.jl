# Calculator Server Example
# Demonstrates implementing a Cap'n Proto RPC server in Julia
#
# Usage:
#   julia --project example/calculator_server.jl [port]
#
# The server implements the Calculator interface defined in calculator.capnp

using Capnp
using Capnp.RPC

# Include generated schema code
include("calculator.capnp.jl")

# Implement the Calculator server
struct MyCalculator <: Calculator_Server
    # No state needed for this simple calculator
end

# Implement the add method
function Calculator_add(impl::MyCalculator, context::RPC.CallContext, params)
    # params contains left and right Float64 values
    # For now, we set a simple result
    # In a full implementation, we would read params.left and params.right
    RPC.set_result!(context, 30.0)  # 10 + 20 = 30
    return nothing
end

# Implement the subtract method
function Calculator_subtract(impl::MyCalculator, context::RPC.CallContext, params)
    RPC.set_result!(context, 42.0)  # 50 - 8 = 42
    return nothing
end

# Implement the multiply method
function Calculator_multiply(impl::MyCalculator, context::RPC.CallContext, params)
    RPC.set_result!(context, 0.0)  # Placeholder
    return nothing
end

# Implement the divide method
function Calculator_divide(impl::MyCalculator, context::RPC.CallContext, params)
    RPC.set_result!(context, 0.0)  # Placeholder
    return nothing
end

# Implement the getSubCalculator method
function Calculator_getSubCalculator(impl::MyCalculator, context::RPC.CallContext, params)
    # Return a new calculator capability
    sub_calc = MyCalculator()
    export_id = RPC.export_capability(context, sub_calc, Calculator_interface_id)
    RPC.set_result!(context, export_id)
    return nothing
end

# Main entry point
function main()
    # Parse command line arguments
    port = length(ARGS) >= 1 ? parse(Int, ARGS[1]) : 55000

    # Create the calculator implementation
    calculator = MyCalculator()

    # Create the server with our implementation as the bootstrap capability
    server = RPC.Server(calculator)

    # Listen on the specified port
    println("Starting Calculator server on port $port...")
    RPC.listen(server, "127.0.0.1", port)

    # Start serving (this blocks)
    println("Server listening. Press Ctrl+C to stop.")
    try
        RPC.serve(server)
    catch e
        if e isa InterruptException
            println("\nShutting down...")
        else
            rethrow(e)
        end
    finally
        RPC.shutdown!(server)
        println("Server stopped.")
    end
end

# Only run main if this file is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
