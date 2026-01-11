# Capnp.jl - Julia plugin for Cap'n Proto

A Julia implementation of the Cap'n Proto serialization format with partial RPC support ([level 1 and level 2](https://capnproto.org/rpc.html#protocol-features) currently).

## Features

- **Wire format compliance**: Full support for Cap'n Proto binary format including default values, packed encoding, and generic types
- **RPC client**: Connect to Cap'n Proto RPC servers with promise pipelining support
- **RPC server**: Host Cap'n Proto services accessible to remote clients
- **Zero-copy performance**: Pre-allocated buffer support for minimal allocations
- **Code generation**: Generate Julia types from Cap'n Proto schemas

## Install & Use

Install from JuliaHub:

    ] add Capnp

Download `capnpc-jl` from this repository and generate code for a schema with:

    capnpc -o./capnpc-jl example/addressbook.capnp

## Quick Start

### Reading and Writing Messages

```julia
using Capnp

# Include generated schema code
include("addressbook.capnp.jl")

# Writing
message = Capnp.AllocMessageBuilder()
addressBook = init_root!(message, Val{:AddressBook})
# ... build message ...
writeMessageToStream(message, stdout)

# Reading
message = Capnp.MessageReader(stdin)
addressBook = root(message, Val{:AddressBook})
# ... read data ...
```

### RPC Client

```julia
using Capnp
using Capnp.RPC

# Connect to server
conn = RPC.connect("localhost", 55000)
client = RPC.bootstrap(conn)

# Call methods (with promise pipelining)
result_promise = Calculator_evaluateAsync(client, params)
result = fetch(result_promise)
```

### RPC Server

```julia
using Capnp
using Capnp.RPC

# Implement the server interface
struct MyCalculator <: Calculator_Server end

function Calculator_evaluate(impl::MyCalculator, context, params)
    # ... implementation ...
    RPC.set_result!(context, result)
end

# Start server
server = RPC.Server(MyCalculator())
RPC.listen(server, "127.0.0.1", 55000)
RPC.serve(server)
```

### Zero-Copy Operations

```julia
using Capnp

# Pre-allocated buffer reading
buffer = read("message.bin")
reader = Capnp.BufferMessageReader(buffer)

# Pre-allocated buffer writing
buffer = zeros(UInt8, 4096)
builder = Capnp.BufferMessageBuilder(buffer)
# ... build message ...
bytes_written = Capnp.finalize!(builder)
```

## Examples

See the [`example` directory](example/) for complete examples:

- `addressbook.jl` - Basic serialization example
- `calculator.capnp` - Calculator RPC interface schema
- `calculator_client.jl` - RPC client example
- `calculator_server.jl` - RPC server implementation

## Generated API

### New API (recommended)

For a struct `MyStruct` with a field `my_field`:
- Reading: `get_my_field(reader, Val{:MyStruct})`
- Writing: `set_my_field!(writer, value, Val{:MyStruct})`
- Init (for structs/lists): `init_my_field!(writer, Val{:MyStruct})`

### Legacy API (deprecated)

The old naming convention is still supported but deprecated:
- `MyStruct_getMyField(reader)` → use `get_my_field(reader, Val{:MyStruct})`
- `MyStruct_setMyField(writer, value)` → use `set_my_field!(writer, value, Val{:MyStruct})`

### Namespace Support

Capnp.jl supports namespace annotations and translates them into Julia modules:
- Using `$Cxx.namespace("capnp::schema");` generates code in module `capnp.schema`
- Note: Julia modules can't reference each other in a cycle

### Lists

Access lists with brackets `[]` (1-based indexing as is standard in Julia).
Initialize lists with `init_items!(writer, count, Val{:MyStruct})`.

### Unions

For struct `A` with union group `u`:
- Enum: `A_u_union`
- Check variant: `A_u_which(reader)`
- Set variant: `A_u_setXy(writer, value)`
- Initialize struct variant: `A_u_initXy(writer)`

## Development

See `src/Capnp.jl` for code structure description.

To regenerate the schema code:

    capnpc -o./capnpc-jl src/schema.capnp

Run tests:

    julia --project test/runtests.jl

Or using Pkg:

    ] test

Format code (excluding generated files):

```julia
using JuliaFormatter
format(".")
# Restore generated files
# git checkout src/schema.capnp.jl example/calculator.capnp.jl
```

For debugging, save messages to files and use `xxd --bits --cols 8`.
See [How to Write Compiler Plugins](https://capnproto.org/otherlang.html) for more tips.
