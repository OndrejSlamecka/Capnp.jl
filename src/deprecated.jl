# Deprecation wrappers for legacy API
# This module provides backward compatibility for the old Struct_getField naming convention
# These will be removed in the next major version

# The deprecation wrappers will be generated alongside new code
# Each legacy function name will be wrapped with @deprecate pointing to the new function

# Example pattern (will be auto-generated for each struct/field):
# @deprecate Person_getName(ptr) get_name(ptr)
# @deprecate Person_setName(ptr, value) set_name!(ptr, value)

# Note: Actual deprecation wrappers are generated in generator.jl
# This file provides the deprecation infrastructure and any manual deprecations

"""
    generate_deprecation(old_name::String, new_name::String)

Helper to generate deprecation macro invocation string.
"""
function generate_deprecation_str(old_name::String, new_name::String, args::String)
    "@deprecate $old_name($args) $new_name($args)"
end
