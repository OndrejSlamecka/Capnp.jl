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
