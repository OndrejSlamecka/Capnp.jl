using Test

@testset "Golden generation tests" begin
    files = [
        "src/schema.capnp",
        "example/addressbook.capnp",
        "example/calculator.capnp"
    ]
    
    for file in files
        golden_jl = file * ".jl"
        mktempdir() do dir
            capnpc_path = abspath("capnpc-jl")
            cmd = Cmd(["capnp", "compile", "-o" * capnpc_path * ":" * dir, file])
            
            err = IOBuffer()
            proc = run(pipeline(cmd, stderr=err), wait=false)
            wait(proc)
            if !success(proc)
                println(String(take!(err)))
                error("Plugin failed for " * file)
            end
            
            generated_jl = joinpath(dir, file * ".jl")
            @test isfile(generated_jl)
            
            golden_content = read(golden_jl, String)
            generated_content = read(generated_jl, String)
            
            @test golden_content == generated_content
        end
    end
end
