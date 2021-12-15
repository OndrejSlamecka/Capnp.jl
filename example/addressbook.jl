# The Capnp.jl variant of the official example, https://capnproto.org/cxx.html
#
# First, install Capnp.jl. Currently it's not in the main repository so use
#     ] add https://github.com/OndrejSlamecka/Capnp.jl.git
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

    addressBook = initRoot_AddressBook(message)
    people = AddressBook_initPeople(addressBook, 2)

    alice = people[1]
    Person_setId(alice, 123)
    Person_setName(alice, "Alice")
    Person_setEmail(alice, "alice@example.com")
    alicePhones = Person_initPhones(alice, 1)
    Person_PhoneNumber_setNumber(alicePhones[1], "555-1212")
    Person_PhoneNumber_setType(alicePhones[1], Person_PhoneNumber_Type_mobile)
    Person_employment_setSchool(alice, "MIT")

    bob = people[2]
    Person_setId(bob, 456)
    Person_setName(bob, "Bob")
    Person_setEmail(bob, "bob@example.com")
    bobPhones = Person_initPhones(bob, 2)
    Person_PhoneNumber_setNumber(bobPhones[1], "555-4567")
    Person_PhoneNumber_setType(bobPhones[1], Person_PhoneNumber_Type_home)
    Person_PhoneNumber_setNumber(bobPhones[2], "555-7654")
    Person_PhoneNumber_setType(bobPhones[2], Person_PhoneNumber_Type_work)
    Person_employment_setUnemployed(bob)

    writeMessageToStream(message, stdout)
end

function printAddressBook()
    message = Capnp.MessageReader(stdin)
    addressBook = root_AddressBook(message)

    for person in AddressBook_getPeople(addressBook)
        println(Person_getName(person), ": ", Person_getEmail(person))

        for phone in Person_getPhones(person)
            typeName = "unknown"
            if Person_PhoneNumber_getType(phone) == Person_PhoneNumber_Type_mobile
                typeName = "mobile"
            elseif Person_PhoneNumber_getType(phone) == Person_PhoneNumber_Type_home
                typeName = "home"
            elseif Person_PhoneNumber_getType(phone) == Person_PhoneNumber_Type_work
                typeName = "work"
            end

            println("  ", typeName, " phone: ", Person_PhoneNumber_getNumber(phone))
        end

        # Support getEmployment not yet available
        employment = Person_getEmployment(person)
        if Person_employment_which(employment) == Person_employment_union_unemployed
            println("  unemployed")
        elseif Person_employment_which(employment) == Person_employment_union_employer
            println("  employer: ", Person_employment_getEmployer(employment))
        elseif Person_employment_which(employment) == Person_employment_union_school
            println("  student at: ", Person_employment_getSchool(employment))
        elseif Person_employment_which(employment) == Person_employment_union_selfEmployed
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
