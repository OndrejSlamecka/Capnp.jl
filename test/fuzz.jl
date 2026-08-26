using Test
using Capnp
using Random

# Ensure schema is available
if !isdefined(Main, :ListsSchema)
    if !Sys.iswindows()
        run(`capnpc -o./capnpc-jl test/lists.capnp`)
    else
        run(pipeline(`capnp compile -o- test/lists.capnp`, `julia --project capnpc-jl`))
    end
    
    @eval module ListsSchema
        include("lists.capnp.jl")
    end
end

@testset "Randomized Fuzzing" begin
    function generate_valid_message_bytes()
        builder = Capnp.AllocMessageBuilder()
        writer = ListsSchema.init_root!(builder, Val{:ListTest})
        int_writer = ListsSchema.init_ints!(writer, 10, Val{:ListTest})
        for i = 1:10
            int_writer[i] = i
        end
        buffer = IOBuffer()
        Capnp.writeMessageToStream(builder, buffer)
        
        # Add an elementary message
        builder2 = Capnp.AllocMessageBuilder()
        writer2 = ElementarySchema.init_root!(builder2, Val{:Test})
        ElementarySchema.set_signed64!(writer2, -42, Val{:Test})
        buffer2 = IOBuffer()
        Capnp.writeMessageToStream(builder2, buffer2)
        
        return [take!(buffer), take!(buffer2)]
    end

    valid_messages = generate_valid_message_bytes()

    Random.seed!(42)
    for _ in 1:2000
        valid_bytes = rand(valid_messages)
        bytes = copy(valid_bytes)
        mutations = rand(1:5)
        for _ in 1:mutations
            op = rand(1:4)
            if op == 1 # truncate
                if length(bytes) > 0
                    resize!(bytes, rand(0:length(bytes)-1))
                end
            elseif op == 2 # flip a bit
                if length(bytes) > 0
                    idx = rand(1:length(bytes))
                    bit = rand(0:7)
                    bytes[idx] ⊻= (1 << bit)
                end
            elseif op == 3 # randomize a byte
                if length(bytes) > 0
                    idx = rand(1:length(bytes))
                    bytes[idx] = rand(UInt8)
                end
            elseif op == 4 # duplicate segment or append garbage
                append!(bytes, rand(UInt8, rand(1:16)))
            end
        end

        try
            reader = Capnp.MessageReader(IOBuffer(bytes))
            
            # Try to read as ListTest
            list_value = ListsSchema.root(reader, Val{:ListTest})
            int_reader = ListsSchema.get_ints(list_value, Val{:ListTest})
            for i in 1:length(int_reader)
                _ = int_reader[i]
            end
            
            # Try to read as ElementaryTest
            # We'll just read raw bits from the struct root.
            root_ptr = Capnp.StructPointer(reader, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            root_struct = Capnp.read_struct_pointer(root_ptr, 0, 0)
            if root_struct !== nothing
                Capnp.read_bits(root_struct, 0, UInt64)
            end
        catch e
            if !(e isa Capnp.InvalidMessageError || e isa EOFError || e isa ArgumentError)
                @show e
                @test e isa Capnp.InvalidMessageError
                rethrow(e)
            end
        end
    end
end
