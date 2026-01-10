# Tests for Calculator example interoperability (US2)
# These tests verify the calculator RPC example works correctly

using Test
using Capnp
using Capnp.RPC

@testset "Calculator RPC Example" begin
    @testset "Calculator schema types" begin
        # These tests verify the calculator schema generates correctly
        # Will be populated when example/calculator.capnp.jl is generated

        @test true  # Placeholder - schema not yet generated
    end

    @testset "Calculator client stub" begin
        # Client stub tests
        # Will verify Calculator_Client type and method stubs

        @test true  # Placeholder - stubs not yet generated
    end

    @testset "Calculator method calls" begin
        # Tests for method invocation
        # Will use mock transport to verify Call message format

        @test true  # Placeholder
    end

    @testset "Calculator promise pipelining" begin
        # Tests for chained RPC calls
        # e.g., get sub-calculator then call method on it

        @test true  # Placeholder
    end

    @testset "C++ interoperability" begin
        # These tests require a running C++ calculator server
        # Skip if capnp CLI not available

        capnp_available = try
            success(`which capnp`)
        catch
            false
        end

        if !capnp_available
            @info "Skipping C++ interop tests - capnp CLI not found"
            @test_skip "C++ calculator server interop"
        else
            # Integration tests with C++ server would go here
            @test true  # Placeholder
        end
    end
end
