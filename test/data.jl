using Test
using Capnp

@testset "Data fields" begin
    @test Capnp.read_data(nothing) == UInt8[]

    builder = Capnp.AllocMessageBuilder()
    bytes = UInt8[0xde, 0xad, 0xbe, 0xef]
    pointer_location = Capnp.WirePointer(UInt32(1), UInt32(0))
    Capnp.alloc(builder, pointer_location, 8)
    pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, length(bytes))
    data_pointer = Capnp.SimpleListPointer{UInt8,typeof(builder)}(
        builder, segment, offset, Capnp.Byte, UInt32(length(bytes)),
    )
    Capnp.write_list_pointer(pointer_location, data_pointer)

    @test Capnp.write_data(data_pointer, bytes) === data_pointer
    @test Capnp.read_data(data_pointer) == bytes
    @test Capnp.read_data(data_pointer) !== bytes

    wrong_element_type = Capnp.SimpleListPointer{UInt16,typeof(builder)}(
        builder, segment, offset, Capnp.TwoBytes, UInt32(2),
    )
    @test_throws Capnp.InvalidMessageError Capnp.read_data(wrong_element_type)
    @test_throws Capnp.InvalidMessageError Capnp.write_data(wrong_element_type, bytes)
    @test_throws Capnp.InvalidMessageError Capnp.write_data(data_pointer, UInt8[0x01])

    outside_segment = Capnp.SimpleListPointer{UInt8,typeof(builder)}(
        builder, segment, UInt32(length(builder.segments[Int(segment)]) ÷ 8), Capnp.Byte, UInt32(1),
    )
    @test_throws Capnp.InvalidMessageError Capnp.read_data(outside_segment)
    @test_throws Capnp.InvalidMessageError Capnp.write_data(outside_segment, UInt8[0x01])
end

@testset "Generated complex fields" begin
    schema = Main.ComplexTypesSchema
    builder = Capnp.AllocMessageBuilder()
    root = schema.init_root!(builder, Val{:ComplexFields})

    schema.set_data_field!(root, UInt8[0xde, 0xad, 0xbe, 0xef], Val{:ComplexFields})

    list_location = Capnp.WirePointer(root.segment, root.offset + root.data_word_count + 1)
    list_location, list_segment, list_offset = Capnp.alloc(builder, list_location, 16)
    list_pointer = Capnp.SimpleListPointer{Capnp.CapnpData,typeof(builder)}(
        builder, list_segment, list_offset, Capnp.Pointer, UInt32(2),
    )
    Capnp.write_list_pointer(list_location, list_pointer)
    for (index, bytes) in enumerate((UInt8[0x11], UInt8[0x22, 0x33]))
        item_location = Capnp.WirePointer(list_segment, list_offset + UInt32(index - 1))
        item_location, item_segment, item_offset = Capnp.alloc(builder, item_location, length(bytes))
        item_pointer = Capnp.SimpleListPointer{UInt8,typeof(builder)}(
            builder, item_segment, item_offset, Capnp.Byte, UInt32(length(bytes)),
        )
        Capnp.write_list_pointer(item_location, item_pointer)
        Capnp.write_data(item_pointer, bytes)
    end

    buffer = IOBuffer()
    Capnp.writeMessageToStream(builder, buffer)
    seekstart(buffer)
    reader = Capnp.MessageReader(buffer)
    value = schema.root(reader, Val{:ComplexFields})

    @test schema.get_data_field(value, Val{:ComplexFields}) == UInt8[0xde, 0xad, 0xbe, 0xef]
    @test collect(schema.get_list_data_field(value, Val{:ComplexFields})) == [UInt8[0x11], UInt8[0x22, 0x33]]
    @test schema.get_any_pointer_field(value, Val{:ComplexFields}) === nothing
end
