# Julia representation of types used by Capnp. These are tags for types, i.e. not their realization.

@enum ElementSize::UInt16 Empty Bit Byte TwoBytes FourBytes EightBytes Pointer InlineComposite

const noDiscriminant = 0xff_ff::UInt16

abstract type CapnpType end

@enum Inherit inherit
const Binding = Union{Nothing,CapnpType}
struct Scope
    scopeId::UInt64
    scope::Union{Vector{Binding},Inherit}
end
struct Brand
    scopes::Vector{Scope}
end

struct CapnpTypeVoid <: CapnpType end
struct CapnpTypeBool <: CapnpType end
struct CapnpTypeInt8 <: CapnpType end
struct CapnpTypeInt16 <: CapnpType end
struct CapnpTypeInt32 <: CapnpType end
struct CapnpTypeInt64 <: CapnpType end
struct CapnpTypeUInt8 <: CapnpType end
struct CapnpTypeUInt16 <: CapnpType end
struct CapnpTypeUInt32 <: CapnpType end
struct CapnpTypeUInt64 <: CapnpType end
struct CapnpTypeFloat32 <: CapnpType end
struct CapnpTypeFloat64 <: CapnpType end
struct CapnpTypeText <: CapnpType end
struct CapnpTypeData <: CapnpType end
struct CapnpTypeList <: CapnpType
    # TODO maybe elementType could be a parameter of CapnpTypeList?
    elementType::CapnpType
end
struct CapnpTypeEnum <: CapnpType
    typeId::UInt64
    brand::Brand
end
struct CapnpTypeStruct <: CapnpType
    typeId::UInt64
    brand::Brand
end
struct CapnpTypeInterface <: CapnpType
    typeId::UInt64
    brand::Brand
end
struct CapnpTypeAnyPointer <: CapnpType
    # TODO
end

struct UnconstrainedPointer <: CapnpType
    type::Any # capnp.schema.Type_anyPointer_unconstrained_union
end

struct ParameterPointer <: CapnpType
    scopeId::UInt64
    parameterIndex::UInt16
end

struct ImplicitMethodParameterPointer <: CapnpType
    parameterIndex::UInt16
end

# capnp_sizeof returns the number of bytes a capnp type takes.
# Bool variant is intentionally not defined. Bools get separate treatment because capnp fits 8 bools into a byte.

# capnp_sizeof(::CapnpTypeBool) 
capnp_sizeof(::CapnpTypeInt8) = 1
capnp_sizeof(::CapnpTypeInt16) = 2
capnp_sizeof(::CapnpTypeInt32) = 4
capnp_sizeof(::CapnpTypeInt64) = 8
capnp_sizeof(::CapnpTypeUInt8) = 1
capnp_sizeof(::CapnpTypeUInt16) = 2
capnp_sizeof(::CapnpTypeUInt32) = 4
capnp_sizeof(::CapnpTypeUInt64) = 8
capnp_sizeof(::CapnpTypeFloat32) = 4
capnp_sizeof(::CapnpTypeFloat64) = 8

# capnp_type_to_bits_type(::CapnpTypeBool) = Bool see capnp_sizeof
capnp_type_to_bits_type(::CapnpTypeInt8) = UInt8
capnp_type_to_bits_type(::CapnpTypeInt16) = UInt16
capnp_type_to_bits_type(::CapnpTypeInt32) = UInt32
capnp_type_to_bits_type(::CapnpTypeInt64) = UInt64
capnp_type_to_bits_type(::CapnpTypeUInt8) = UInt8
capnp_type_to_bits_type(::CapnpTypeUInt16) = UInt16
capnp_type_to_bits_type(::CapnpTypeUInt32) = UInt32
capnp_type_to_bits_type(::CapnpTypeUInt64) = UInt64
capnp_type_to_bits_type(::CapnpTypeFloat32) = Float32
capnp_type_to_bits_type(::CapnpTypeFloat64) = Float64
capnp_type_to_bits_type(::Any) = nothing

is_capnp_bits(type) = capnp_type_to_bits_type(type) !== nothing
