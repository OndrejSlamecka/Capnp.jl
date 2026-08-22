# Persistent Calculator Client Example
# Demonstrates using persistent capabilities with Cap'n Proto RPC in Julia
#
# This example shows:
# 1. Connecting to a calculator server
# 2. Calling save() to get a SturdyRef
# 3. Simulating disconnect and reconnect
# 4. Restoring the calculator from the SturdyRef
#
# Usage:
#   julia --project example/persistent_calculator_client.jl [host] [port]
#
# Prerequisites:
#   Start the persistent calculator server first:
#   julia --project example/persistent_calculator_server.jl

using Capnp
using Capnp.RPC

# Include generated schema code
include("calculator.capnp.jl")

function main()
    # Parse command line arguments
    host = length(ARGS) >= 1 ? ARGS[1] : "127.0.0.1"
    port = length(ARGS) >= 2 ? parse(Int, ARGS[2]) : 55001

    println("Persistent Calculator Client Example")
    println("=====================================")
    println("")

    # Step 1: Connect to the server
    println("Step 1: Connecting to server at $host:$port...")
    conn, calculator = RPC.connect(host, port)
    println("  Connected and got bootstrap calculator capability")
    println("")

    # Step 2: Perform some calculations
    println("Step 2: Performing calculations...")
    # In a full implementation, we would call the actual methods
    println("  (Calculator methods would be called here)")
    println("")

    # Step 3: Save the calculator to get a SturdyRef
    println("Step 3: Saving calculator to get persistent reference...")
    try
        sturdy_ref = RPC.call_save_sync(conn, calculator.import_id)
        println("  Received SturdyRef!")
        println("    Host ID: $(String(copy(sturdy_ref.host_id)))")
        println("    Object ID: $(String(copy(sturdy_ref.object_id)))")

        # Serialize the SturdyRef (as you would for storage)
        serialized = RPC.serialize_sturdy_ref(sturdy_ref)
        println("  Serialized SturdyRef: $(length(serialized)) bytes")
        println("")

        # Step 4: Simulate disconnect
        println("Step 4: Simulating disconnect...")
        # In real usage, you would close the connection here
        # RPC.close!(conn)
        println("  (Connection would be closed here)")
        println("")

        # Step 5: Deserialize and restore (simulating reconnection)
        println("Step 5: Deserializing SturdyRef for later use...")
        restored_ref = RPC.deserialize_sturdy_ref(serialized)
        println("  SturdyRef deserialized successfully")
        println("    Host ID matches: $(restored_ref.host_id == sturdy_ref.host_id)")
        println("    Object ID matches: $(restored_ref.object_id == sturdy_ref.object_id)")
        println("")

        # Step 6: Would restore using call_restore on new connection
        println("Step 6: Restoration (would happen on new connection)...")
        println("  To restore, use: RPC.call_restore_sync(new_conn, sturdy_ref)")
        println("")

    catch e
        if e isa RPC.NotPersistentException
            println("  Error: Calculator does not support persistence")
            println("  Make sure you're using persistent_calculator_server.jl")
        else
            println("  Error during save: $e")
        end
    end

    println("Demo complete!")
    println("")
    println("Summary of persistent capability workflow:")
    println("  1. Get capability from bootstrap or method call")
    println("  2. Call save() to get SturdyRef")
    println("  3. Serialize SturdyRef for storage")
    println("  4. Disconnect (connection can be lost)")
    println("  5. Reconnect to server")
    println("  6. Deserialize SturdyRef")
    println("  7. Call restore() with SturdyRef to get capability back")
end

# Only run main if this file is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
