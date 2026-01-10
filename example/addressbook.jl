# The Capnp.jl variant of the official example, https://capnproto.org/cxx.html
#
# First, install Capnp.jl:
#     ] add Capnp
#
# Generate the code for the schema (you need the `capnpc-jl` file distributed with Capnp.jl):
#     capnpc -o./capnpc-jl example/addressbook.capnp
# or if you add the directory to your PATH:
#     capnpc -o jl example/addressbook.capnp
#
# Test writing out:
#     julia addressbook.jl write | capnp convert binary:text addressbook.capnp AddressBook
#
# You should see something like
#     ( people = [
#         ( id = 123,
#         name = "Alice",
#         email = "alice@example.com",
#         phones = [
#             (number = "555-1212", type = mobile) ],
#         employment = (school = "MIT") ),
#         ( id = 456,
#         name = "Bob",
#         email = "bob@example.com",
#         phones = [
#             (number = "555-4567", type = home),
#             (number = "555-7654", type = work) ],
#         employment = (unemployed = void) ) ] )
#
# Let's also check reading:
#    julia addressbook.jl write | julia addressbook.jl read
#
# And observe:
#    Alice: alice@example.com
#      mobile phone: 555-1212
#      student at: MIT
#    Bob: bob@example.com
#      home phone: 555-4567
#      work phone: 555-7654
#      unemployed


using Capnp
include("addressbook.capnp.jl") # the generated file

function writeAddressBook()
    message = Capnp.AllocMessageBuilder()

    addressBook = init_root!(message, Val{:AddressBook})
    people = init_people!(addressBook, 2, Val{:AddressBook})

    alice = people[1]
    set_id!(alice, 123, Val{:Person})
    set_name!(alice, "Alice", Val{:Person})
    set_email!(alice, "alice@example.com", Val{:Person})
    alicePhones = init_phones!(alice, 1, Val{:Person})
    set_number!(alicePhones[1], "555-1212", Val{:Person_PhoneNumber})
    set_type!(alicePhones[1], Person_PhoneNumber_Type_mobile, Val{:Person_PhoneNumber})
    set_school!(alice, "MIT", Val{:Person_employment})

    bob = people[2]
    set_id!(bob, 456, Val{:Person})
    set_name!(bob, "Bob", Val{:Person})
    set_email!(bob, "bob@example.com", Val{:Person})
    bobPhones = init_phones!(bob, 2, Val{:Person})
    set_number!(bobPhones[1], "555-4567", Val{:Person_PhoneNumber})
    set_type!(bobPhones[1], Person_PhoneNumber_Type_home, Val{:Person_PhoneNumber})
    set_number!(bobPhones[2], "555-7654", Val{:Person_PhoneNumber})
    set_type!(bobPhones[2], Person_PhoneNumber_Type_work, Val{:Person_PhoneNumber})
    set_unemployed!(bob, Val{:Person_employment})

    writeMessageToStream(message, stdout)
end

function printAddressBook()
    message = Capnp.MessageReader(stdin)
    addressBook = root(message, Val{:AddressBook})

    for person in get_people(addressBook, Val{:AddressBook})
        println(get_name(person, Val{:Person}), ": ", get_email(person, Val{:Person}))

        for phone in get_phones(person, Val{:Person})
            typeName = "unknown"
            if get_type(phone, Val{:Person_PhoneNumber}) == Person_PhoneNumber_Type_mobile
                typeName = "mobile"
            elseif get_type(phone, Val{:Person_PhoneNumber}) == Person_PhoneNumber_Type_home
                typeName = "home"
            elseif get_type(phone, Val{:Person_PhoneNumber}) == Person_PhoneNumber_Type_work
                typeName = "work"
            end

            println("  ", typeName, " phone: ", get_number(phone, Val{:Person_PhoneNumber}))
        end

        # Support getEmployment not yet available
        employment = get_employment(person, Val{:Person})
        if which(employment, Val{:Person_employment}) == Person_employment_union_unemployed
            println("  unemployed")
        elseif which(employment, Val{:Person_employment}) == Person_employment_union_employer
            println("  employer: ", get_employer(employment, Val{:Person_employment}))
        elseif which(employment, Val{:Person_employment}) == Person_employment_union_school
            println("  student at: ", get_school(employment, Val{:Person_employment}))
        elseif which(employment, Val{:Person_employment}) == Person_employment_union_selfEmployed
            println("  self-employed")
        end
    end
end

if length(ARGS) != 1 || !(ARGS[1] in ["read", "write"])
    println("Please specify 'read' or 'write' as the first argument")
elseif ARGS[1] == "read"
    printAddressBook()
else # write
    writeAddressBook()
end
