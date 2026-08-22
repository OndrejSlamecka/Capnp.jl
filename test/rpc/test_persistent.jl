# Tests for RPC Persistent Capability Types (Level 2)
# T028-T029, T058: SturdyRef, SaveParams, SaveResults, custom SturdyRef format

using Test
using Capnp
using Capnp.RPC

@testset "RPC Persistent Capabilities" begin
    @testset "DefaultSturdyRef" begin
        @testset "Construction from bytes" begin
            host_id = Vector{UInt8}("test-host")
            object_id = Vector{UInt8}("test-object-123")

            ref = RPC.DefaultSturdyRef(host_id, object_id)

            @test ref.host_id == host_id
            @test ref.object_id == object_id
        end

        @testset "Construction from strings" begin
            ref = RPC.DefaultSturdyRef("my-host", "my-object")

            @test String(copy(ref.host_id)) == "my-host"
            @test String(copy(ref.object_id)) == "my-object"
        end

        @testset "Serialization round-trip" begin
            ref = RPC.DefaultSturdyRef("localhost:5000", "capability-42")

            # Serialize
            serialized = RPC.serialize_sturdy_ref(ref)
            @test serialized isa Vector{UInt8}
            @test length(serialized) > 0

            # Deserialize
            deserialized = RPC.deserialize_sturdy_ref(serialized)
            @test deserialized isa RPC.DefaultSturdyRef
            @test deserialized.host_id == ref.host_id
            @test deserialized.object_id == ref.object_id
        end

        @testset "Serialization format" begin
            # Format: [host_id_len:4][host_id][object_id_len:4][object_id]
            ref = RPC.DefaultSturdyRef("ABC", "XYZ")
            serialized = RPC.serialize_sturdy_ref(ref)

            # Should be: 4 bytes (3) + 3 bytes + 4 bytes (3) + 3 bytes = 14 bytes
            @test length(serialized) == 14

            # Parse manually to verify format
            io = IOBuffer(serialized)
            host_len = read(io, UInt32)
            @test host_len == 3
            host_data = read(io, 3)
            @test String(host_data) == "ABC"

            obj_len = read(io, UInt32)
            @test obj_len == 3
            obj_data = read(io, 3)
            @test String(obj_data) == "XYZ"
        end

        @testset "Empty values" begin
            ref = RPC.DefaultSturdyRef("", "")
            serialized = RPC.serialize_sturdy_ref(ref)
            deserialized = RPC.deserialize_sturdy_ref(serialized)

            @test isempty(deserialized.host_id)
            @test isempty(deserialized.object_id)
        end

        @testset "Large values" begin
            large_host = repeat("H", 1000)
            large_object = repeat("O", 2000)
            ref = RPC.DefaultSturdyRef(large_host, large_object)

            serialized = RPC.serialize_sturdy_ref(ref)
            deserialized = RPC.deserialize_sturdy_ref(serialized)

            @test String(copy(deserialized.host_id)) == large_host
            @test String(copy(deserialized.object_id)) == large_object
        end
    end

    @testset "DefaultOwner" begin
        @testset "Default construction" begin
            owner = RPC.DefaultOwner()
            @test owner.display_name == ""
        end

        @testset "Construction with name" begin
            owner = RPC.DefaultOwner("alice")
            @test owner.display_name == "alice"
        end
    end

    @testset "SaveParams" begin
        @testset "Default construction" begin
            params = RPC.SaveParams()
            @test params.seal_for === nothing
        end

        @testset "With owner" begin
            owner = RPC.DefaultOwner("bob")
            params = RPC.SaveParams(owner)
            @test params.seal_for === owner
            @test params.seal_for.display_name == "bob"
        end

        @testset "Generic type parameter" begin
            params = RPC.SaveParams{RPC.DefaultOwner}(nothing)
            @test params.seal_for === nothing

            owner = RPC.DefaultOwner("typed")
            params_with_owner = RPC.SaveParams{RPC.DefaultOwner}(owner)
            @test params_with_owner.seal_for === owner
        end
    end

    @testset "SaveResults" begin
        @testset "Construction" begin
            ref = RPC.DefaultSturdyRef("host", "obj")
            results = RPC.SaveResults(ref)

            @test results.sturdy_ref === ref
        end

        @testset "Generic type parameter" begin
            ref = RPC.DefaultSturdyRef("host", "obj")
            results = RPC.SaveResults{RPC.DefaultSturdyRef}(ref)

            @test results.sturdy_ref === ref
            @test results isa RPC.SaveResults{RPC.DefaultSturdyRef}
        end
    end

    @testset "Restorer" begin
        @testset "DefaultRestorer construction" begin
            restorer = RPC.DefaultRestorer("my-host")

            @test String(copy(restorer.host_id)) == "my-host"
            @test restorer.registry !== nothing
        end

        @testset "register! and restore" begin
            restorer = RPC.DefaultRestorer("test-server")

            # Register a capability
            object_id = Vector{UInt8}("capability-1")
            capability = "MockCapability"
            owner = RPC.DefaultOwner("user1")

            sturdy_ref = RPC.register!(restorer, object_id, capability, owner)

            @test sturdy_ref isa RPC.DefaultSturdyRef
            @test sturdy_ref.host_id == restorer.host_id
            @test sturdy_ref.object_id == object_id

            # Restore the capability
            restored = RPC.restore(restorer, sturdy_ref)
            @test restored === capability
        end

        @testset "restore not found" begin
            restorer = RPC.DefaultRestorer("test-server")
            unknown_ref = RPC.DefaultSturdyRef("test-server", "unknown")

            @test_throws RPC.RestoreException RPC.restore(restorer, unknown_ref)

            try
                RPC.restore(restorer, unknown_ref)
            catch e
                @test e isa RPC.RestoreException
                @test e.type == :not_found
            end
        end

        @testset "restore wrong host" begin
            restorer = RPC.DefaultRestorer("host-A")
            wrong_host_ref = RPC.DefaultSturdyRef("host-B", "object")

            @test_throws RPC.RestoreException RPC.restore(restorer, wrong_host_ref)
        end

        @testset "revoke!" begin
            restorer = RPC.DefaultRestorer("server")

            # Register and then revoke
            object_id = Vector{UInt8}("temp-cap")
            RPC.register!(restorer, object_id, "TempCapability", RPC.DefaultOwner())

            # Revoke should succeed
            result = RPC.revoke!(restorer, object_id)
            @test result == true

            # Now restore should fail
            ref = RPC.DefaultSturdyRef("server", "temp-cap")
            @test_throws RPC.RestoreException RPC.restore(restorer, ref)

            # Revoke again should return false (not found)
            result2 = RPC.revoke!(restorer, object_id)
            @test result2 == false
        end

        @testset "validate_owner" begin
            restorer = RPC.DefaultRestorer("server")
            object_id = Vector{UInt8}("cap")
            RPC.register!(restorer, object_id, "Cap", RPC.DefaultOwner("alice"))

            # Default implementation allows all owners
            @test RPC.validate_owner(restorer, object_id, RPC.DefaultOwner("alice")) == true
            @test RPC.validate_owner(restorer, object_id, RPC.DefaultOwner("bob")) == true
        end
    end

    @testset "RestoreException" begin
        ex = RPC.RestoreException("not found", :not_found)
        @test ex.reason == "not found"
        @test ex.type == :not_found
        @test ex isa Exception

        # Other types
        ex_unauth = RPC.RestoreException("unauthorized", :unauthorized)
        @test ex_unauth.type == :unauthorized

        ex_expired = RPC.RestoreException("expired", :expired)
        @test ex_expired.type == :expired
    end

    @testset "PersistentCapability trait" begin
        @testset "is_persistent for non-persistent" begin
            regular_cap = "NotPersistent"
            @test RPC.is_persistent(regular_cap) == false
        end

        @testset "can_save for non-persistent" begin
            regular_cap = "NotPersistent"
            @test RPC.can_save(regular_cap, RPC.DefaultOwner()) == false
        end

        @testset "SimplePersistentCapability" begin
            # Wrap a regular capability to make it persistent
            wrapped = "MyCapability"
            persistent = RPC.SimplePersistentCapability(wrapped, "my-cap-id")

            @test RPC.is_persistent(persistent) == true
            @test RPC.can_save(persistent, RPC.DefaultOwner()) == true
            @test persistent.wrapped === wrapped
            @test String(copy(persistent.object_id)) == "my-cap-id"
        end

        @testset "SimplePersistentCapability with default ID" begin
            wrapped = "AnotherCap"
            persistent = RPC.SimplePersistentCapability(wrapped)

            @test RPC.is_persistent(persistent) == true
            @test !isempty(persistent.object_id)
        end

        @testset "generate_sturdy_ref for SimplePersistentCapability" begin
            restorer = RPC.DefaultRestorer("my-server")
            wrapped = "PersistentCap"
            persistent = RPC.SimplePersistentCapability(wrapped, "cap-123")

            sturdy_ref = RPC.generate_sturdy_ref(persistent, RPC.DefaultOwner(), restorer)

            @test sturdy_ref isa RPC.DefaultSturdyRef
            @test sturdy_ref.host_id == restorer.host_id
            @test sturdy_ref.object_id == persistent.object_id

            # Should be able to restore the wrapped capability
            restored = RPC.restore(restorer, sturdy_ref)
            @test restored === wrapped
        end
    end

    @testset "Custom SturdyRef format support" begin
        # Test that the serialization format is extensible
        @testset "Binary data in SturdyRef" begin
            # SturdyRef can contain arbitrary binary data
            binary_host = UInt8[0x00, 0x01, 0x02, 0xFF, 0xFE]
            binary_object = UInt8[0xDE, 0xAD, 0xBE, 0xEF]

            ref = RPC.DefaultSturdyRef(binary_host, binary_object)
            serialized = RPC.serialize_sturdy_ref(ref)
            deserialized = RPC.deserialize_sturdy_ref(serialized)

            @test deserialized.host_id == binary_host
            @test deserialized.object_id == binary_object
        end

        @testset "UUID-style object IDs" begin
            # Common pattern: UUID as object ID
            uuid_str = "550e8400-e29b-41d4-a716-446655440000"
            ref = RPC.DefaultSturdyRef("server", uuid_str)

            serialized = RPC.serialize_sturdy_ref(ref)
            deserialized = RPC.deserialize_sturdy_ref(serialized)

            @test String(copy(deserialized.object_id)) == uuid_str
        end
    end
end
