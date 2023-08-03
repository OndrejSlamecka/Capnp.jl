module Capnp

# Exports for user code. Generated code should use `Capnp.` prefix.
export MessageTraverser, Reader, Writer, writeMessageToStream

include("runtime_types.jl")
include("runtime_lib.jl")
include("typed_pointers.jl")

module Generator
using ..Capnp

include("schema.capnp.jl")
include("schema_tree.jl")
include("generator.jl")
end

end
