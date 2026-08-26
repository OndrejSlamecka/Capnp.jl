# Persistent Calculator Server Example
# Demonstrates implementing a persistent Cap'n Proto RPC capability in Julia
#
# This example shows:
# 1. Creating a calculator that implements PersistentCapability
# 2. Registering the calculator with a restorer
# 3. Handling save() calls from clients
# 4. Restoring capabilities from SturdyRefs
#
# Usage:
#   julia --project example/persistent_calculator_server.jl [port]
#
# The server implements:
# - Calculator interface from calculator.capnp
# - Persistent save/restore functionality

using Capnp
using Capnp.RPC

# Include generated schema code
include("calculator.capnp.jl")

# Implement a Persistent Calculator that can be saved and restored
# The calculator maintains state (accumulator) that persists across connections
mutable struct PersistentCalculator <: RPC.PersistentCapability
    # Calculator state
    accumulator::Float64
    # Unique identifier for this calculator instance
    object_id::Vector{UInt8}

    function PersistentCalculator(accumulator::Float64 = 0.0)
        instance_id = string(Base.objectid(accumulator), "-", time_ns())
        new(accumulator, Vector{UInt8}(instance_id))
    end

    function PersistentCalculator(accumulator::Float64, object_id::Vector{UInt8})
        new(accumulator, object_id)
    end
end

# Implement can_save for authorization (allow all by default)
function RPC.can_save(calc::PersistentCalculator, owner)
    return true
end

# Implement generate_sturdy_ref to create a restorable reference
function RPC.generate_sturdy_ref(calc::PersistentCalculator, owner, restorer::RPC.DefaultRestorer)
    return RPC.register!(restorer, calc.object_id, calc, owner isa RPC.DefaultOwner ? owner : RPC.DefaultOwner())
end

# Implement the Calculator_Server interface
# (This is the generated server base type from calculator.capnp.jl)

# Implement the add method
function Calculator_add(impl::PersistentCalculator, context::RPC.CallContext, params)
    # Add to accumulator and return new value
    impl.accumulator += 10.0  # Simplified: would parse params in full implementation
    RPC.set_result!(context, impl.accumulator)
    return nothing
end

# Implement the subtract method
function Calculator_subtract(impl::PersistentCalculator, context::RPC.CallContext, params)
    impl.accumulator -= 5.0  # Simplified
    RPC.set_result!(context, impl.accumulator)
    return nothing
end

# Implement the multiply method
function Calculator_multiply(impl::PersistentCalculator, context::RPC.CallContext, params)
    impl.accumulator *= 2.0  # Simplified
    RPC.set_result!(context, impl.accumulator)
    return nothing
end

# Implement the divide method
function Calculator_divide(impl::PersistentCalculator, context::RPC.CallContext, params)
    impl.accumulator /= 2.0  # Simplified
    RPC.set_result!(context, impl.accumulator)
    return nothing
end

# Implement the getSubCalculator method - returns a new persistent calculator
function Calculator_getSubCalculator(impl::PersistentCalculator, context::RPC.CallContext, params)
    # Create a new persistent sub-calculator
    sub_calc = PersistentCalculator(impl.accumulator)
    export_id = RPC.export_capability(context, sub_calc, Calculator_interface_id)
    RPC.set_result!(context, export_id)
    return nothing
end

# Factory function to restore a calculator from a SturdyRef
function restore_calculator(object_id::Vector{UInt8}, saved_state::Dict{Vector{UInt8},Float64})
    accumulator = get(saved_state, object_id, 0.0)
    return PersistentCalculator(accumulator, object_id)
end

# Main entry point
function main()
    # Parse command line arguments
    port = length(ARGS) >= 1 ? parse(Int, ARGS[1]) : 55001

    # Create the persistent calculator implementation
    calculator = PersistentCalculator()

    # Create a restorer for handling save/restore
    restorer = RPC.DefaultRestorer("localhost:$port")

    # Create the server with our implementation as the bootstrap capability
    server = RPC.Server(calculator)

    # Configure the restorer for handling save() calls
    RPC.set_restorer!(server, restorer)

    # Register the bootstrap calculator so it can be restored
    sturdy_ref = RPC.register!(restorer, calculator.object_id, calculator, RPC.DefaultOwner())

    # Listen on the specified port
    println("Starting Persistent Calculator server on port $port...")
    println("Bootstrap calculator SturdyRef: host=$(String(copy(sturdy_ref.host_id))), object=$(String(copy(sturdy_ref.object_id)))")
    RPC.listen(server, "127.0.0.1", port)

    # Start serving (this blocks)
    println("Server listening. Press Ctrl+C to stop.")
    println("")
    println("Features demonstrated:")
    println("  - Calculator maintains state (accumulator)")
    println("  - Clients can call save() to get a SturdyRef")
    println("  - SturdyRef can be used to restore the calculator later")
    println("")

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
