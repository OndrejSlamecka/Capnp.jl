using Test

# When running with Pkg.test() (like in Github Actions) the cwd is set to test, revert that.
if endswith(pwd(), "test")
    cd("..")
end

@testset "Addressbook integration test" begin
    run(`capnpc -o./capnpc-jl example/addressbook.capnp`)

    # Write address book and read it back while using the `capnp` tool in the middle to check the format.
    result = read(
        ```sh -c 'julia --project example/addressbook.jl write \
                | capnp convert binary:text example/addressbook.capnp AddressBook \
                | capnp convert text:binary example/addressbook.capnp AddressBook \
                | julia --project example/addressbook.jl read'```,
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

@testset "Lists" begin
    run(`capnpc -o./capnpc-jl test/lists.capnp`)
    include("lists.capnp.jl")

    # writing part
    message = Capnp.AllocMessageBuilder()
    listTest = initRoot_ListTest(message)
    bytes = ListTest_initBytes(listTest, 7)
    ints = ListTest_initInts(listTest, 7)
    # bools = ListTest_initBools(listTest, 7)
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
    listTest = root_ListTest(message)

    bytes = ListTest_getBytes(listTest)
    @test bytes[1] == 1 # tests getindex
    @test length(bytes) == 7
    @test collect(bytes) == 1:7 # tests iterate

    ints = ListTest_getInts(listTest)
    @test ints[1] == 1
    @test length(ints) == 7
    @test collect(ints) == 1:7

    # bools = ListTest_getBools(listTest)
    # @test bools[1] == 1
    # @test length(bools) == 7
    # @test collect(bools) == [1,0,1,0,1,0,1]
end