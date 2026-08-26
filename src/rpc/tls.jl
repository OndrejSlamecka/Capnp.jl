# TLS configuration types for Cap'n Proto RPC

abstract type AbstractTLSConfig end
abstract type AbstractTLSListenerConfig end

"""
    TLSConfig

Configuration for secure TLS/mTLS RPC connections.
This structure is defined by Capnp but requires the `Reseau` package 
(via the `CapnpReseauExt` extension) to be active.
"""
Base.@kwdef struct TLSConfig <: AbstractTLSConfig
    verify_host::Bool = true
    ca_roots::Union{String,Nothing} = nothing
    client_cert::Union{String,Nothing} = nothing
    client_key::Union{String,Nothing} = nothing
    sni::Union{String,Nothing} = nothing
    alpn_protocols::Union{Vector{String},Nothing} = nothing
    handshake_timeout_ns::Union{UInt64,Nothing} = nothing
    read_timeout_ns::Union{UInt64,Nothing} = nothing
    write_timeout_ns::Union{UInt64,Nothing} = nothing
end

"""
    TLSListenerConfig

Configuration for secure TLS/mTLS RPC listeners (servers).
"""
Base.@kwdef struct TLSListenerConfig <: AbstractTLSListenerConfig
    server_cert::String
    server_key::String
    require_client_cert::Bool = false
    alpn_protocols::Union{Vector{String},Nothing} = nothing
    handshake_timeout_ns::Union{UInt64,Nothing} = nothing
    read_timeout_ns::Union{UInt64,Nothing} = nothing
    write_timeout_ns::Union{UInt64,Nothing} = nothing
    ca_roots::Union{String,Nothing} = nothing
end

function Base.show(io::IO, config::TLSConfig)
    print(io, "TLSConfig(")
    print(io, "verify_host=", config.verify_host)
    config.ca_roots !== nothing && print(io, ", ca_roots=", repr(config.ca_roots))
    config.client_cert !== nothing && print(io, ", client_cert=", repr(config.client_cert))
    config.client_key !== nothing && print(io, ", client_key=\"***REDACTED***\"")
    config.sni !== nothing && print(io, ", sni=", repr(config.sni))
    config.alpn_protocols !== nothing && print(io, ", alpn_protocols=", repr(config.alpn_protocols))
    config.handshake_timeout_ns !== nothing && print(io, ", handshake_timeout_ns=", config.handshake_timeout_ns)
    config.read_timeout_ns !== nothing && print(io, ", read_timeout_ns=", config.read_timeout_ns)
    config.write_timeout_ns !== nothing && print(io, ", write_timeout_ns=", config.write_timeout_ns)
    print(io, ")")
end

function Base.show(io::IO, config::TLSListenerConfig)
    print(io, "TLSListenerConfig(")
    print(io, "server_cert=", repr(config.server_cert))
    print(io, ", server_key=\"***REDACTED***\"")
    print(io, ", require_client_cert=", config.require_client_cert)
    config.alpn_protocols !== nothing && print(io, ", alpn_protocols=", repr(config.alpn_protocols))
    config.handshake_timeout_ns !== nothing && print(io, ", handshake_timeout_ns=", config.handshake_timeout_ns)
    config.read_timeout_ns !== nothing && print(io, ", read_timeout_ns=", config.read_timeout_ns)
    config.write_timeout_ns !== nothing && print(io, ", write_timeout_ns=", config.write_timeout_ns)
    config.ca_roots !== nothing && print(io, ", ca_roots=", repr(config.ca_roots))
    print(io, ")")
end
