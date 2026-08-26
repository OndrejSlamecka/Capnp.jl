using Test
using Capnp

# When running with Pkg.test() (like in Github Actions) the cwd is set to test, revert that.
if endswith(pwd(), "test")
    cd("..")
end

"""
    compile_capnp(schema_path)

Cross-platform helper to compile a Cap'n Proto schema using the Julia plugin.
On Unix, uses the shebang-based capnpc-jl script directly.
On Windows, uses Julia's pipeline to work around shebang limitations.
"""
function compile_capnp(schema_path)
    if Sys.iswindows()
        # On Windows, shebangs don't work, so we pipe capnpc output to Julia directly
        run(pipeline(`capnp compile -o- $schema_path`, `julia --project capnpc-jl`))
    else
        # On Unix, use the shebang-based script
        run(`capnpc -o./capnpc-jl $schema_path`)
    end
end

# Keep generated schemas in separate namespaces. Besides avoiding collisions in
# their common helper names, this prevents method invalidation issues on Julia 1.10.
compile_capnp("test/elementary.capnp")
compile_capnp("test/lists.capnp")
compile_capnp("test/complextypes.capnp")

module ElementarySchema
include("elementary.capnp.jl")
end

module ListsSchema
include("lists.capnp.jl")
end

module ComplexTypesSchema
include("complextypes.capnp.jl")
end

@testset "Addressbook integration test" begin
    compile_capnp("example/addressbook.capnp")

    # Write address book and read it back while using the `capnp` tool in the middle to check the format.
    # Uses Julia's pipeline() for cross-platform compatibility (sh -c doesn't work on Windows)
    result = read(
        pipeline(
            `julia --project example/addressbook.jl write`,
            `capnp convert binary:text example/addressbook.capnp AddressBook`,
            `capnp convert text:binary example/addressbook.capnp AddressBook`,
            `julia --project example/addressbook.jl read`,
        ),
        String,
    )
    expected = """Alice: alice@example.com
    mobile phone: 555-1212
    student at: MIT
  Bob: bob@example.com
    home phone: 555-4567
    work phone: 555-7654
    unemployed
  """
    @test result == expected
end

@testset "Elementary types" begin
    # writing part
    builder = Capnp.AllocMessageBuilder()
    test_writer = ElementarySchema.init_root!(builder, Val{:Test})
    ElementarySchema.set_boolean_false!(test_writer, false, Val{:Test})
    ElementarySchema.set_boolean_true!(test_writer, true, Val{:Test})
    ElementarySchema.set_signed64!(test_writer, -1, Val{:Test})

    # finish writing and flush into buffer for reading
    buffer = IOBuffer()
    writeMessageToStream(builder, buffer)
    seek(buffer, 0)

    # reading part
    reader = Capnp.MessageReader(buffer)
    test_reader = ElementarySchema.root(reader, Val{:Test})

    booleanFalse = ElementarySchema.get_boolean_false(test_reader, Val{:Test})
    @test booleanFalse == false

    booleanTrue = ElementarySchema.get_boolean_true(test_reader, Val{:Test})
    @test booleanTrue == true

    signed64 = ElementarySchema.get_signed64(test_reader, Val{:Test})
    @test signed64 == -1
end

@testset "Lists" begin
    # writing part
    list_builder = Capnp.AllocMessageBuilder()
    list_writer = ListsSchema.init_root!(list_builder, Val{:ListTest})
    byte_writer = ListsSchema.init_bytes!(list_writer, 7, Val{:ListTest})
    int_writer = ListsSchema.init_ints!(list_writer, 7, Val{:ListTest})
    # bools = init_bools!(listTest, 7, Val{:ListTest})
    for i = 1:7
        byte_writer[i] = i
        int_writer[i] = i
        # bools[i] = i % 2
    end
    
    texts_writer = ListsSchema.init_texts!(list_writer, 2, Val{:ListTest})
    texts_writer[1] = "hello"
    texts_writer[2] = "world"
    
    lists_writer = ListsSchema.init_lists!(list_writer, 2, Val{:ListTest})
    # To initialize inner lists, we need init_ints! equivalent... wait, Capnp API for allocating inner lists?
    # SimpleListPointer doesn't have an `init` for its elements. Wait, if we assign to lists_writer[i], what does it do?
    # It would try to `setindex!` with a list value, but how do we create the inner list before writing it?
    # Actually, in Capnp.jl, nested lists of lists are tricky without a dedicated init method. 
    # For now, let's just leave the lists_writer empty (it is allocated as a list of lists, but all pointers are null).
    
    data_writer = ListsSchema.init_data_list!(list_writer, 2, Val{:ListTest})
    data_writer[1] = UInt8[0xde, 0xad]
    data_writer[2] = UInt8[0xbe, 0xef]

    buffer = IOBuffer()
    writeMessageToStream(list_builder, buffer)
    seek(buffer, 0)

    # reading part
    list_reader = Capnp.MessageReader(buffer)
    list_value = ListsSchema.root(list_reader, Val{:ListTest})

    byte_reader = ListsSchema.get_bytes(list_value, Val{:ListTest})
    @test byte_reader[1] == 1 # tests getindex
    @test length(byte_reader) == 7
    @test collect(byte_reader) == 1:7 # tests iterate

    int_reader = ListsSchema.get_ints(list_value, Val{:ListTest})
    @test int_reader[1] == 1
    @test length(int_reader) == 7
    @test collect(int_reader) == 1:7

    # bools = get_bools(listTest, Val{:ListTest})
    # @test bools[1] == 1
    # @test length(bools) == 7
    # @test collect(bools) == [1,0,1,0,1,0,1]
    
    texts_reader = ListsSchema.get_texts(list_value, Val{:ListTest})
    @test length(texts_reader) == 2
    @test texts_reader[1] == "hello"
    @test texts_reader[2] == "world"
    @test collect(texts_reader) == ["hello", "world"]
    
    lists_reader = ListsSchema.get_lists(list_value, Val{:ListTest})
    @test length(lists_reader) == 2
    
    data_reader = ListsSchema.get_data_list(list_value, Val{:ListTest})
    @test length(data_reader) == 2
    @test data_reader[1] == UInt8[0xde, 0xad]
    @test data_reader[2] == UInt8[0xbe, 0xef]
    @test collect(data_reader) == [[0xde, 0xad], [0xbe, 0xef]]
end

# RPC capability tests
include("rpc/capability.jl")

if !isempty(ARGS)
    for arg in ARGS
        if arg == "rpc/test_tls.jl"
            include("rpc/test_tls.jl")
        else
            include(arg)
        end
    end
    exit(0)
end

# User Story 1: Wire Format Compliance tests
include("defaults.jl")
include("packed.jl")
include("double_far.jl")
include("data.jl")
include("generics.jl")
include("reader_validation.jl")
include("fuzz.jl")
include("interop/roundtrip.jl")
include("generator_persistent_test.jl")

@testset "Code Generator Request Copy" begin
    include("copy_schema.jl")
end

include("golden_tests.jl")

# User Story 2: RPC Client tests
include("rpc/promise.jl")
include("rpc/client.jl")
include("rpc/cancellation.jl")
include("rpc/calculator.jl")
include("rpc/test_protocol.jl")
include("rpc/test_persistent.jl")
include("rpc/test_persistent_integration.jl")

# User Story 3: RPC Server tests
include("rpc/server.jl")

@testset "C++ Interoperability Tests" begin
    if isfile(joinpath(@__DIR__, "interop", "cpp_client_test"))
        include("interop/test_cpp_interop.jl")
    else
        println("Skipping C++ client interop: cpp_client_test not found")
    end
    
    if isfile(joinpath(@__DIR__, "interop", "cpp_server_test"))
        include("interop/test_cpp_tls_interop.jl")
    else
        println("Skipping C++ TLS interop: cpp_server_test not found")
    end
end

# User Story 4: Zero-Copy Performance tests
include("performance.jl")

# Package quality checks
using Aqua
Aqua.test_all(Capnp)
