# Helper file for including calculator schema in tests
# This file is included from test/rpc/server.jl

using Capnp
using Capnp.RPC

# Include the generated calculator schema
# Use @__DIR__ to get the directory of this file and navigate to example/
include(joinpath(@__DIR__, "..", "example", "calculator.capnp.jl"))
