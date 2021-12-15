module Capnp

# Used by generated code at runtime
include("capnp_types.jl")
include("runtime_lib.jl")

module Generator
using ..Capnp

include("schema.capnp.jl")
include("schema_tree.jl")
include("generator.jl")
end

end
