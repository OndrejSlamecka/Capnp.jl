module PlainRPCApp
using Capnp
using Capnp.RPC
using Sockets

struct DummyCalculator end

function safe_println(s::String)
    ccall(:puts, Cint, (Cstring,), s)
end

function main(args::Vector{String})::Cint
    try
        safe_println("Plain RPC App starting...")
        
        server = RPC.Server(DummyCalculator())
        RPC.listen(server, "127.0.0.1", 0)
        
        safe_println("Listening...")
        RPC.shutdown!(server)
        safe_println("Success")
        
        return 0
    catch e
        safe_println("Error")
        return 1
    end
end
end

using .PlainRPCApp
const main = PlainRPCApp.main
@main
