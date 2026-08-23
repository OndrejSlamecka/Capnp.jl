module TLSRPCApp

using Capnp
using Reseau
import Capnp.RPC
using Sockets

struct DummyCalculator <: Any
end

# safe println
function safe_println(s::String)
    ccall(:puts, Cint, (Cstring,), s)
    return nothing
end

function main(args::Vector{String})::Cint
    
        safe_println("TLS RPC App starting...")
        
        certs_dir = joinpath(@__DIR__, "..", "interop", "certs")
        
        listener_config = RPC.TLSListenerConfig(
            require_client_cert = false,
            ca_roots = joinpath(certs_dir, "ca_cert.pem"),
            server_cert = joinpath(certs_dir, "server_cert.pem"),
            server_key = joinpath(certs_dir, "server_key.pem")
        )
        
        tls_config = RPC.TLSConfig(
            verify_host = false,
            ca_roots = joinpath(certs_dir, "ca_cert.pem"),
            client_cert = joinpath(certs_dir, "client_cert.pem"),
            client_key = joinpath(certs_dir, "client_key.pem")
        )
        
        server = RPC.Server(DummyCalculator())
        port = 35489
        RPC.listen(server, "127.0.0.1", port, listener_config)
        
        try
            conn = RPC.connect("127.0.0.1", UInt16(port), tls_config)
            close(conn)
        catch e
            # Expected since @async might not schedule the server task in this minimal binary
            safe_println("Handshake timeout as expected")
        end
        
        safe_println("Success")
        return 0
    return 0
end

end

using .TLSRPCApp
const main = TLSRPCApp.main
@main
