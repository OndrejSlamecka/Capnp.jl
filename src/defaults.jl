# Default value handling for Cap'n Proto (FR-002)
#
# In Cap'n Proto, default values are stored using XOR encoding:
# - Data section fields: stored_value XOR default_value = wire_value
# - Reading: wire_value XOR default_value = actual_value
# - Writing: value_to_write XOR default_value = wire_value
#
# For pointer fields, a null pointer (all zeros) means the default applies:
# - Text: empty string ""
# - Data: empty bytes
# - List: empty list
# - Struct: null (no struct present)
# - Capability: null capability

"""
    apply_default_xor(value::T, default::T) where T

Apply XOR decoding to retrieve the actual value from a wire value and its default.
For reading: actual = wire_value XOR default_value

# Example
```julia
# Field with default 42, stored as 0 on wire -> actual value is 42
apply_default_xor(UInt32(0), UInt32(42)) == 42

# Field with default 42, stored as 42 on wire -> actual value is 0
apply_default_xor(UInt32(42), UInt32(42)) == 0
```
"""
function apply_default_xor(value::T, default::T) where {T}
    xor(value, default)
end

"""
    encode_with_default(value::T, default::T) where T

Apply XOR encoding to prepare a value for writing to wire format.
For writing: wire_value = value_to_write XOR default_value

# Example
```julia
# Writing value 0 with default 42 -> stores 42 on wire
encode_with_default(UInt32(0), UInt32(42)) == 42

# Writing value 42 with default 42 -> stores 0 on wire (compact!)
encode_with_default(UInt32(42), UInt32(42)) == 0
```
"""
function encode_with_default(value::T, default::T) where {T}
    xor(value, default)
end

# Float defaults need special handling due to NaN representation
"""
    apply_default_xor(value::Float32, default::Float32)

Apply XOR decoding for Float32 values by reinterpreting as UInt32.
"""
function apply_default_xor(value::Float32, default::Float32)
    reinterpret(Float32, xor(reinterpret(UInt32, value), reinterpret(UInt32, default)))
end

"""
    apply_default_xor(value::Float64, default::Float64)

Apply XOR decoding for Float64 values by reinterpreting as UInt64.
"""
function apply_default_xor(value::Float64, default::Float64)
    reinterpret(Float64, xor(reinterpret(UInt64, value), reinterpret(UInt64, default)))
end

"""
    encode_with_default(value::Float32, default::Float32)

Apply XOR encoding for Float32 values by reinterpreting as UInt32.
"""
function encode_with_default(value::Float32, default::Float32)
    reinterpret(Float32, xor(reinterpret(UInt32, value), reinterpret(UInt32, default)))
end

"""
    encode_with_default(value::Float64, default::Float64)

Apply XOR encoding for Float64 values by reinterpreting as UInt64.
"""
function encode_with_default(value::Float64, default::Float64)
    reinterpret(Float64, xor(reinterpret(UInt64, value), reinterpret(UInt64, default)))
end

# Bool defaults (single bit)
"""
    apply_default_xor(value::Bool, default::Bool)

Apply XOR for boolean values.
"""
function apply_default_xor(value::Bool, default::Bool)
    xor(value, default)
end

"""
    encode_with_default(value::Bool, default::Bool)

Apply XOR encoding for boolean values.
"""
function encode_with_default(value::Bool, default::Bool)
    xor(value, default)
end

# Pointer field defaults
"""
    is_null_pointer(ptr)

Check if a pointer is null (all zero bytes), indicating default should apply.
"""
function is_null_pointer(ptr)
    isnothing(ptr)
end

"""
    default_text()

Return the default value for a null Text pointer: empty string.
"""
default_text() = ""

"""
    default_data()

Return the default value for a null Data pointer: empty byte array.
"""
default_data() = UInt8[]

"""
    default_list(::Type{T}) where T

Return the default value for a null List pointer: empty list.
"""
default_list(::Type{T}) where {T} = T[]

# Export public API
export apply_default_xor, encode_with_default
export is_null_pointer, default_text, default_data, default_list
