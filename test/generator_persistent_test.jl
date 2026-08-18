# Tests for Generator Persistent Interface Detection (T074-T075)
# Tests the code generator extensions for Cap'n Proto RPC Level 2

using Test
using Capnp

# Access generator internals via the Generator module
Generator = Capnp.Generator

@testset "Generator Persistent Interface Extensions" begin
    @testset "PERSISTENT_INTERFACE_ID constant" begin
        # The Persistent interface ID from persistent.capnp
        @test isdefined(Generator, :PERSISTENT_INTERFACE_ID_GEN)
        @test Generator.PERSISTENT_INTERFACE_ID_GEN isa UInt64
        @test Generator.PERSISTENT_INTERFACE_ID_GEN == UInt64(0xc8cb212fcd9f5691)
    end

    @testset "has_persistent_annotation function exists" begin
        @test isdefined(Generator, :has_persistent_annotation)
        @test hasmethod(Generator.has_persistent_annotation, Tuple{Generator.Environment,Generator.Node{Generator.InterfaceNodeProps}})
        @test hasmethod(Generator.has_persistent_annotation, Tuple{Generator.Environment,Generator.Node})
    end

    @testset "extends_persistent function exists" begin
        @test isdefined(Generator, :extends_persistent)
        @test hasmethod(Generator.extends_persistent, Tuple{Generator.Environment,Generator.Node{Generator.InterfaceNodeProps}})
        @test hasmethod(Generator.extends_persistent, Tuple{Generator.Environment,Generator.Node})
    end

    @testset "is_persistent_interface function exists" begin
        @test isdefined(Generator, :is_persistent_interface)
        @test hasmethod(Generator.is_persistent_interface, Tuple{Generator.Environment,Generator.Node{Generator.InterfaceNodeProps}})
        @test hasmethod(Generator.is_persistent_interface, Tuple{Generator.Environment,Generator.Node})
    end

    @testset "generatePersistentMethods function exists" begin
        @test isdefined(Generator, :generatePersistentMethods)
        @test hasmethod(Generator.generatePersistentMethods, Tuple{Generator.Environment,Generator.Node{Generator.InterfaceNodeProps}})
    end

    @testset "Generator types for persistence" begin
        # Verify the generator module has required types
        @test isdefined(Generator, :Environment)
        @test isdefined(Generator, :Node)
        @test isdefined(Generator, :InterfaceNodeProps)
        @test isdefined(Generator, :Annotation)
        @test isdefined(Generator, :Superclass)
    end
end

@testset "Generator RPC Module Export" begin
    # Verify the RPC module exports the PERSISTENT_INTERFACE_ID
    @test isdefined(Capnp.RPC, :PERSISTENT_INTERFACE_ID)
    @test Capnp.RPC.PERSISTENT_INTERFACE_ID isa UInt64

    # Verify persistence-related exports
    @test isdefined(Capnp.RPC, :PERSISTENT_ANNOTATION_ID)
    @test isdefined(Capnp.RPC, :PERSISTENT_SAVE_METHOD_ID)
end

@testset "Generated Persistent Interface Code" begin
    # If we have an example schema with a persistent interface,
    # we could test that the generated code includes save() methods.
    # For now, we just verify the infrastructure is in place.

    @testset "RPC exports for Level 2 persistence" begin
        # Verify all persistence-related exports exist
        @test isdefined(Capnp.RPC, :PersistentCapability)
        @test isdefined(Capnp.RPC, :SimplePersistentCapability)
        @test isdefined(Capnp.RPC, :can_save)
        @test isdefined(Capnp.RPC, :generate_sturdy_ref)
        @test isdefined(Capnp.RPC, :is_persistent)
    end

    @testset "PersistentCapability is abstract" begin
        @test isabstracttype(Capnp.RPC.PersistentCapability)
    end

    @testset "SimplePersistentCapability inherits from PersistentCapability" begin
        @test Capnp.RPC.SimplePersistentCapability <: Capnp.RPC.PersistentCapability
    end
end
