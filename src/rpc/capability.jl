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
    sender_hosted_id::Union{UInt32, Nothing}
    sender_promise_id::Union{UInt32, Nothing}
    receiver_hosted_id::Union{UInt32, Nothing}
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

# Export public types and functions
export CapDescriptorKind, CapDescriptor, CapabilityTable
export sender_hosted, sender_promise, receiver_hosted
export get_descriptor, add_descriptor!, add_sender_hosted!, add_receiver_hosted!, add_null!, clear!
