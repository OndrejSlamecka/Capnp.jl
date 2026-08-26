using Test
using Capnp

@testset "Golden Code Generation Tests" begin
    schemas = [
        "example/addressbook.capnp",
        "test/elementary.capnp",
        "test/lists.capnp",
        "test/complextypes.capnp"
    ]
    
    update_goldens = get(ENV, "UPDATE_GOLDENS", "false") == "true"
    
    for schema in schemas
        generated_file = schema * ".jl"
        golden_file = joinpath(@__DIR__, "goldens", basename(schema) * ".jl")
        
        @test isfile(generated_file)
        
        generated_content = read(generated_file, String)
        
        if update_goldens || !isfile(golden_file)
            if !isfile(golden_file)
                println("Creating new golden file for $schema")
            else
                println("Updating golden file for $schema")
            end
            write(golden_file, generated_content)
        end
        
        golden_content = read(golden_file, String)
        
        @test generated_content == golden_content
    end
end
