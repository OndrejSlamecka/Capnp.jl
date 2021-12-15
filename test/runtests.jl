using Test

@testset "Addressbook integration test" begin
    # When running with Pkg.test() (like in Github Actions) the cwd is set to test, revert that.
    if endswith(pwd(), "test")
        cd("..")
    end

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
