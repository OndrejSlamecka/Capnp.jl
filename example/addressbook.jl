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

    addressBook = AddressBook(message)
    peoples = addressBook.people(2)
    alice = peoples[1]
    alice.id = 123
    alice.name = "Alice"
    alice.email = "alice@example.com"
    alicePhones = alice.phones(1)
    alicePhone = first(alicePhones)
    alicePhone.number = "555-1212"
    alicePhone.type = :mobile
    alice.employment.school = "MIT"

    bob = peoples[2]
    bob.id = 456
    bob.name = "Bob"
    bob.email = "bob@example.com"
    bobPhones = bob.phones(2)
    bobPhones[1].number = "555-4567"
    bobPhones[1].type = :home
    bobPhones[2].number = "555-7654"
    bobPhones[2].type = :work
    bob.employment.unemployed

    writeMessageToStream(message, stdout)
end

function printAddressBook()
    message = Capnp.MessageReader(stdin)
    addressBook = AddressBook(message)

    for person in addressBook.people
        println(person.name, ": ", person.email)

        for phone in person.phones
            typeName = "unknown"
            if Capnp.isenumequal(phone.type, :mobile)
                typeName = "mobile"
            elseif Capnp.isenumequal(phone.type, :home)
                typeName = "home"
            elseif Capnp.isenumequal(phone.type, :work)
                typeName = "work"
            end

            println("  ", typeName, " phone: ", phone.number)
        end

        # Support getEmployment not yet available
        employment = person.employment
        employmentype = which(employment)
        if Capnp.isenumequal(employmentype, :unemployed)
            println("  unemployed")
        elseif Capnp.isenumequal(employmentype, :employer)
            println("  employer: ", employment.employer)
        elseif Capnp.isenumequal(employmentype, :school)
            println("  student at: ", employment.school)
        elseif Capnp.isenumequal(employmentype, :selfEmployed)
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
