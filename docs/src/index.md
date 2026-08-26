# Capnp.jl

Capnp.jl implements Cap'n Proto serialization and code generation in Julia. RPC support is experimental and incomplete.

```@contents
Pages = ["support.md", "api.md", "rpc.md", "rpc-functions.md"]
Depth = 2
```

## Installation

Capnp.jl requires Julia 1.10 or newer. Schema generation also requires a `capnp` compiler executable.

```julia
using Pkg
Pkg.add("Capnp")
```

## Basic message workflow

Generate Julia code from a schema using the repository's `capnpc-jl` plugin:

```sh
capnpc -o./capnpc-jl schema.capnp
```

Include the generated file, construct a message, and write it to an IO stream:

```julia
using Capnp
include("schema.capnp.jl")

message = Capnp.AllocMessageBuilder()
# Initialize and populate the generated root type here.
Capnp.writeMessageToStream(message, stdout)
```

!!! warning
    The current reader has bounded message framing and checked pointer accesses, but traversal and nesting budgets are not yet enforced. Treat RPC and untrusted-message processing as experimental.
