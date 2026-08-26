# Generic type support for Cap'n Proto (FR-004)
#
# Cap'n Proto supports generic/parameterized types like Map(Key, Value).
# The type system uses "Brand" to represent type parameter bindings.
#
# A Brand contains a list of Scopes, each binding type parameters for a
# specific generic struct in the type hierarchy.
#
# See: https://capnproto.org/language.html#generic-types

"""
Module for Brand.Binding kind enum.
"""
module BindingKind
@enum T begin
    UNBOUND     # Type parameter is not bound
    TYPE        # Type parameter is bound to a specific type
end
end

"""
    Binding

Represents a single type parameter binding.
A binding can be unbound (the type parameter is left as a variable)
or bound to a specific type.
"""
struct Binding
    kind::BindingKind.T
    # For TYPE kind: the bound type ID (or other type representation)
    type_id::Union{UInt64,Nothing}

    Binding(kind::BindingKind.T, type_id::Union{UInt64,Nothing} = nothing) = new(kind, type_id)
end

"""
    unbound_binding()

Create an unbound binding (type parameter left as variable).
"""
unbound_binding() = Binding(BindingKind.UNBOUND, nothing)

"""
    type_binding(type_id::UInt64)

Create a type binding for a specific type.
"""
type_binding(type_id::UInt64) = Binding(BindingKind.TYPE, type_id)

"""
    Scope

Represents type parameter bindings for a single generic struct in the type hierarchy.
Each scope is identified by the struct's type ID and contains bindings for all its
type parameters.
"""
struct Scope
    scope_id::UInt64                # Type ID of the generic struct
    bindings::Vector{Binding}       # Bindings for each type parameter

    Scope(scope_id::UInt64, bindings::Vector{Binding} = Binding[]) = new(scope_id, bindings)
end

"""
    Brand

Represents the complete type parameter bindings for a parameterized type.
A brand is a list of scopes, one for each generic struct in the type hierarchy.
"""
struct Brand
    scopes::Vector{Scope}

    Brand(scopes::Vector{Scope} = Scope[]) = new(scopes)
end

"""
    isempty(brand::Brand)

Check if a brand has no scopes (i.e., type is not parameterized or all defaults).
"""
Base.isempty(brand::Brand) = isempty(brand.scopes)

"""
    TypeParameter

Represents a type parameter definition in a generic struct schema.
This is used during code generation to track type parameter names and positions.
"""
struct TypeParameter
    name::String                    # Parameter name (e.g., "Key", "Value")
    position::Int                   # Position in parameter list (0-based)

    TypeParameter(name::String, position::Int) = new(name, position)
end

"""
    GenericType

Represents a generic type with its type parameters.
Used during schema parsing and code generation.
"""
struct GenericType
    type_id::UInt64                         # Type ID of the generic struct
    parameters::Vector{TypeParameter}       # Type parameters defined by this struct

    GenericType(type_id::UInt64, parameters::Vector{TypeParameter} = TypeParameter[]) = new(type_id, parameters)
end

"""
    is_generic(gtype::GenericType)

Check if a type is generic (has type parameters).
"""
is_generic(gtype::GenericType) = !isempty(gtype.parameters)

"""
    get_parameter_count(gtype::GenericType)

Get the number of type parameters for a generic type.
"""
get_parameter_count(gtype::GenericType) = length(gtype.parameters)

"""
    get_parameter_names(gtype::GenericType)

Get the names of type parameters for a generic type.
"""
get_parameter_names(gtype::GenericType) = [p.name for p in gtype.parameters]

# Code generation helpers

"""
    julia_type_params(gtype::GenericType)

Generate Julia type parameter string for a generic type.
E.g., "{Key, Value}" for Map(Key, Value).
"""
function julia_type_params(gtype::GenericType)
    if isempty(gtype.parameters)
        return ""
    end
    names = get_parameter_names(gtype)
    return "{" * join(names, ", ") * "}"
end

"""
    julia_type_bounds(gtype::GenericType)

Generate Julia where clause for type parameters.
E.g., "where {Key, Value}" for Map(Key, Value).
"""
function julia_type_bounds(gtype::GenericType)
    if isempty(gtype.parameters)
        return ""
    end
    names = get_parameter_names(gtype)
    return " where {" * join(names, ", ") * "}"
end

# Export public API
export BindingKind, Binding, Scope, Brand
export unbound_binding, type_binding
export TypeParameter, GenericType
export is_generic, get_parameter_count, get_parameter_names
export julia_type_params, julia_type_bounds
