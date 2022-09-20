# Capnp.jl - Julia plugin for Cap'n'proto

**This is currently a prototype.**

# Install & use

Install from JuliaHub:

    ] add Capnp

Download `capnpc-jl` from this repository and generate code for a schema with

    capnpc -o./capnpc-jl example/addressbook.capnp

## Example

See [the addressbook example](https://capnproto.org/cxx.html) in the [`example` directory](example/).

## Generated names

Capnp.jl supports namespace annotations and translates them into Julia modules.  E.g. using
`$Cxx.namespace("capnp::schema");` generates code in module `capnp.schema`. Note Julia modules can't reference each
other in a cycle.

To start reading a reader has to be opened with a stream, e.g. `message = Capnp.MessageReader(stdin)` and root reader
created, e.g. for a struct `A` `reader = root_A(message)`. To write, a writer has to be created, e.g. `message =
Capnp.AllocMessageBuilder()`, root writer initialised, e.g. `writer = initRoot_A(message)`, and finally the message
should be written to a stream `writeMessageToStream(message, stdout)`.

For a struct `A` with a field `xy` function `A_getXy(reader)` is generated. If `A` has a nested struct `B` with a field
`yz` then `A_B_getYz()` is generated.

For reading and writing lists you can use brackets `[]` but note this is 1-based as is usual in Julia. For writing lists
you need to initialise them with `A_initBs(a_writer, number_of_items)`.

If struct `A` has a union group `u` then `A_u_union` enum is generated as well as function `A_u_which(a_reader)`. For an
anonymous union the names would be `A_union` and `A_which`. Sett union slot `xy` with `A_u_setXy(a_writer, value)` or
`A_u_setXy(a_writer)` if `xy` is `Void`. For `xy` of struct type use `xy_writer = A_u_initXy(a_writer)`.

(If you feel there's something missing in this description then please let me know.)

## Development

See `src/Capnp.jl` for description of code structure. To generate the code for _the_ Capnp schema use `capnpc
-o./capnpc-jl src/schema.capnp`.

Some things to work on:

* Add a test like the addressbook integration test but one testing _the_ capnp schema reading/writing.
* Emit types that make user code safer.
* Zero allocations when reading or writing using a big enough buffer. Start by adding a test.
* Support capnp's packing.
* Generate smaller code.
* Support generics.
* Test in _some_ production environment. (Please let me know if you do.)
* Initialisation/default values.

For debugging it can be useful to save a message to a file and use `xxd --bits --cols 8`. [How to Write Compiler Plugins](https://capnproto.org/otherlang.html) has other good tips, especially the bit with printing annotated schema (`capnp compile -ocapnp schema.capnp`).

Finally, run tests with `julia --project test/runtests.jl` and format code with JuliaFormatter.jl.
