# Julia representation of types used by Capnp/given schema. These are used at runtime, see schema_tree.jl for parsed type information.

@enum ElementSize::UInt16 Empty Bit Byte TwoBytes FourBytes EightBytes Pointer InlineComposite

abstract type CapnpType end

abstract type CapnpVoid <: CapnpType end
abstract type CapnpBool <: CapnpType end
abstract type CapnpInt8 <: CapnpType end
abstract type CapnpInt16 <: CapnpType end
abstract type CapnpInt32 <: CapnpType end
abstract type CapnpInt64 <: CapnpType end
abstract type CapnpUInt8 <: CapnpType end
abstract type CapnpUInt16 <: CapnpType end
abstract type CapnpUInt32 <: CapnpType end
abstract type CapnpUInt64 <: CapnpType end
abstract type CapnpFloat32 <: CapnpType end
abstract type CapnpFloat64 <: CapnpType end
# abstract type CapnpText <: CapnpType end
# abstract type CapnpData <: CapnpType end
# abstract type CapnpList{T} <: CapnpType where {T <: CapnpType} end

abstract type CapnpStruct <: CapnpType end

# This supports, for example, "$(CapnpVoid())" == "CapnpVoid",
# although it's a bit naughty to rely on typeof here
Base.show(io::IO, t::CapnpType) = print(io, typeof(t))

capnp_sizeof(::Type{CapnpInt8   }) = 1
capnp_sizeof(::Type{CapnpInt16  }) = 2
capnp_sizeof(::Type{CapnpInt32  }) = 4
capnp_sizeof(::Type{CapnpInt64  }) = 8
capnp_sizeof(::Type{CapnpUInt8  }) = 1
capnp_sizeof(::Type{CapnpUInt16 }) = 2
capnp_sizeof(::Type{CapnpUInt32 }) = 4
capnp_sizeof(::Type{CapnpUInt64 }) = 8
capnp_sizeof(::Type{CapnpFloat32}) = 4
capnp_sizeof(::Type{CapnpFloat64}) = 8

capnp_type_to_bits_type(::Type{CapnpInt8   }) = UInt8
capnp_type_to_bits_type(::Type{CapnpInt16  }) = UInt16
capnp_type_to_bits_type(::Type{CapnpInt32  }) = UInt32
capnp_type_to_bits_type(::Type{CapnpInt64  }) = UInt64
capnp_type_to_bits_type(::Type{CapnpUInt8  }) = UInt8
capnp_type_to_bits_type(::Type{CapnpUInt16 }) = UInt16
capnp_type_to_bits_type(::Type{CapnpUInt32 }) = UInt32
capnp_type_to_bits_type(::Type{CapnpUInt64 }) = UInt64
capnp_type_to_bits_type(::Type{CapnpFloat32}) = Float32
capnp_type_to_bits_type(::Type{CapnpFloat64}) = Float64
capnp_type_to_bits_type(::Any) = nothing

is_capnp_bits(type) = capnp_type_to_bits_type(type) !== nothing