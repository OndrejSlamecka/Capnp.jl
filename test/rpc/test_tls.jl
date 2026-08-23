using Test
using Capnp
using Capnp.RPC
using Reseau

@testset "TLS Extension" begin
    @test Base.get_extension(Capnp, :CapnpReseauExt) !== nothing

    # Use Reseau's test certificates
    reseau_dir = pkgdir(Reseau)
    cert_dir = joinpath(reseau_dir, "test", "resources")
    server_cert = joinpath(cert_dir, "native_tls_server.crt")
    server_key = joinpath(cert_dir, "native_tls_server.key")
    client_cert = joinpath(cert_dir, "native_tls_client.crt")
    client_key = joinpath(cert_dir, "native_tls_client.key")
    ca_roots = joinpath(cert_dir, "native_tls_ca.crt")

    @testset "Server and Client integration" begin
        # 1. Start a TLS server
        server = RPC.Server(nothing)
        listener_config = RPC.TLSListenerConfig(server_cert = server_cert, server_key = server_key, ca_roots = ca_roots, require_client_cert = false)

        # Test error if Reseau not loaded logic (we can't easily unload Reseau, so we just check it compiles)
        # We start the server on an ephemeral port if possible, or just a random port
        port = 8443
        RPC.listen(server, "127.0.0.1", port, listener_config)

        # Give it a moment to start
        sleep(0.5)

        @test RPC.is_running(server)

        # 2. Connect client
        client_config = RPC.TLSConfig(
            ca_roots = ca_roots,
            client_cert = client_cert,
            client_key = client_key,
            verify_host = false, # we use IP address, cert has localhost
        )

        conn = RPC.connect("127.0.0.1", port, client_config)
        @test isopen(conn.transport)

        # Close connection and server
        close(conn)
        RPC.set_running!(server, false)
        try
            close(server.tcp_server)
        catch
        end
    end
end
