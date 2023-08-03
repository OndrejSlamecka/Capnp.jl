# This file provides typed containers for CapnpPointer

# todo: remove Union below: null pointer should be a CapnpPointer
abstract type TypedPointer{T<:Union{Nothing,CapnpPointer}} end

Base.getproperty(x::TypedPointer, name::Symbol) = getindex(x, Val(name))
Base.setproperty!(x::TypedPointer, name::Symbol, value) = setindex!(x, value, Val(name))
getptr(x::TypedPointer) = getfield(x, :ptr)

macro wrapptr(name)
    quote
        struct $(esc(name)){T} <: TypedPointer{T}
            ptr::T
        end
    end
end

struct ListBuilder{T,P} <: TypedPointer{P}
    ptr::P
    ListBuilder{T}(ptr::P) where {T,P} = new{T,P}(ptr)
end

struct List{T,P} <: TypedPointer{P}
    ptr::P
    List{T}(ptr::P) where {T,P} = new{T,P}(ptr)
end

Base.eltype(::List{T}) where {T} = T
Base.eltype(::Type{<:List{T}}) where {T} = T
getptr(x::List) = getfield(x, :ptr)

Base.getindex(list::List{T}, i) where {T} = getptr(list)[i] |> T

function Base.iterate(list::List{T}) where {T}
    r = iterate(getptr(list))
    isnothing(r) && return nothing
    x, state = r
    (T(x), state)
end

function Base.iterate(list::List{T}, state) where {T}
    r = iterate(getptr(list), state)
    isnothing(r) && return nothing
    x, newstate = r
    (T(x), newstate)
end

struct Void{P} <: TypedPointer{P}
    ptr::P
end
