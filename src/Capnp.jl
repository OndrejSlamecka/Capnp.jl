module Capnp

# Exports for user code. Generated code should use `Capnp.` prefix.
export MessageTraverser, Reader, Writer, writeMessageToStream
export BufferMessageReader, BufferMessageBuilder, get_segments, finalize!
export InvalidMessageError

# Core runtime types and library
include("runtime_types.jl")
include("runtime_lib.jl")

# New functionality for full Cap'n Proto compliance
include("defaults.jl")       # Default value handling (US1)
include("packed.jl")         # Packed encoding support (US1)
include("generics.jl")       # Generic type support (US1)

# Deprecation wrappers for API migration
include("deprecated.jl")

# RPC module for client and server functionality
include("rpc/RPC.jl")
using .RPC

# Code generator module
module Generator
using ..Capnp

include("schema.capnp.jl")
include("schema_tree.jl")
include("generator.jl")
end

end
