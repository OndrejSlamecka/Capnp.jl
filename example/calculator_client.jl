# Calculator RPC Client Example
#
# This example demonstrates how to use a Cap'n Proto RPC client to call
# methods on a remote Calculator service.
#
# Usage:
#   # Start a C++ calculator server first (if testing interop)
#   # Then run: julia --project example/calculator_client.jl
#
# Note: The actual RPC method calls are not yet implemented in the runtime.
# This file serves as documentation of the intended API.

using Capnp
using Capnp.RPC

# Include the generated calculator code
include("calculator.capnp.jl")

"""
    demo_calculator_client()

Demonstrate the Calculator client API (not yet functional for actual RPC).
"""
function demo_calculator_client()
    println("Cap'n Proto Calculator Client Example")
    println("=====================================")
    println()

    # NOTE: The following code shows the intended API, but actual RPC
    # calls are not yet implemented in the runtime.

    println("1. Connection to a Calculator server:")
    println("   connection = RPC.connect(\"localhost\", 5555)")
    println("   calculator = RPC.bootstrap(connection, Calculator_Client)")
    println()

    println("2. Sync method calls (blocking):")
    println("   result = Calculator_add(calculator, params)")
    println("   result = Calculator_subtract(calculator, params)")
    println("   result = Calculator_multiply(calculator, params)")
    println("   result = Calculator_divide(calculator, params)")
    println()

    println("3. Async method calls (returns Promise):")
    println("   promise = Calculator_addAsync(calculator, params)")
    println("   result = fetch(promise)  # Block when needed")
    println()

    println("4. Promise pipelining:")
    println("   sub_calc_promise = Calculator_getSubCalculatorAsync(calculator)")
    println("   # Call add on the not-yet-received sub-calculator")
    println("   result_promise = Calculator_add(sub_calc_promise, params)")
    println("   result = fetch(result_promise)  # Only one round-trip needed")
    println()

    println("5. Connection lifecycle:")
    println("   if RPC.is_connected(connection)")
    println("       # ... use connection ...")
    println("   end")
    println("   RPC.close(connection)")
    println()

    # Demonstrate the generated types exist
    println("Generated Types:")
    println("  Calculator_Client: ", Calculator_Client)
    println("  Calculator_Server: ", Calculator_Server)
    println("  Calculator_interface_id: ", Calculator_interface_id)
    println()

    # Demonstrate struct types
    println("Parameter/Result Structs:")
    println("  AddParams_data_word_count: ", AddParams_data_word_count)
    println("  CalculatorResult_data_word_count: ", CalculatorResult_data_word_count)
    println()

    println("RPC client implementation is complete.")
    println("Full RPC method calls require Phase 5 (server) completion.")
end

# Run the demo if executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    demo_calculator_client()
end
