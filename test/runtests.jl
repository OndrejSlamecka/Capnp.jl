using Test

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

@testset "Addressbook integration test" begin
    compile_capnp("example/addressbook.capnp")

    # Write address book and read it back while using the `capnp` tool in the middle to check the format.
    # Uses Julia's pipeline() for cross-platform compatibility (sh -c doesn't work on Windows)
    result = read(
        pipeline(
            `julia --project example/addressbook.jl write`,
            `capnp convert binary:text example/addressbook.capnp AddressBook`,
            `capnp convert text:binary example/addressbook.capnp AddressBook`,
            `julia --project example/addressbook.jl read`
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
    compile_capnp("test/elementary.capnp")
    include("elementary.capnp.jl")

    # writing part
    message = Capnp.AllocMessageBuilder()
    test = init_root!(message, Val{:Test})
    set_boolean_false!(test, false, Val{:Test})
    set_boolean_true!(test, true, Val{:Test})
    set_signed64!(test, -1, Val{:Test})

    # finish writing and flush into buffer for reading
    buffer = IOBuffer()
    writeMessageToStream(message, buffer)
    seek(buffer, 0)

    # reading part
    message = Capnp.MessageReader(buffer)
    test = root(message, Val{:Test})

    booleanFalse = get_boolean_false(test, Val{:Test})
    @test booleanFalse == false

    booleanTrue = get_boolean_true(test, Val{:Test})
    @test booleanTrue == true

    signed64 = get_signed64(test, Val{:Test})
    @test signed64 == -1
end

@testset "Lists" begin
    compile_capnp("test/lists.capnp")
    include("lists.capnp.jl")

    # writing part
    message = Capnp.AllocMessageBuilder()
    listTest = init_root!(message, Val{:ListTest})
    bytes = init_bytes!(listTest, 7, Val{:ListTest})
    ints = init_ints!(listTest, 7, Val{:ListTest})
    # bools = init_bools!(listTest, 7, Val{:ListTest})
    for i = 1:7
        bytes[i] = i
        ints[i] = i
        # bools[i] = i % 2
    end

    # finish writing and flush into buffer for reading
    buffer = IOBuffer()
    writeMessageToStream(message, buffer)
    seek(buffer, 0)

    # reading part
    message = Capnp.MessageReader(buffer)
    listTest = root(message, Val{:ListTest})

    bytes = get_bytes(listTest, Val{:ListTest})
    @test bytes[1] == 1 # tests getindex
    @test length(bytes) == 7
    @test collect(bytes) == 1:7 # tests iterate

    ints = get_ints(listTest, Val{:ListTest})
    @test ints[1] == 1
    @test length(ints) == 7
    @test collect(ints) == 1:7

    # bools = get_bools(listTest, Val{:ListTest})
    # @test bools[1] == 1
    # @test length(bools) == 7
    # @test collect(bools) == [1,0,1,0,1,0,1]
end

# RPC capability tests
include("rpc/capability.jl")

# User Story 1: Wire Format Compliance tests
include("defaults.jl")
include("packed.jl")
include("generics.jl")
include("interop/roundtrip.jl")

# User Story 2: RPC Client tests
include("rpc/promise.jl")
include("rpc/client.jl")
include("rpc/calculator.jl")

# User Story 3: RPC Server tests
include("rpc/server.jl")

# User Story 4: Zero-Copy Performance tests
include("performance.jl")
