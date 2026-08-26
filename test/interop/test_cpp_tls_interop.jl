using Test
using Capnp
using Capnp.RPC
using Sockets

# Check if Reseau is installed
if Base.find_package("Reseau") === nothing
    println("Skipping C++ TLS Interoperability tests: Reseau package not installed.")
else
    using Reseau

    @testset "C++ TLS Interoperability" begin
        println("Starting C++ server...")
        cpp_server = joinpath(@__DIR__, "cpp_server_test")
        if !isfile(cpp_server)
            println("Skipping C++ TLS Interoperability tests: $cpp_server not found.")
            return
        end
        server_process = open(`$cpp_server 127.0.0.1:0`, "r+")
    cpp_port = parse(Int, split(line, ":")[2])
    println("C++ server running on port $cpp_port")

    stunnel_conf = joinpath(@__DIR__, "stunnel.conf")
    stunnel_log_file = joinpath(@__DIR__, "stunnel.log")
    certs_dir = joinpath(@__DIR__, "certs")

    function run_stunnel(conf_str)
        rm(stunnel_log_file, force = true)
        open(stunnel_conf, "w") do f
            write(f, """
            pid = $(joinpath(@__DIR__, "stunnel.pid"))
            output = $stunnel_log_file
            foreground = yes
            debug = info
            sslVersionMax = TLSv1.2
            [test]
            accept = 127.0.0.1:0
            connect = 127.0.0.1:$cpp_port
            """ * conf_str)
        end
        p = open(`stunnel $stunnel_conf`, "r+")
        sleep(1.0)
        log_content = read(stunnel_log_file, String)
        m = match(r"bound to 127\.0\.0\.1:(\d+)", log_content)
        port = parse(Int, m[1])
        return p, port
    end

    include("../../example/calculator.capnp.jl")

    @testset "Happy path - valid client cert" begin
        p, port = run_stunnel("""
        cert = $certs_dir/stunnel.pem
        CAfile = $certs_dir/ca_cert.pem
        verify = 2
        """)

        tls_config = TLSConfig(
            verify_host = true, # localhost
            ca_roots = joinpath(certs_dir, "ca_cert.pem"),
            client_cert = joinpath(certs_dir, "client_cert.pem"),
            client_key = joinpath(certs_dir, "client_key.pem"),
        )

        conn = RPC.connect("localhost", port, tls_config)
        client_cap = RPC.bootstrap(conn, RPC.RemoteCapability)
        client = Calculator_Client(client_cap)

        promise = Calculator_addAsync(client, function (payload, loc)
            Capnp.write_bits(payload, 0, Float64, 123.0)
            Capnp.write_bits(payload, 8, Float64, 456.0)
        end)
        ans = fetch(promise)

        res_ptr = Capnp.read_struct_pointer(ans, 0, 0)
        val = Capnp.read_bits(res_ptr, 0, Float64)
        @test val == 579.0

        close(conn)
        kill(p)
    end

    @testset "Negative - Invalid CA for server" begin
        p, port = run_stunnel("""
        cert = $certs_dir/stunnel.pem
        CAfile = $certs_dir/ca_cert.pem
        verify = 2
        """)

        # Missing ca_roots should cause connection failure
        tls_config = TLSConfig(verify_host = true, client_cert = joinpath(certs_dir, "client_cert.pem"), client_key = joinpath(certs_dir, "client_key.pem"))

        @test_throws Exception RPC.connect("localhost", port, tls_config)
        kill(p)
    end

    @testset "Negative - Missing client cert" begin
        p, port = run_stunnel("""
        cert = $certs_dir/stunnel.pem
        CAfile = $certs_dir/ca_cert.pem
        verify = 2
        """)

        tls_config = TLSConfig(
            verify_host = true,
            ca_roots = joinpath(certs_dir, "ca_cert.pem"),
            # No client cert
        )

        @test_throws Exception begin
            conn = RPC.connect("localhost", port, tls_config)
            # Connection might succeed but first read/write fails the handshake
            # Bootstrap implicitly reads, so it throws!
            RPC.bootstrap(conn, RPC.RemoteCapability)
        end
        kill(p)
    end

    kill(server_process)
end
end
