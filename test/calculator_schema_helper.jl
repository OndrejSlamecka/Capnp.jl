# Helper file for including calculator schema in tests
# This file is included from test/rpc/server.jl

using Capnp
using Capnp.RPC

# Cross-platform helper to compile Cap'n Proto schema
function compile_capnp_helper(schema_path)
    if Sys.iswindows()
        # On Windows, shebangs don't work, so we pipe capnpc output to Julia directly
        run(pipeline(`capnp compile -o- $schema_path`, `julia --project capnpc-jl`))
    else
        # On Unix, use the shebang-based script
        run(`capnpc -o./capnpc-jl $schema_path`)
    end
end

# Generate the calculator schema if needed
compile_capnp_helper("example/calculator.capnp")

# Include the generated calculator schema
# Use @__DIR__ to get the directory of this file and navigate to example/
include(joinpath(@__DIR__, "..", "example", "calculator.capnp.jl"))
