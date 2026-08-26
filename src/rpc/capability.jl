# Capability types and capability table management for Cap'n Proto RPC
#
# Capabilities are the core abstraction of Cap'n Proto RPC. They represent
# references to objects (local or remote) that can be called. A capability
# table is attached to each message and maps capability indices to descriptors.

"""
Module defining capability descriptor kinds.

Each variant describes where a capability lives and how to reach it:
- NONE: Null capability (no object)
- SENDER_HOSTED: We own this capability locally
- SENDER_PROMISE: Promise to a capability we'll resolve later
- RECEIVER_HOSTED: Peer owns this capability
- RECEIVER_ANSWER: Pipelined capability from ongoing call
- THIRD_PARTY: Third-party capability handoff (Level 3)
"""
module CapDescriptorKind
@enum T begin
    NONE              # Null capability
    SENDER_HOSTED     # We own it, they're importing
    SENDER_PROMISE    # Promise we'll resolve
    RECEIVER_HOSTED   # They own it, we're importing
    RECEIVER_ANSWER   # Pipelined from call
    THIRD_PARTY       # Level 3 (future)
end
end

"""
    CapDescriptor

Describes a capability in a message's capability table.

# Fields
- `kind::CapDescriptorKind.T`: Type of capability descriptor
- `sender_hosted_id::Union{UInt32, Nothing}`: Export ID when sender-hosted
- `sender_promise_id::Union{UInt32, Nothing}`: Promise ID when sender-promise
- `receiver_hosted_id::Union{UInt32, Nothing}`: Import ID when receiver-hosted
- `receiver_answer::Union{PromisedAnswer, Nothing}`: Pipelined answer reference
"""
struct CapDescriptor
    kind::CapDescriptorKind.T
    # Union fields - only one is valid based on kind
    sender_hosted_id::Union{UInt32,Nothing}
    sender_promise_id::Union{UInt32,Nothing}
    receiver_hosted_id::Union{UInt32,Nothing}
    # receiver_answer would be PromisedAnswer, but we'll add that with RPC types
end

"""
    CapDescriptor(kind::CapDescriptorKind.T)

Create a descriptor with the given kind and no associated data.
Useful for NONE kind.
"""
function CapDescriptor(kind::CapDescriptorKind.T)
    CapDescriptor(kind, nothing, nothing, nothing)
end

"""
    sender_hosted(export_id::UInt32)

Create a sender-hosted capability descriptor.
The sender exports this capability under the given ID.
"""
function sender_hosted(export_id::UInt32)
    CapDescriptor(CapDescriptorKind.SENDER_HOSTED, export_id, nothing, nothing)
end

"""
    sender_promise(promise_id::UInt32)

Create a sender-promise capability descriptor.
The sender promises to resolve this capability later.
"""
function sender_promise(promise_id::UInt32)
    CapDescriptor(CapDescriptorKind.SENDER_PROMISE, nothing, promise_id, nothing)
end

"""
    receiver_hosted(import_id::UInt32)

Create a receiver-hosted capability descriptor.
The receiver already exported this capability; we're referencing it back.
"""
function receiver_hosted(import_id::UInt32)
    CapDescriptor(CapDescriptorKind.RECEIVER_HOSTED, nothing, nothing, import_id)
end

"""
    CapabilityTable

Table of capabilities attached to a message.
Maps capability indices (from CapabilityPointer) to descriptors.

# Fields
- `descriptors::Vector{CapDescriptor}`: List of capability descriptors

# Usage
Capability indices in messages are 0-based, but Julia vectors are 1-based.
The accessor methods handle this conversion automatically.
"""
mutable struct CapabilityTable
    descriptors::Vector{CapDescriptor}

    CapabilityTable() = new(CapDescriptor[])
end

"""
    Base.length(table::CapabilityTable) -> Int

Return the number of capabilities in the table.
"""
Base.length(table::CapabilityTable) = length(table.descriptors)

"""
    Base.isempty(table::CapabilityTable) -> Bool

Check if the table has no capabilities.
"""
Base.isempty(table::CapabilityTable) = isempty(table.descriptors)

"""
    get_descriptor(table::CapabilityTable, index::UInt32) -> CapDescriptor

Get the capability descriptor at the given 0-based index.
Throws if the index is out of bounds.
"""
function get_descriptor(table::CapabilityTable, index::UInt32)
    julia_index = Int(index) + 1  # Convert 0-based to 1-based
    if julia_index < 1 || julia_index > length(table.descriptors)
        throw(BoundsError(table.descriptors, julia_index))
    end
    table.descriptors[julia_index]
end

"""
    add_descriptor!(table::CapabilityTable, descriptor::CapDescriptor) -> UInt32

Add a capability descriptor to the table and return its 0-based index.
"""
function add_descriptor!(table::CapabilityTable, descriptor::CapDescriptor)
    push!(table.descriptors, descriptor)
    UInt32(length(table.descriptors) - 1)  # Return 0-based index
end

"""
    add_sender_hosted!(table::CapabilityTable, export_id::UInt32) -> UInt32

Convenience method to add a sender-hosted capability.
Returns the 0-based capability index.
"""
function add_sender_hosted!(table::CapabilityTable, export_id::UInt32)
    add_descriptor!(table, sender_hosted(export_id))
end

"""
    add_receiver_hosted!(table::CapabilityTable, import_id::UInt32) -> UInt32

Convenience method to add a receiver-hosted capability reference.
Returns the 0-based capability index.
"""
function add_receiver_hosted!(table::CapabilityTable, import_id::UInt32)
    add_descriptor!(table, receiver_hosted(import_id))
end

"""
    add_null!(table::CapabilityTable) -> UInt32

Add a null capability to the table.
Returns the 0-based capability index.
"""
function add_null!(table::CapabilityTable)
    add_descriptor!(table, CapDescriptor(CapDescriptorKind.NONE))
end

"""
    clear!(table::CapabilityTable)

Remove all capabilities from the table.
"""
function clear!(table::CapabilityTable)
    empty!(table.descriptors)
end

# ============================================================================
# Level 2: Persistent Capability Types
# ============================================================================

"""
    DefaultSturdyRef

Default SturdyRef implementation using opaque bytes.
A SturdyRef is a persistent reference to a capability that can survive
beyond the lifetime of a single connection.

# Fields
- `host_id::Vector{UInt8}`: Identifies the host that can restore this capability
- `object_id::Vector{UInt8}`: Identifies the specific capability on that host
"""
struct DefaultSturdyRef
    host_id::Vector{UInt8}
    object_id::Vector{UInt8}

    DefaultSturdyRef(host_id::Vector{UInt8}, object_id::Vector{UInt8}) = new(host_id, object_id)
    DefaultSturdyRef(host_id::AbstractString, object_id::AbstractString) = new(Vector{UInt8}(host_id), Vector{UInt8}(object_id))
end

"""
    DefaultOwner

Default Owner implementation for capability access control.
The owner field in SaveParams can be used for authorization checks.

# Fields
- `display_name::String`: Human-readable name for the owner
"""
struct DefaultOwner
    display_name::String

    DefaultOwner(name::AbstractString = "") = new(String(name))
end

"""
    SaveParams{Owner}

Parameters for the Persistent.save() method.
Used when requesting to persist a capability.

# Type Parameter
- `Owner`: The type used for owner/authorization info (e.g., DefaultOwner)

# Fields
- `seal_for::Owner`: Owner information for access control (optional)
"""
struct SaveParams{Owner}
    seal_for::Union{Owner,Nothing}

    SaveParams{Owner}(seal_for::Union{Owner,Nothing} = nothing) where {Owner} = new{Owner}(seal_for)
end

# Convenience constructor with default owner type
SaveParams(seal_for::Union{DefaultOwner,Nothing} = nothing) = SaveParams{DefaultOwner}(seal_for)

"""
    SaveResults{SturdyRef}

Results from the Persistent.save() method.
Contains the persistent reference to the capability.

# Type Parameter
- `SturdyRef`: The type of sturdy reference returned (e.g., DefaultSturdyRef)

# Fields
- `sturdy_ref::SturdyRef`: The persistent reference that can be used to restore the capability
"""
struct SaveResults{SturdyRef}
    sturdy_ref::SturdyRef
end

# Convenience constructor with default sturdy ref type
SaveResults(ref::DefaultSturdyRef) = SaveResults{DefaultSturdyRef}(ref)

"""
    serialize_sturdy_ref(ref::DefaultSturdyRef) -> Vector{UInt8}

Serialize a DefaultSturdyRef to bytes for transmission or storage.
Format: [host_id_len:4][host_id][object_id_len:4][object_id]
"""
function serialize_sturdy_ref(ref::DefaultSturdyRef)
    buffer = IOBuffer()
    # Write host_id length and data
    write(buffer, UInt32(length(ref.host_id)))
    write(buffer, ref.host_id)
    # Write object_id length and data
    write(buffer, UInt32(length(ref.object_id)))
    write(buffer, ref.object_id)
    return take!(buffer)
end

"""
    deserialize_sturdy_ref(data::Vector{UInt8}) -> DefaultSturdyRef

Deserialize a DefaultSturdyRef from bytes.
"""
function deserialize_sturdy_ref(data::Vector{UInt8})
    buffer = IOBuffer(data)
    # Read host_id
    host_len = read(buffer, UInt32)
    host_id = read(buffer, host_len)
    # Read object_id
    object_len = read(buffer, UInt32)
    object_id = read(buffer, object_len)
    return DefaultSturdyRef(host_id, object_id)
end

"""
    Restorer{SturdyRef, Owner}

Abstract type for restorers that can restore capabilities from SturdyRefs.
Implementations must provide:
- `restore(restorer, sturdy_ref, owner)` -> capability or exception

# Type Parameters
- `SturdyRef`: The type of sturdy reference used (e.g., DefaultSturdyRef)
- `Owner`: The type of owner for authorization (e.g., DefaultOwner)
"""
abstract type Restorer{SturdyRef,Owner} end

"""
    RestoreException

Exception thrown when restoration fails.
"""
struct RestoreException <: Exception
    reason::String
    type::Symbol  # :not_found, :unauthorized, :expired, :failed
end

"""
    RestorerRegistry{SturdyRef, Owner}

Registry that maps host IDs to their restorers and object IDs to capabilities.
Used by DefaultRestorer to look up and restore capabilities.
"""
mutable struct RestorerRegistry{SturdyRef,Owner}
    # Map from object_id bytes to capability
    capabilities::Dict{Vector{UInt8},Any}
    # Map from object_id to owner (for authorization)
    owners::Dict{Vector{UInt8},Owner}
    lock::ReentrantLock

    function RestorerRegistry{S,O}() where {S,O}
        new{S,O}(Dict{Vector{UInt8},Any}(), Dict{Vector{UInt8},O}(), ReentrantLock())
    end
end

"""
    DefaultRestorer

Default implementation of Restorer for DefaultSturdyRef.
Maintains an in-memory registry of saved capabilities.
"""
mutable struct DefaultRestorer <: Restorer{DefaultSturdyRef,DefaultOwner}
    host_id::Vector{UInt8}
    registry::RestorerRegistry{DefaultSturdyRef,DefaultOwner}

    function DefaultRestorer(host_id::Vector{UInt8})
        new(host_id, RestorerRegistry{DefaultSturdyRef,DefaultOwner}())
    end

    function DefaultRestorer(host_id::AbstractString)
        new(Vector{UInt8}(host_id), RestorerRegistry{DefaultSturdyRef,DefaultOwner}())
    end
end

"""
    register!(restorer::DefaultRestorer, object_id::Vector{UInt8}, capability, owner::DefaultOwner) -> DefaultSturdyRef

Register a capability for later restoration.
Returns a SturdyRef that can be used to restore the capability.
"""
function register!(restorer::DefaultRestorer, object_id::Vector{UInt8}, capability, owner::Union{DefaultOwner,Nothing} = DefaultOwner())
    lock(restorer.registry.lock) do
        restorer.registry.capabilities[object_id] = capability
        restorer.registry.owners[object_id] = owner === nothing ? DefaultOwner() : owner
    end
    return DefaultSturdyRef(restorer.host_id, object_id)
end

"""
    restore(restorer::DefaultRestorer, sturdy_ref::DefaultSturdyRef, owner::DefaultOwner) -> Any

Restore a capability from a SturdyRef.
This implements C003-RESTORE contract.

# Throws
- `RestoreException(:not_found, ...)` if the object_id is not registered
- `RestoreException(:unauthorized, ...)` if the owner doesn't match
"""
function restore(restorer::DefaultRestorer, sturdy_ref::DefaultSturdyRef, owner::DefaultOwner = DefaultOwner())
    # Validate host_id matches
    if sturdy_ref.host_id != restorer.host_id
        throw(RestoreException("SturdyRef host_id does not match this restorer", :not_found))
    end

    lock(restorer.registry.lock) do
        # Check if object exists
        if !haskey(restorer.registry.capabilities, sturdy_ref.object_id)
            throw(RestoreException("Capability not found", :not_found))
        end

        # Validate owner if present
        if !validate_owner(restorer, sturdy_ref.object_id, owner)
            throw(RestoreException("Owner validation failed", :unauthorized))
        end

        return restorer.registry.capabilities[sturdy_ref.object_id]
    end
end

"""
    validate_owner(restorer::DefaultRestorer, object_id::Vector{UInt8}, owner::DefaultOwner) -> Bool

Validate that the owner is authorized to restore the capability.
Default implementation: always returns true (no authorization).
"""
function validate_owner(restorer::DefaultRestorer, object_id::Vector{UInt8}, owner::DefaultOwner)
    # Default: no authorization required
    # In a real implementation, this would check owner.display_name against stored owner
    return true
end

"""
    revoke!(restorer::DefaultRestorer, object_id::Vector{UInt8}) -> Bool

Revoke a previously saved capability.
Returns true if the capability was found and revoked, false otherwise.
"""
function revoke!(restorer::DefaultRestorer, object_id::Vector{UInt8})
    lock(restorer.registry.lock) do
        if haskey(restorer.registry.capabilities, object_id)
            delete!(restorer.registry.capabilities, object_id)
            delete!(restorer.registry.owners, object_id)
            return true
        end
        return false
    end
end

# ============================================================================
# Level 2: Server-Side Persistent Capability Trait
# ============================================================================

"""
    PersistentCapability

Abstract type for capabilities that support the Persistent interface.
Server implementations should subtype this to indicate they support save().

Implementations must provide:
- `can_save(cap, owner)` -> Bool: Check if saving is allowed for this owner
- `generate_sturdy_ref(cap, owner)` -> SturdyRef: Generate a SturdyRef for this capability

This implements C004-SERVER-PERSISTENCE contract.
"""
abstract type PersistentCapability end

"""
    can_save(cap::PersistentCapability, owner) -> Bool

Check if the capability can be saved by the given owner.
Default implementation returns true (any owner can save).

Override this to implement access control for save operations.
"""
function can_save(cap::PersistentCapability, owner)
    return true
end

# Fallback for non-persistent capabilities
function can_save(cap, owner)
    return false
end

"""
    generate_sturdy_ref(cap::PersistentCapability, owner, restorer::DefaultRestorer) -> DefaultSturdyRef

Generate a SturdyRef for this capability.
The default implementation generates a unique object ID and registers with the restorer.

Override this to implement custom SturdyRef generation.
"""
function generate_sturdy_ref(cap::PersistentCapability, owner, restorer::DefaultRestorer)
    # Generate a unique object ID based on object identity
    object_id = Vector{UInt8}(string(objectid(cap)))
    return register!(restorer, object_id, cap, owner)
end

"""
    is_persistent(cap) -> Bool

Check if a capability implements the PersistentCapability trait.
"""
function is_persistent(cap)
    return cap isa PersistentCapability
end

"""
    SimplePersistentCapability

A simple wrapper that makes any capability persistent.
Use this when you want to quickly make an existing capability persistent
without creating a custom subtype.
"""
mutable struct SimplePersistentCapability <: PersistentCapability
    wrapped::Any
    object_id::Vector{UInt8}

    function SimplePersistentCapability(wrapped, object_id::Vector{UInt8} = Vector{UInt8}(string(objectid(wrapped))))
        new(wrapped, object_id)
    end

    function SimplePersistentCapability(wrapped, object_id::AbstractString)
        new(wrapped, Vector{UInt8}(object_id))
    end
end

"""
    generate_sturdy_ref(cap::SimplePersistentCapability, owner, restorer::DefaultRestorer) -> DefaultSturdyRef

Generate a SturdyRef for a SimplePersistentCapability using its stored object_id.
"""
function generate_sturdy_ref(cap::SimplePersistentCapability, owner, restorer::DefaultRestorer)
    return register!(restorer, cap.object_id, cap.wrapped, owner)
end

# Export public types and functions
export CapDescriptorKind, CapDescriptor, CapabilityTable
export sender_hosted, sender_promise, receiver_hosted
export get_descriptor, add_descriptor!, add_sender_hosted!, add_receiver_hosted!, add_null!, clear!

# Level 2: Persistent capability types
export DefaultSturdyRef, DefaultOwner, SaveParams, SaveResults
export serialize_sturdy_ref, deserialize_sturdy_ref

# Level 2: Restorer types
export Restorer, RestoreException, RestorerRegistry, DefaultRestorer
export register!, restore, validate_owner, revoke!

# Level 2: Server-side persistence types
export PersistentCapability, SimplePersistentCapability
export can_save, generate_sturdy_ref, is_persistent
