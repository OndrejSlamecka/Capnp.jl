# Integration tests for Cap'n Proto RPC Level 2 Persistent Capabilities
# T031: save() round-trip integration test
# T045: save-disconnect-restore cycle integration test
# T059: full persistent calculator workflow integration test

using Test
using Capnp
using Capnp.RPC

@testset "Persistent Capability Integration Tests" begin

    @testset "T031: save() round-trip" begin
        # This test verifies that a capability can be saved and the SturdyRef
        # can be serialized, stored, and deserialized correctly.

        # Create a persistent capability
        persistent_cap = RPC.SimplePersistentCapability("TestCalculator", "calc-001")

        # Create a restorer
        restorer = RPC.DefaultRestorer("test-server")

        # Register the capability
        object_id = Vector{UInt8}("calc-001")
        sturdy_ref = RPC.register!(restorer, object_id, persistent_cap, RPC.DefaultOwner())

        @test sturdy_ref isa RPC.DefaultSturdyRef
        @test sturdy_ref.host_id == Vector{UInt8}("test-server")
        @test sturdy_ref.object_id == object_id

        # Serialize the SturdyRef (as would be done for storage)
        serialized = RPC.serialize_sturdy_ref(sturdy_ref)
        @test serialized isa Vector{UInt8}
        @test length(serialized) > 0

        # Deserialize the SturdyRef (as would be done on restoration)
        deserialized = RPC.deserialize_sturdy_ref(serialized)
        @test deserialized.host_id == sturdy_ref.host_id
        @test deserialized.object_id == sturdy_ref.object_id

        # Restore the capability using the deserialized SturdyRef
        restored = RPC.restore(restorer, deserialized)
        @test restored === persistent_cap

        @info "T031 PASSED: save() round-trip works correctly"
    end

    @testset "T045: save-disconnect-restore cycle" begin
        # This test simulates a full save-disconnect-restore cycle
        # where a capability is saved, the "connection" is lost,
        # and the capability is restored using the SturdyRef.

        # Setup: Create server-side infrastructure
        restorer = RPC.DefaultRestorer("persistent-server")

        # Create multiple persistent capabilities
        cap1 = RPC.SimplePersistentCapability("Document", "doc-001")
        cap2 = RPC.SimplePersistentCapability("Spreadsheet", "sheet-001")

        # Register capabilities
        ref1 = RPC.register!(restorer, Vector{UInt8}("doc-001"), cap1, RPC.DefaultOwner())
        ref2 = RPC.register!(restorer, Vector{UInt8}("sheet-001"), cap2, RPC.DefaultOwner())

        # Serialize SturdyRefs (simulating client saving them)
        saved_ref1 = RPC.serialize_sturdy_ref(ref1)
        saved_ref2 = RPC.serialize_sturdy_ref(ref2)

        # Simulate "disconnect" by clearing local references
        cap1_local = nothing
        cap2_local = nothing

        # Simulate "reconnect" by deserializing and restoring
        restored_ref1 = RPC.deserialize_sturdy_ref(saved_ref1)
        restored_ref2 = RPC.deserialize_sturdy_ref(saved_ref2)

        restored_cap1 = RPC.restore(restorer, restored_ref1)
        restored_cap2 = RPC.restore(restorer, restored_ref2)

        # Verify restoration
        @test restored_cap1 === cap1
        @test restored_cap2 === cap2
        @test RPC.is_persistent(restored_cap1)
        @test RPC.is_persistent(restored_cap2)

        @info "T045 PASSED: save-disconnect-restore cycle works correctly"
    end

    @testset "T059: full persistent calculator workflow" begin
        # This test simulates a complete workflow:
        # 1. Server creates a persistent calculator
        # 2. Calculator performs operations
        # 3. Calculator is saved (SturdyRef generated)
        # 4. SturdyRef is stored (serialized)
        # 5. Server/connection is "restarted"
        # 6. Calculator is restored from SturdyRef
        # 7. Calculator state is preserved

        # Define a persistent calculator with state
        mutable struct TestPersistentCalculator <: RPC.PersistentCapability
            id::String
            accumulator::Float64
        end

        # Implement persistence traits
        function RPC.can_save(::TestPersistentCalculator, _owner)
            return true
        end

        function RPC.is_persistent(::TestPersistentCalculator)
            return true
        end

        # Calculator operations
        function calc_add!(calc::TestPersistentCalculator, value::Float64)
            calc.accumulator += value
            return calc.accumulator
        end

        # Setup server infrastructure
        restorer = RPC.DefaultRestorer("calc-server")

        # Create initial calculator with state
        calc = TestPersistentCalculator("calc-persistent", 0.0)

        # Perform some operations
        calc_add!(calc, 10.0)
        calc_add!(calc, 20.0)
        calc_add!(calc, 12.0)
        @test calc.accumulator == 42.0

        # Save the calculator
        object_id = Vector{UInt8}(calc.id)
        sturdy_ref = RPC.register!(restorer, object_id, calc, RPC.DefaultOwner())

        # Serialize for "storage"
        saved_data = RPC.serialize_sturdy_ref(sturdy_ref)

        # Simulate server restart - the restorer still has the capability registered
        # (In a real scenario, the restorer would persist its registry)

        # Restore from SturdyRef
        restored_ref = RPC.deserialize_sturdy_ref(saved_data)
        restored_calc = RPC.restore(restorer, restored_ref)

        # Verify state is preserved
        @test restored_calc === calc
        @test restored_calc.accumulator == 42.0

        # Continue operations on restored calculator
        calc_add!(restored_calc, 8.0)
        @test restored_calc.accumulator == 50.0

        @info "T059 PASSED: full persistent calculator workflow works correctly"
    end

    @testset "Persistence error handling" begin
        # Test restoration of non-existent capability
        restorer = RPC.DefaultRestorer("error-test-server")

        nonexistent_ref = RPC.DefaultSturdyRef("error-test-server", "does-not-exist")

        @test_throws RPC.RestoreException RPC.restore(restorer, nonexistent_ref)

        # Test revocation
        cap = RPC.SimplePersistentCapability("RevocableService", "revocable-001")
        ref = RPC.register!(restorer, Vector{UInt8}("revocable-001"), cap, RPC.DefaultOwner())

        # Can restore before revocation
        @test RPC.restore(restorer, ref) === cap

        # Revoke the capability
        RPC.revoke!(restorer, Vector{UInt8}("revocable-001"))

        # Cannot restore after revocation
        @test_throws RPC.RestoreException RPC.restore(restorer, ref)
    end

    @testset "Multiple owner support" begin
        restorer = RPC.DefaultRestorer("multi-owner-server")

        # Register capability for specific owner
        cap = RPC.SimplePersistentCapability("SecureService", "secure-001")
        owner = RPC.DefaultOwner("authorized-user")
        ref = RPC.register!(restorer, Vector{UInt8}("secure-001"), cap, owner)

        # Restore with correct owner
        restored = RPC.restore(restorer, ref, owner)
        @test restored === cap

        # Restore with different owner (DefaultRestorer allows any owner by default)
        other_owner = RPC.DefaultOwner("other-user")
        restored2 = RPC.restore(restorer, ref, other_owner)
        @test restored2 === cap  # DefaultRestorer doesn't enforce owner restrictions
    end
end
