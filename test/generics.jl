# Tests for generic type support (FR-004)
# Cap'n Proto generics allow parameterized struct types like List(T)

using Test
using Capnp

@testset "Generic Types" begin
    @testset "BindingKind enum" begin
        @test Capnp.BindingKind.UNBOUND isa Capnp.BindingKind.T
        @test Capnp.BindingKind.TYPE isa Capnp.BindingKind.T
    end

    @testset "Binding construction" begin
        # Unbound binding
        unbound = Capnp.unbound_binding()
        @test unbound.kind == Capnp.BindingKind.UNBOUND
        @test unbound.type_id === nothing

        # Type binding
        type_id = UInt64(0x1234567890abcdef)
        bound = Capnp.type_binding(type_id)
        @test bound.kind == Capnp.BindingKind.TYPE
        @test bound.type_id == type_id
    end

    @testset "Scope construction" begin
        scope_id = UInt64(0xdeadbeef)

        # Empty scope
        empty_scope = Capnp.Scope(scope_id)
        @test empty_scope.scope_id == scope_id
        @test isempty(empty_scope.bindings)

        # Scope with bindings
        bindings = [Capnp.unbound_binding(), Capnp.type_binding(UInt64(0x1234))]
        scope = Capnp.Scope(scope_id, bindings)
        @test scope.scope_id == scope_id
        @test length(scope.bindings) == 2
    end

    @testset "Brand construction" begin
        # Empty brand
        empty_brand = Capnp.Brand()
        @test isempty(empty_brand)
        @test isempty(empty_brand.scopes)

        # Brand with scopes
        scope1 = Capnp.Scope(UInt64(0x1111), [Capnp.unbound_binding()])
        scope2 = Capnp.Scope(UInt64(0x2222), [Capnp.type_binding(UInt64(0x3333))])
        brand = Capnp.Brand([scope1, scope2])
        @test !isempty(brand)
        @test length(brand.scopes) == 2
    end

    @testset "TypeParameter" begin
        param = Capnp.TypeParameter("Key", 0)
        @test param.name == "Key"
        @test param.position == 0

        param2 = Capnp.TypeParameter("Value", 1)
        @test param2.name == "Value"
        @test param2.position == 1
    end

    @testset "GenericType" begin
        type_id = UInt64(0xabcdef)

        # Non-generic type
        nongeneric = Capnp.GenericType(type_id)
        @test !Capnp.is_generic(nongeneric)
        @test Capnp.get_parameter_count(nongeneric) == 0
        @test isempty(Capnp.get_parameter_names(nongeneric))

        # Generic type with parameters
        params = [Capnp.TypeParameter("Key", 0), Capnp.TypeParameter("Value", 1)]
        generic = Capnp.GenericType(type_id, params)
        @test Capnp.is_generic(generic)
        @test Capnp.get_parameter_count(generic) == 2
        @test Capnp.get_parameter_names(generic) == ["Key", "Value"]
    end

    @testset "Julia code generation helpers" begin
        type_id = UInt64(0x123456)

        @testset "Non-generic type" begin
            nongeneric = Capnp.GenericType(type_id)
            @test Capnp.julia_type_params(nongeneric) == ""
            @test Capnp.julia_type_bounds(nongeneric) == ""
        end

        @testset "Single parameter" begin
            params = [Capnp.TypeParameter("T", 0)]
            generic = Capnp.GenericType(type_id, params)
            @test Capnp.julia_type_params(generic) == "{T}"
            @test Capnp.julia_type_bounds(generic) == " where {T}"
        end

        @testset "Multiple parameters" begin
            params = [Capnp.TypeParameter("Key", 0), Capnp.TypeParameter("Value", 1)]
            generic = Capnp.GenericType(type_id, params)
            @test Capnp.julia_type_params(generic) == "{Key, Value}"
            @test Capnp.julia_type_bounds(generic) == " where {Key, Value}"
        end
    end
end
