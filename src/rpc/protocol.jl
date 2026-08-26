# Cap'n Proto RPC Protocol Message Parsing (Level 0)
#
# This module provides parsing for the Cap'n Proto RPC protocol messages
# as defined in rpc.capnp. It implements Level 0 (basic) message handling.
#
# Message types for Level 0:
# - Bootstrap: Client requests the root capability
# - Call: Client calls a method on a capability
# - Return: Server responds to a call
# - Finish: Client is done with a question
# - Release: Client releases a capability reference

# ============================================================================
# Persistent interface constants (from persistent.capnp, Level 2 RPC)
# ============================================================================

"""
Persistent interface ID from persistent.capnp.
Interface ID: 0xc8cb212fcd9f5691
"""
const PERSISTENT_INTERFACE_ID = 0xc8cb212fcd9f5691

"""
Persistent annotation ID.
Used to mark interfaces as always persistent.
"""
const PERSISTENT_ANNOTATION_ID = 0x91b79d1f17716c18

"""
Method ID for Persistent.save()
"""
const PERSISTENT_SAVE_METHOD_ID = UInt16(0)

# SaveParams struct layout:
# - sealFor @0 :Owner (pointer 0)
const SaveParams_data_word_count = 0
const SaveParams_pointer_count = 1

# SaveResults struct layout:
# - sturdyRef @0 :SturdyRef (pointer 0)
const SaveResults_data_word_count = 0
const SaveResults_pointer_count = 1

"""
RPC Message type discriminants from rpc.capnp Message union.
"""
module MessageType
@enum T::UInt16 begin
    UNIMPLEMENTED = 0
    ABORT = 1
    CALL = 2
    RETURN = 3
    FINISH = 4
    RESOLVE = 5
    RELEASE = 6
    OBSOLETE_DELETE = 7
    BOOTSTRAP = 8
    PROVIDE = 9
    ACCEPT = 10
    JOIN = 11
    OBSOLETE_SAVE = 12
    DISEMBARGO = 13
end
end

"""
Return union type discriminants from rpc.capnp Return struct.
"""
module ReturnType
@enum T::UInt16 begin
    RESULTS = 0
    EXCEPTION = 1
    CANCELED = 2
    RESULTS_SENT_ELSEWHERE = 3
    TAKE_FROM_OTHER_QUESTION = 4
    ACCEPT_FROM_THIRD_PARTY = 5
end
end

"""
MessageTarget union type discriminants.
"""
module MessageTargetType
@enum T::UInt16 begin
    IMPORTED_CAP = 0
    PROMISED_ANSWER = 1
    RECEIVER_HOSTED = 2  # receiverHosted targets an export in the server's export table
end
end

"""
SendResultsTo union type discriminants.
"""
module SendResultsToType
@enum T::UInt16 begin
    CALLER = 0
    YOURSELF = 1
    THIRD_PARTY = 2
end
end

"""
Resolve union type discriminants from rpc.capnp Resolve struct.
Level 2: Promise resolution message types.
"""
module ResolveType
@enum T::UInt16 begin
    CAP = 0        # Resolved to a capability
    EXCEPTION = 1  # Resolved to an exception
end
end

"""
CapDescriptor union type discriminants from rpc.capnp.
Describes how a capability is represented in a message's capability table.
"""
module CapDescriptorType
@enum T::UInt16 begin
    NONE = 0
    SENDER_HOSTED = 1
    SENDER_PROMISE = 2
    RECEIVER_HOSTED = 3
    RECEIVER_ANSWER = 4
    THIRD_PARTY_HOSTED = 5
end
end

"""
PromisedAnswer.Op union type discriminants.
Operations for navigating a promised answer.
"""
module PromisedAnswerOpType
@enum T::UInt16 begin
    NOOP = 0
    GET_POINTER_FIELD = 1
end
end

"""
    PromisedAnswerOp

Operation for navigating a promised answer (getPointerField).
"""
struct PromisedAnswerOp
    kind::PromisedAnswerOpType.T
    get_pointer_field::Union{UInt16,Nothing}  # For GET_POINTER_FIELD kind
end

"""
    ParsedPromisedAnswer

Reference to a promised answer for capability addressing.
Used in MessageTarget.promisedAnswer and CapDescriptor.receiverAnswer.
"""
struct ParsedPromisedAnswer
    question_id::QuestionId
    transform::Vector{PromisedAnswerOp}
end

"""
    ParsedCapDescriptor

Parsed CapDescriptor from a message's capability table.
Describes how a capability is represented.
"""
struct ParsedCapDescriptor
    kind::CapDescriptorType.T
    sender_hosted::Union{ExportId,Nothing}      # kind = SENDER_HOSTED
    sender_promise::Union{ExportId,Nothing}     # kind = SENDER_PROMISE
    receiver_hosted::Union{ImportId,Nothing}    # kind = RECEIVER_HOSTED
    receiver_answer::Union{ParsedPromisedAnswer,Nothing}  # kind = RECEIVER_ANSWER
    # third_party_hosted not implemented for Level 2
end

"""
    ParsedBootstrap

Parsed Bootstrap message data.
"""
struct ParsedBootstrap
    question_id::QuestionId
end

"""
    ParsedMessageTarget

Parsed MessageTarget from a Call message.
"""
struct ParsedReturn
    answer_id::AnswerId
    release_param_caps::Bool
    kind::ReturnType.T
    # If kind == RESULTS
    payload_ptr::Union{Capnp.StructPointer,Nothing}
    cap_table::Vector{ParsedCapDescriptor}
    # If kind == EXCEPTION
    exception_reason::Union{String,Nothing}
    exception_type::Union{ExceptionType.T,Nothing}
end

struct ParsedMessageTarget
    kind::MessageTargetType.T
    imported_cap::Union{ImportId,Nothing}
    promised_answer::Union{ParsedPromisedAnswer,Nothing}

    ParsedMessageTarget(kind::MessageTargetType.T, imported::Union{ImportId,Nothing} = nothing, pa::Union{ParsedPromisedAnswer,Nothing} = nothing) = new(kind, imported, pa)
end

"""
    ParsedCall

Parsed Call message data.
"""
struct ParsedCall
    question_id::QuestionId
    target::ParsedMessageTarget
    interface_id::UInt64
    method_id::UInt16
    params::Any
end

"""
    ParsedFinish

Parsed Finish message data.
"""
struct ParsedFinish
    question_id::QuestionId
    release_result_caps::Bool
end

"""
    ParsedRelease

Parsed Release message data.
"""
struct ParsedRelease
    id::ImportId
    reference_count::UInt32
end

"""
    ParsedResolve

Parsed Resolve message data (Level 2).
Resolve notifies the receiver that a promised capability has resolved.
"""
struct ParsedResolve
    promise_id::ExportId           # ID of the promise being resolved
    kind::ResolveType.T            # cap or exception
    cap_descriptor::Union{ParsedCapDescriptor,Nothing}  # If kind == CAP
    exception_reason::Union{String,Nothing}             # If kind == EXCEPTION
    exception_type::Union{ExceptionType.T,Nothing}      # If kind == EXCEPTION
end


"""
    ParsedMessage

Union type for parsed RPC messages.
"""
struct ParsedMessage
    type::MessageType.T
    bootstrap::Union{ParsedBootstrap,Nothing}
    call::Union{ParsedCall,Nothing}
    finish::Union{ParsedFinish,Nothing}
    release::Union{ParsedRelease,Nothing}
    resolve::Union{ParsedResolve,Nothing}  # Level 2
    return_msg::Union{ParsedReturn,Nothing}
end

"""
    parse_rpc_message(reader::Capnp.MessageReader) -> ParsedMessage

Parse an incoming RPC message from a Cap'n Proto message reader.
"""
function parse_rpc_message(reader::Capnp.MessageReader)
    # Get the root struct pointer - this is the Message struct
    # Message is a struct containing a union
    # The union discriminant is at data offset 0 (UInt16)

    seg = reader.segments[1]
    root_ptr = get_struct_pointer(seg, 1)  # Root pointer at word 0 (1-based: word 1)

    if root_ptr === nothing
        throw(RemoteException("Invalid RPC message: null root pointer", ExceptionType.FAILED))
    end

    # Decode the struct pointer to get data/pointer section locations
    data_offset, data_size, _ptr_count = decode_struct_pointer(root_ptr)

    # Calculate the actual data section location
    # The offset in a struct pointer is relative to the END of the pointer word
    # Root pointer is at word 1 (1-based), so struct data starts at word (1 + 1 + offset) = 2 + offset
    # In Cap'n Proto: pointer at word 0, offset is words from END of pointer to START of struct
    struct_start = 2 + data_offset  # 1 for root pointer word, 1 for 1-based indexing adjustment

    # Read the union discriminant (UInt16 at offset 0 of data section)
    msg_type_raw = read_data_field(seg, struct_start, 0, UInt16)
    msg_type = MessageType.T(msg_type_raw)

    # Pointer section starts after data section
    ptr_section_start = struct_start + data_size

    if msg_type == MessageType.BOOTSTRAP
        return parse_bootstrap(seg, ptr_section_start)
    elseif msg_type == MessageType.CALL
        return parse_call(reader, seg, struct_start, ptr_section_start)
    elseif msg_type == MessageType.FINISH
        return parse_finish(seg, ptr_section_start)
    elseif msg_type == MessageType.RELEASE
        return parse_release(seg, ptr_section_start)
    elseif msg_type == MessageType.RESOLVE
        return parse_resolve(seg, ptr_section_start)
    elseif msg_type == MessageType.RETURN
        return parse_return(reader, seg, struct_start, ptr_section_start)
    else
        # Return an unimplemented message for unsupported types
        return ParsedMessage(msg_type, nothing, nothing, nothing, nothing, nothing, nothing)
    end
end

"""
Helper to get a struct pointer from a segment at word offset.
"""
function get_struct_pointer(seg::Vector{UInt8}, word_offset::Int)
    byte_offset = (word_offset - 1) * 8 + 1  # Julia 1-based
    if byte_offset + 7 > length(seg)
        return nothing
    end
    reinterpret(UInt64, @view seg[byte_offset:(byte_offset+7)])[1]
end

"""
Decode a struct pointer into offset and sizes.
Returns (data_offset_words, data_size_words, pointer_count).
"""
function decode_struct_pointer(ptr::UInt64)
    # Struct pointer format:
    # Bits 0-1: 0 (struct pointer type)
    # Bits 2-31: Offset (signed, in words from end of pointer to start of struct)
    # Bits 32-47: Data section size (in words)
    # Bits 48-63: Pointer section size (in pointers)

    ptr_type = ptr & 0x3
    if ptr_type != 0
        throw(ArgumentError("Not a struct pointer: type = $ptr_type"))
    end

    offset_raw = (ptr >> 2) & 0x3FFFFFFF
    # Sign-extend from 30 bits
    if offset_raw & 0x20000000 != 0
        offset = Int(offset_raw) - 0x40000000
    else
        offset = Int(offset_raw)
    end

    data_size = Int((ptr >> 32) & 0xFFFF)
    ptr_count = Int((ptr >> 48) & 0xFFFF)

    return (offset, data_size, ptr_count)
end

"""
Read a data field from a segment.
"""
function read_data_field(seg::Vector{UInt8}, struct_word::Int, byte_offset::Int, ::Type{T}) where {T}
    byte_pos = (struct_word - 1) * 8 + byte_offset + 1  # Julia 1-based
    if byte_pos + sizeof(T) - 1 > length(seg)
        return zero(T)  # Default value for out-of-bounds
    end
    reinterpret(T, @view seg[byte_pos:(byte_pos+sizeof(T)-1)])[1]
end

"""
Parse a Bootstrap message.
Bootstrap struct layout:
- Data section: none for the base Message (discriminant only)
- Pointer 0: Bootstrap struct
  - Bootstrap.questionId: UInt32 at data offset 0
"""
function parse_bootstrap(seg::Vector{UInt8}, ptr_section_start::Int)
    # The bootstrap data is pointed to by pointer 0 in Message's pointer section
    bootstrap_ptr = get_struct_pointer(seg, ptr_section_start)

    if bootstrap_ptr === nothing || bootstrap_ptr == 0
        throw(RemoteException("Invalid Bootstrap message: null pointer", ExceptionType.FAILED))
    end

    # Decode the Bootstrap struct pointer
    boot_offset, _boot_data_size, _boot_ptr_count = decode_struct_pointer(bootstrap_ptr)

    # Bootstrap struct starts at: pointer_word + 1 + offset
    # ptr_section_start is the word containing the pointer (1-based)
    # offset is relative to the end of that word
    boot_start = ptr_section_start + 1 + boot_offset

    # Read questionId (UInt32 at data offset 0)
    question_id = read_data_field(seg, boot_start, 0, UInt32)

    bootstrap = ParsedBootstrap(QuestionId(question_id))
    return ParsedMessage(MessageType.BOOTSTRAP, bootstrap, nothing, nothing, nothing, nothing, nothing)
end

"""
Parse a Call message.
Call struct layout in Message pointer section at pointer 0:
- Data section (packed by Cap'n Proto):
  - Word 0: questionId (UInt32 at byte 0), methodId (UInt16 at byte 4), sendResultsTo discriminant (UInt16 at byte 6)
  - Word 1: interfaceId (UInt64 at byte 8)
  - Word 2: allowThirdPartyTailCall (Bool at bit 0 of byte 16)
- Pointer section:
  - target: MessageTarget at pointer 0
  - params: Payload at pointer 1
"""
function parse_call(reader::Capnp.MessageReader, seg::Vector{UInt8}, _msg_struct_start::Int, msg_ptr_section_start::Int)
    # The Call data is pointed to by pointer 0 in Message's pointer section
    call_ptr = get_struct_pointer(seg, msg_ptr_section_start)

    if call_ptr === nothing || call_ptr == 0
        throw(RemoteException("Invalid Call message: null pointer", ExceptionType.FAILED))
    end

    # Decode the Call struct pointer
    call_offset, call_data_size, _call_ptr_count = decode_struct_pointer(call_ptr)
    # Call struct starts at: pointer_word + 1 + offset (offset is from end of pointer)
    call_start = msg_ptr_section_start + 1 + call_offset
    call_ptr_section = call_start + call_data_size

    # Read Call fields from data section
    # Call struct layout determined empirically from C++ messages:
    # - questionId @0 :UInt32 at offset 0
    # - methodId @3 :UInt16 at offset 4
    # - interfaceId @2 :UInt64 at offset 8
    question_id = read_data_field(seg, call_start, 0, UInt32)
    method_id = read_data_field(seg, call_start, 4, UInt16)
    interface_id = read_data_field(seg, call_start, 8, UInt64)

    # Parse target (MessageTarget at pointer 0 of Call)
    target = parse_message_target(seg, call_ptr_section)

    # Parse params (Payload at pointer 1 of Call)
    params = parse_params(reader, seg, call_ptr_section + 1)

    call = ParsedCall(QuestionId(question_id), target, interface_id, method_id, params)

    return ParsedMessage(MessageType.CALL, nothing, call, nothing, nothing, nothing, nothing)
end

"""
Parse method parameters from Payload.content.
Payload struct:
- Pointer 0: content (AnyPointer - points to params struct)
- Pointer 1: capTable (list of CapDescriptor)

For Calculator methods, params struct layout:
- Word 0: left (Float64)
- Word 1: right (Float64)
"""
function parse_params(reader::Capnp.MessageReader, seg::Vector{UInt8}, payload_ptr_word::Int)
    # Get Payload pointer
    payload_ptr = get_struct_pointer(seg, payload_ptr_word)
    if payload_ptr === nothing || payload_ptr == 0
        return nothing
    end

    # Decode Payload pointer
    payload_offset, _payload_data_size, _payload_ptr_count = decode_struct_pointer(payload_ptr)
    payload_start = payload_ptr_word + 1 + payload_offset
    # Payload has 0 data words, 2 pointers (content, capTable)
    # content pointer is at payload_start (word 0 of pointer section)

    # Get content pointer (params struct)
    content_ptr = get_struct_pointer(seg, payload_start)
    if content_ptr === nothing || content_ptr == 0
        return nothing
    end

    # Decode content pointer to get params struct location
    content_offset, content_data_size, content_ptr_count = decode_struct_pointer(content_ptr)
    params_start = payload_start + 1 + content_offset

    # Return a generic StructPointer representing the params
    # segment_id is 1 because we only support single-segment messages currently in RPC
    return Capnp.StructPointer(reader, UInt32(1), UInt32(params_start - 1), UInt16(content_data_size), UInt16(content_ptr_count))
end

"""
    parse_cap_descriptor(seg, cap_desc_start, cap_desc_data_size) -> ParsedCapDescriptor

Parse a CapDescriptor struct from the capability table.
CapDescriptor layout:
- discriminant: UInt16 at data offset 0
- senderHosted/senderPromise/receiverHosted: UInt32 at data offset 4
- receiverAnswer: pointer in pointer section
"""
function parse_cap_descriptor(seg::Vector{UInt8}, cap_desc_start::Int, cap_desc_data_size::Int)
    # Read discriminant
    kind_raw = read_data_field(seg, cap_desc_start, 0, UInt16)
    kind = CapDescriptorType.T(kind_raw)

    if kind == CapDescriptorType.NONE
        return ParsedCapDescriptor(kind, nothing, nothing, nothing, nothing)
    elseif kind == CapDescriptorType.SENDER_HOSTED
        export_id = read_data_field(seg, cap_desc_start, 4, UInt32)
        return ParsedCapDescriptor(kind, ExportId(export_id), nothing, nothing, nothing)
    elseif kind == CapDescriptorType.SENDER_PROMISE
        export_id = read_data_field(seg, cap_desc_start, 4, UInt32)
        return ParsedCapDescriptor(kind, nothing, ExportId(export_id), nothing, nothing)
    elseif kind == CapDescriptorType.RECEIVER_HOSTED
        import_id = read_data_field(seg, cap_desc_start, 4, UInt32)
        return ParsedCapDescriptor(kind, nothing, nothing, ImportId(import_id), nothing)
    elseif kind == CapDescriptorType.RECEIVER_ANSWER
        # Parse PromisedAnswer from pointer section
        ptr_section_start = cap_desc_start + cap_desc_data_size
        promised_answer = parse_promised_answer(seg, ptr_section_start)
        return ParsedCapDescriptor(kind, nothing, nothing, nothing, promised_answer)
    else
        # THIRD_PARTY_HOSTED - not implemented
        return ParsedCapDescriptor(kind, nothing, nothing, nothing, nothing)
    end
end

"""
    parse_promised_answer(seg, ptr_section_start) -> ParsedPromisedAnswer

Parse a PromisedAnswer struct from a pointer.
PromisedAnswer layout:
- questionId: UInt32 at data offset 0
- transform: List(Op) at pointer 0
"""
function parse_promised_answer(seg::Vector{UInt8}, ptr_section_start::Int)
    # Get the PromisedAnswer pointer
    pa_ptr = get_struct_pointer(seg, ptr_section_start)

    if pa_ptr === nothing || pa_ptr == 0
        return ParsedPromisedAnswer(QuestionId(0), PromisedAnswerOp[])
    end

    # Decode the PromisedAnswer struct
    pa_offset, pa_data_size, _ = decode_struct_pointer(pa_ptr)
    pa_start = ptr_section_start + 1 + pa_offset

    # Read questionId
    question_id = read_data_field(seg, pa_start, 0, UInt32)

    # Parse transform list (at pointer 0)
    # For now, return empty transform - can be extended later
    transform = PromisedAnswerOp[]

    return ParsedPromisedAnswer(QuestionId(question_id), transform)
end

"""
Parse a MessageTarget struct.
MessageTarget is a union:
- discriminant at data offset 0 (UInt16)
- importedCap: UInt32 at data offset 4
- promisedAnswer: struct at pointer 0
"""
function parse_message_target(seg::Vector{UInt8}, call_ptr_section::Int)
    # Get the target struct pointer
    target_ptr = get_struct_pointer(seg, call_ptr_section)

    if target_ptr === nothing || target_ptr == 0
        # Default to imported cap 0 (bootstrap capability)
        return ParsedMessageTarget(MessageTargetType.IMPORTED_CAP, ImportId(0))
    end

    # Decode the MessageTarget struct
    target_offset, target_data_size, target_ptr_count = decode_struct_pointer(target_ptr)
    # Target struct starts at: pointer_word + 1 + offset
    target_start = call_ptr_section + 1 + target_offset

    # Read discriminant
    target_type_raw = read_data_field(seg, target_start, 0, UInt16)

    # Handle discriminant
    if target_type_raw == 0  # importedCap
        import_id = read_data_field(seg, target_start, 4, UInt32)
        return ParsedMessageTarget(MessageTargetType.IMPORTED_CAP, ImportId(import_id))
    elseif target_type_raw == 1  # promisedAnswer
        pa_ptr_section = target_start + target_data_size
        pa = parse_promised_answer(seg, pa_ptr_section)
        return ParsedMessageTarget(MessageTargetType.PROMISED_ANSWER, nothing, pa)
    else
        # Non-standard discriminant: Some C++ RPC implementations send the export_id as the
        # discriminant when calling a receiver-hosted capability. This is a workaround to
        # interpret such messages by treating the discriminant value as the import_id.
        @debug "Non-standard MessageTarget discriminant: treating as importedCap" target_type_raw
        return ParsedMessageTarget(MessageTargetType.IMPORTED_CAP, ImportId(target_type_raw))
    end
end

"""
Parse a Finish message.
Finish struct layout:
- questionId: UInt32 at data offset 0
- releaseResultCaps: Bool at data offset 4
"""
function parse_finish(seg::Vector{UInt8}, ptr_section_start::Int)
    # Get the Finish struct pointer from Message pointer section
    finish_ptr = get_struct_pointer(seg, ptr_section_start)

    if finish_ptr === nothing || finish_ptr == 0
        throw(RemoteException("Invalid Finish message: null pointer", ExceptionType.FAILED))
    end

    data_offset, data_size, _ptr_count = decode_struct_pointer(finish_ptr)
    struct_start = ptr_section_start + 1 + data_offset

    if data_size >= 1
        # questionId: UInt32 at offset 0
        qid = QuestionId(read_data_field(seg, struct_start, 0, UInt32))

        # releaseResultCaps: Bool at offset 4 (bit 0), default is true (XOR decoded)
        release_caps = true
        # Offset 4 is in the first word, so data_size >= 1 is sufficient
        if data_size >= 1
            raw_bool = read_data_field(seg, struct_start, 4, UInt8)
            release_caps = (raw_bool & 0x01) == 0
        end
        return ParsedMessage(MessageType.FINISH, nothing, nothing, ParsedFinish(qid, release_caps), nothing, nothing, nothing)
    end

    return ParsedMessage(MessageType.FINISH, nothing, nothing, ParsedFinish(QuestionId(0), true), nothing, nothing, nothing)
end

"""
Parse a Release message.
Release struct layout:
- id: UInt32 at data offset 0
- referenceCount: UInt32 at data offset 4
"""
function parse_release(seg::Vector{UInt8}, ptr_section_start::Int)
    # Get the Release struct pointer
    release_ptr = get_struct_pointer(seg, ptr_section_start)

    if release_ptr === nothing || release_ptr == 0
        return ParsedMessage(MessageType.RELEASE, nothing, nothing, nothing, ParsedRelease(ImportId(0), UInt32(1)), nothing, nothing)
    end

    # Decode the Release struct
    rel_offset, _rel_data_size, _ = decode_struct_pointer(release_ptr)
    # Release struct starts at: pointer_word + 1 + offset
    rel_start = ptr_section_start + 1 + rel_offset

    id = read_data_field(seg, rel_start, 0, UInt32)
    ref_count = read_data_field(seg, rel_start, 4, UInt32)

    release = ParsedRelease(ImportId(id), ref_count)
    return ParsedMessage(MessageType.RELEASE, nothing, nothing, nothing, release, nothing, nothing)
end

"""
Parse a Resolve message.
Resolve struct layout (per rpc.capnp):
- promiseId @0: ExportId (UInt32 at data offset 0)
- union discriminant: UInt16 at data offset 4
  - cap @1: CapDescriptor at pointer 0
  - exception @2: Exception at pointer 0
"""
function parse_resolve(seg::Vector{UInt8}, ptr_section_start::Int)
    # Get the Resolve struct pointer
    resolve_ptr = get_struct_pointer(seg, ptr_section_start)

    if resolve_ptr === nothing || resolve_ptr == 0
        throw(RemoteException("Invalid Resolve message: null pointer", ExceptionType.FAILED))
    end

    # Decode the Resolve struct
    res_offset, res_data_size, _ = decode_struct_pointer(resolve_ptr)
    res_start = ptr_section_start + 1 + res_offset
    res_ptr_section = res_start + res_data_size

    # Read promiseId (UInt32 at data offset 0)
    promise_id = read_data_field(seg, res_start, 0, UInt32)

    # Read union discriminant (UInt16 at data offset 4)
    kind_raw = read_data_field(seg, res_start, 4, UInt16)
    kind = ResolveType.T(kind_raw)

    if kind == ResolveType.CAP
        # Parse CapDescriptor at pointer 0
        cap_desc_ptr = get_struct_pointer(seg, res_ptr_section)
        if cap_desc_ptr === nothing || cap_desc_ptr == 0
            # Empty capability descriptor
            cap_desc = ParsedCapDescriptor(CapDescriptorType.NONE, nothing, nothing, nothing, nothing)
        else
            cap_offset, cap_data_size, _ = decode_struct_pointer(cap_desc_ptr)
            cap_start = res_ptr_section + 1 + cap_offset
            cap_desc = parse_cap_descriptor(seg, cap_start, cap_data_size)
        end
        resolve = ParsedResolve(ExportId(promise_id), kind, cap_desc, nothing, nothing)
    else
        # Parse Exception at pointer 0
        # Exception struct: reason @0 :Text, type @3 :UInt16 at offset 4
        exc_ptr = get_struct_pointer(seg, res_ptr_section)
        exception_reason = ""
        exception_type = ExceptionType.FAILED

        if exc_ptr !== nothing && exc_ptr != 0
            exc_offset, exc_data_size, _ = decode_struct_pointer(exc_ptr)
            exc_start = res_ptr_section + 1 + exc_offset
            exc_ptr_section = exc_start + exc_data_size

            # Read exception type (UInt16 at data offset 4)
            type_raw = read_data_field(seg, exc_start, 4, UInt16)
            if type_raw <= 3
                exception_type = ExceptionType.T(type_raw)
            end

            # Parse reason text at pointer 0
            text_ptr = get_struct_pointer(seg, exc_ptr_section)
            if text_ptr !== nothing && text_ptr != 0
                # Text list pointer
                list_type = text_ptr & 0x3
                if list_type == 1  # List pointer
                    list_offset = Int((text_ptr >> 2) & 0x3FFFFFFF)
                    # Sign extend
                    if list_offset & 0x20000000 != 0
                        list_offset -= 0x40000000
                    end
                    elem_count = Int((text_ptr >> 35) & 0x1FFFFFFF)
                    text_start = (exc_ptr_section + list_offset) * 8 + 1
                    # Read bytes (elem_count includes NUL terminator)
                    if text_start > 0 && text_start + elem_count - 1 <= length(seg)
                        text_bytes = seg[text_start:(text_start+elem_count-2)]  # Exclude NUL
                        exception_reason = String(text_bytes)
                    end
                end
            end
        end
        resolve = ParsedResolve(ExportId(promise_id), kind, nothing, exception_reason, exception_type)
    end

    return ParsedMessage(MessageType.RESOLVE, nothing, nothing, nothing, nothing, resolve, nothing)
end
# ============================================================================
# Bootstrap Message Builder
# ============================================================================

"""Build a Bootstrap request for `question_id` in stream-framed wire format."""
function build_bootstrap_request(question_id::QuestionId)
    segment = zeros(UInt8, 4 * 8)

    root_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 1, reinterpret(UInt8, [root_ptr]), 1, 8)
    copyto!(segment, 9, reinterpret(UInt8, [UInt16(MessageType.BOOTSTRAP)]), 1, 2)

    bootstrap_ptr = UInt64(0) | (UInt64(1) << 32)
    copyto!(segment, 17, reinterpret(UInt8, [bootstrap_ptr]), 1, 8)
    copyto!(segment, 25, reinterpret(UInt8, [UInt32(question_id)]), 1, 4)

    message = Vector{UInt8}(undef, 8 + length(segment))
    Capnp._store_le_uint32!(message, 1, 0)
    Capnp._store_le_uint32!(message, 5, 4)
    copyto!(message, 9, segment, 1, length(segment))
    return message
end


# ============================================================================
# Return Message Builder
# ============================================================================

"""
    build_return_message(answer_id::AnswerId, result::Any;
                        has_exception::Bool=false,
                        exception_reason::String="",
                        exception_type::ExceptionType.T=ExceptionType.FAILED) -> Vector{UInt8}

Build a Return message to send back to the client.
"""
function build_return_message(answer_id::AnswerId, result::Any; has_exception::Bool = false, exception_reason::String = "", _exception_type::ExceptionType.T = ExceptionType.FAILED)
    # For a simple implementation, we create a minimal Return message
    # Message struct with Return union variant

    # We need to build:
    # 1. Message struct (root) with union discriminant = RETURN (3)
    # 2. Return struct pointed from Message pointer 0

    # If the result is an ExportId, return a capability using build_capability_return
    if result isa ExportId
        return build_capability_return(answer_id, result)
    end

    # Handle exception case
    if has_exception
        return build_exception_return(answer_id, exception_reason, _exception_type)
    end

    # Otherwise, build a minimal return message with Float64 result
    buffer = build_minimal_return(answer_id, result)
    return buffer
end

"""
    build_exception_return(answer_id::AnswerId, reason::String, exception_type::ExceptionType.T) -> Vector{UInt8}

Build a Return message with an exception.

Return struct (union discriminant = 1 for exception):
- answerId @0: UInt32
- releaseParamCaps @1: Bool (default true)
- union discriminant at offset 6: 1 (exception)
- pointer[0]: Exception struct

Exception struct (1 data word, 1 pointer):
- type @3: UInt16 at offset 4 (0=failed, 1=overloaded, 2=disconnected, 3=unimplemented)
- reason @0: Text pointer
"""
function build_exception_return(answer_id::AnswerId, reason::String, exception_type::ExceptionType.T)
    reason_bytes = Vector{UInt8}(reason)
    reason_len = length(reason_bytes)
    # Text is stored as data bytes + NUL terminator, word-aligned
    reason_words = cld(reason_len + 1, 8)  # Include NUL terminator, round up to words

    # Layout:
    # Word 0: Root pointer to Message struct
    # Word 1: Message data section (discriminant = RETURN = 3)
    # Word 2: Message pointer section -> Return struct
    # Word 3-4: Return data section (answerId, releaseParamCaps, union discriminant = 3)
    # Word 5: Return pointer section -> Exception struct
    # Word 6: Exception data section (type at offset 4)
    # Word 7: Exception pointer section -> Text (reason)
    # Word 8+: Text data (reason + NUL)

    total_words = 8 + reason_words
    segment = Vector{UInt8}(undef, total_words * 8)
    fill!(segment, 0)

    # Word 0: Root pointer to Message struct at word 1
    root_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 1, reinterpret(UInt8, [root_ptr]), 1, 8)

    # Word 1: Message struct data section - discriminant = RETURN = 3
    segment[9] = 0x03

    # Word 2: Message pointer section -> Return struct at word 3
    return_ptr = UInt64(0) | (UInt64(2) << 32) | (UInt64(1) << 48)
    copyto!(segment, 17, reinterpret(UInt8, [return_ptr]), 1, 8)

    # Word 3-4: Return struct data section
    # - UInt32 at offset 0: answerId
    copyto!(segment, 25, reinterpret(UInt8, [UInt32(answer_id)]), 1, 4)
    # - Bool at offset 4: releaseParamCaps (default true, so wire 0 = true)
    segment[29] = 0x00
    # - UInt16 at offset 6: union discriminant = 1 (exception)
    segment[31] = 0x01

    # Word 5: Return pointer section -> Exception struct at word 6
    # Exception: 1 data word, 1 pointer
    exception_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 41, reinterpret(UInt8, [exception_ptr]), 1, 8)

    # Word 6: Exception data section
    # - type @3 at offset 4: UInt16 enum (0=failed, 1=overloaded, 2=disconnected, 3=unimplemented)
    type_value = UInt16(Int(exception_type))
    copyto!(segment, 53, reinterpret(UInt8, [type_value]), 1, 2)

    # Word 7: Exception pointer section -> Text (reason)
    # Text pointer: list pointer, size=2 (byte), element_count = reason_len + 1 (for NUL)
    # Offset from word 7 to word 8 = 0 (from end of pointer)
    text_ptr = UInt64(1) | (UInt64(0) << 2) | (UInt64(2) << 32) | (UInt64(reason_len + 1) << 35)
    copyto!(segment, 57, reinterpret(UInt8, [text_ptr]), 1, 8)

    # Word 8+: Text data (reason bytes + NUL terminator)
    if reason_len > 0
        copyto!(segment, 65, reason_bytes, 1, reason_len)
    end
    segment[65+reason_len] = 0x00  # NUL terminator

    used_size = total_words * 8

    # Build the full message with header
    num_segments = UInt32(0)
    segment_size = UInt32(total_words)

    message = Vector{UInt8}(undef, 8 + used_size)
    Capnp._store_le_uint32!(message, 1, num_segments)
    Capnp._store_le_uint32!(message, 5, segment_size)
    copyto!(message, 9, segment, 1, used_size)

    return message
end

"""
Build a Return message in wire format with a Float64 result.

For a successful return with a Float64 value (like Calculator.add), we need:
- Message struct (1 data word, 1 pointer)
- Return struct (2 data words, 1 pointer) - results variant
- Payload struct (0 data words, 2 pointers)
- Payload.content = struct pointer to result struct (1 data word for Float64, 0 pointers)
- Payload.capTable = null pointer (empty list, no capabilities)
- Result struct (1 data word containing Float64)
"""
function build_minimal_return(answer_id::AnswerId, result::Any)
    # Build segment data - 10 words total (matching C++ output)
    segment = Vector{UInt8}(undef, 80)
    fill!(segment, 0)

    # Word 0: Root pointer to Message struct at word 1
    # Struct pointer: type=0, offset=0, data_size=1, ptr_count=1
    root_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 1, reinterpret(UInt8, [root_ptr]), 1, 8)

    # Word 1: Message struct data section
    # - UInt16 at offset 0: union discriminant = 3 (RETURN)
    segment[9] = 0x03  # RETURN = 3

    # Word 2: Message pointer section -> Return struct at word 3
    # Struct pointer: type=0, offset=0, data_size=2, ptr_count=1
    return_ptr = UInt64(0) | (UInt64(2) << 32) | (UInt64(1) << 48)
    copyto!(segment, 17, reinterpret(UInt8, [return_ptr]), 1, 8)

    # Word 3-4: Return struct data section
    # - UInt32 at offset 0: answerId
    copyto!(segment, 25, reinterpret(UInt8, [UInt32(answer_id)]), 1, 4)
    # - Bool at offset 4: releaseParamCaps (default true)
    # Default is true, so wire value 0 means true (XOR encoding)
    segment[29] = 0x00
    # - UInt16 at offset 6: union discriminant = 0 (results)
    # leave as 0 (results)

    # Word 5: Return pointer section -> Payload struct at word 6
    # Payload struct: 0 data words, 2 pointers
    payload_ptr = UInt64(0) | (UInt64(0) << 32) | (UInt64(2) << 48)
    copyto!(segment, 41, reinterpret(UInt8, [payload_ptr]), 1, 8)

    # Word 6: Payload.content -> Result struct at word 8
    # Result struct: 1 data word (Float64), 0 pointers
    # Offset from word 6 to word 8 = 1 (since offset is from END of pointer word)
    content_ptr = UInt64(1 << 2) | (UInt64(1) << 32) | (UInt64(0) << 48)  # offset=1, data=1, ptrs=0
    copyto!(segment, 49, reinterpret(UInt8, [content_ptr]), 1, 8)

    # Word 7: Payload.capTable - empty list (composite with 0 elements)
    # List pointer: type=1, offset=1, size=7 (composite), word_count=0
    # For composite lists, word_count is the total words for elements (NOT including tag word)
    # Empty list has 0 element words, but we still include the tag word
    captable_ptr = UInt64(1) | (UInt64(1) << 2) | (UInt64(7) << 32) | (UInt64(0) << 35)
    copyto!(segment, 57, reinterpret(UInt8, [captable_ptr]), 1, 8)

    # Word 8: Result struct data (Float64 value)
    result_value = result isa Number ? Float64(result) : 0.0
    copyto!(segment, 65, reinterpret(UInt8, [result_value]), 1, 8)

    # Word 9: capTable composite list tag word
    # Tag word format: element_count=0, data_size=1, ptr_count=1 (CapDescriptor layout)
    # Even for empty lists, we include the tag word to describe element structure
    tag_word = UInt64(0 << 2) | (UInt64(1) << 32) | (UInt64(1) << 48)  # 0 elements, 1 data, 1 ptr
    copyto!(segment, 73, reinterpret(UInt8, [tag_word]), 1, 8)

    used_size = 80  # 10 words (matching C++ output)

    # Build the full message with header (8 bytes) + segment (80 bytes) = 88 bytes
    num_segments = UInt32(0)  # 0 means 1 segment
    segment_size = UInt32(used_size ÷ 8)  # 10 words

    message = Vector{UInt8}(undef, 8 + used_size)  # 88 bytes
    Capnp._store_le_uint32!(message, 1, num_segments)
    Capnp._store_le_uint32!(message, 5, segment_size)
    copyto!(message, 9, segment, 1, used_size)

    return message
end

"""
    build_capability_return(answer_id::AnswerId, export_id::ExportId) -> Vector{UInt8}

Build a Return message that returns a capability (e.g., for getSubCalculator).
Unlike build_bootstrap_return, this creates a result struct with the capability in its pointer section.
GetSubCalculatorResults has 0 data words and 1 pointer (the calculator capability).
"""
function build_capability_return(answer_id::AnswerId, export_id::ExportId)
    # The Return contains results with a struct containing a capability pointer
    # The capability table has one entry: senderHosted with the export_id

    # Build segment (12 words = 96 bytes)
    segment = Vector{UInt8}(undef, 96)
    fill!(segment, 0)

    # Word 0: Root pointer to Message struct at word 1
    root_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 1, reinterpret(UInt8, [root_ptr]), 1, 8)

    # Word 1: Message struct data section (discriminant = RETURN = 3)
    segment[9] = 0x03

    # Word 2: Message pointer section -> Return struct at word 3
    return_ptr = UInt64(0) | (UInt64(2) << 32) | (UInt64(1) << 48)
    copyto!(segment, 17, reinterpret(UInt8, [return_ptr]), 1, 8)

    # Word 3-4: Return struct data
    # answerId = answer_id at offset 0
    copyto!(segment, 25, reinterpret(UInt8, [UInt32(answer_id)]), 1, 4)
    # releaseParamCaps = true at offset 4 (wire value 0 = true with XOR encoding)
    segment[29] = 0x00
    # union discriminant = 0 (results) at offset 6 (already 0 from fill)

    # Word 5: Return pointer section -> Payload struct at word 6
    payload_ptr = UInt64(0) | (UInt64(0) << 32) | (UInt64(2) << 48)
    copyto!(segment, 41, reinterpret(UInt8, [payload_ptr]), 1, 8)

    # Word 6: content - struct pointer to result struct at word 8
    # Result struct (GetSubCalculatorResults): 0 data words, 1 pointer
    # Offset from word 6 end to word 8 start = 1
    content_ptr = UInt64(1 << 2) | (UInt64(0) << 32) | (UInt64(1) << 48)  # offset=1, data=0, ptrs=1
    copyto!(segment, 49, reinterpret(UInt8, [content_ptr]), 1, 8)

    # Word 7: capTable - list pointer to CapDescriptor list at word 9
    # List pointer: type=1, offset=1, size=7 (composite), word_count=2
    # word_count = 2 because: CapDescriptor has 1 data word + 1 pointer = 2 words per element
    # (word_count does NOT include the tag word per Cap'n Proto spec)
    list_ptr = UInt64(1) | (UInt64(1) << 2) | (UInt64(7) << 32) | (UInt64(2) << 35)
    copyto!(segment, 57, reinterpret(UInt8, [list_ptr]), 1, 8)

    # Word 8: Result struct pointer section - capability pointer to capTable[0]
    # Capability pointer format: type=3 (capability), index=0
    cap_ptr = UInt64(3) | (UInt64(0) << 32)
    copyto!(segment, 65, reinterpret(UInt8, [cap_ptr]), 1, 8)

    # Word 9: Composite list tag word (element_count=1, data_size=1, ptr_count=1)
    tag_word = UInt64(1 << 2) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 73, reinterpret(UInt8, [tag_word]), 1, 8)

    # Word 10: CapDescriptor data section (1 word)
    # union discriminant = 1 (senderHosted) at offset 0 (UInt16)
    # senderHosted export_id (UInt32) at offset 4
    segment[81] = 0x01  # discriminant = senderHosted
    segment[82] = 0x00  # high byte of discriminant
    copyto!(segment, 85, reinterpret(UInt8, [UInt32(export_id)]), 1, 4)

    # Word 11: CapDescriptor pointer section (unused, 1 pointer)

    used_size = 96  # 12 words

    # Build message with header
    num_segments = UInt32(0)
    segment_size = UInt32(used_size ÷ 8)

    message = Vector{UInt8}(undef, 8 + used_size)
    Capnp._store_le_uint32!(message, 1, num_segments)
    Capnp._store_le_uint32!(message, 5, segment_size)
    copyto!(message, 9, segment, 1, used_size)

    return message
end

"""
    build_bootstrap_return(question_id::QuestionId, export_id::ExportId) -> Vector{UInt8}

Build a Return message for a Bootstrap request, returning the exported capability.
"""
function build_bootstrap_return(question_id::QuestionId, export_id::ExportId)
    # The Bootstrap Return contains results with a single capability pointer
    # The capability table has one entry: senderHosted with the export_id

    # Build segment (11 words = 88 bytes)
    segment = Vector{UInt8}(undef, 88)
    fill!(segment, 0)

    # Word 0: Root pointer to Message struct at word 1
    root_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 1, reinterpret(UInt8, [root_ptr]), 1, 8)

    # Word 1: Message struct data section (discriminant = RETURN = 3)
    segment[9] = 0x03

    # Word 2: Message pointer section -> Return struct at word 3
    return_ptr = UInt64(0) | (UInt64(2) << 32) | (UInt64(1) << 48)
    copyto!(segment, 17, reinterpret(UInt8, [return_ptr]), 1, 8)

    # Word 3-4: Return struct data
    # answerId = question_id at offset 0
    copyto!(segment, 25, reinterpret(UInt8, [UInt32(question_id)]), 1, 4)
    # releaseParamCaps = true at offset 4
    # Default is true, so wire value 0x00 XOR 0x01 (default) = 0x01 (true)
    # To send true, we write 0x00 (the default)
    segment[29] = 0x00
    # union discriminant = 0 (results) at offset 6 (already 0 from fill)

    # Word 5: Return pointer section -> Payload struct at word 6
    payload_ptr = UInt64(0) | (UInt64(0) << 32) | (UInt64(2) << 48)
    copyto!(segment, 41, reinterpret(UInt8, [payload_ptr]), 1, 8)

    # Word 6-7: Payload struct (0 data words, 2 pointers)
    # Payload.content: capability pointer referencing capTable[0]
    # Payload.capTable: list of CapDescriptor
    #
    # Per rpc.capnp: "For a Return in response to Bootstrap, results.content
    # is just a capability pointer with index 0."

    # Word 6: content - capability pointer to capTable[0]
    # Capability pointer format:
    #   Bits 0-1: type = 3 (capability/interface pointer, also called "other" pointer)
    #   Bits 2-31: 0 (unused for capability pointers)
    #   Bits 32-63: capability index in capTable (0 for first entry)
    cap_ptr = UInt64(3) | (UInt64(0) << 32)  # type=3, index=0
    copyto!(segment, 49, reinterpret(UInt8, [cap_ptr]), 1, 8)

    # Word 7: capTable - list pointer to CapDescriptor list at word 8
    # List pointer format:
    #   Bits 0-1: type = 1 (list)
    #   Bits 2-31: offset from end of pointer (30 bits signed)
    #   Bits 32-34: element size code = 7 (composite)
    #   Bits 35-63: total word count for element data (NOT including tag word per Cap'n Proto spec)
    # CapDescriptor has: 1 data word (union discriminant + data), 1 pointer = 2 words per element
    # For 1 element: word_count = 1 * 2 = 2
    list_ptr = UInt64(1) | (UInt64(0) << 2) | (UInt64(7) << 32) | (UInt64(2) << 35)
    copyto!(segment, 57, reinterpret(UInt8, [list_ptr]), 1, 8)

    # Word 8: Composite list tag word (element count=1, data_size=1, ptr_count=1)
    # CapDescriptor: 1 data word, 1 pointer
    tag_word = UInt64(1 << 2) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 65, reinterpret(UInt8, [tag_word]), 1, 8)

    # Word 9: CapDescriptor data section (1 word)
    # union discriminant = 1 (senderHosted) at offset 0 (UInt16)
    # senderHosted export_id (UInt32) at offset 4 (after 2-byte discriminant + 2-byte padding)
    segment[73] = 0x01  # discriminant = senderHosted
    segment[74] = 0x00  # high byte of discriminant
    copyto!(segment, 77, reinterpret(UInt8, [UInt32(export_id)]), 1, 4)  # export_id at byte offset 4

    # Word 10: CapDescriptor pointer section (unused, 1 pointer)

    used_size = 88  # 11 words

    # Build message with header
    num_segments = UInt32(0)
    segment_size = UInt32(used_size ÷ 8)

    message = Vector{UInt8}(undef, 8 + used_size)
    Capnp._store_le_uint32!(message, 1, num_segments)
    Capnp._store_le_uint32!(message, 5, segment_size)
    copyto!(message, 9, segment, 1, used_size)

    return message
end


# ============================================================================
# Resolve Message Builder (Level 2)
# ============================================================================

"""
    build_resolve_message(promise_id::ExportId, cap_kind::CapDescriptorType.T, export_id::ExportId) -> Vector{UInt8}

Build a Resolve message that resolves a promised capability to an actual capability.
The capability is described using a CapDescriptor in the Resolve.cap field.

Resolve struct layout (per rpc.capnp):
- Message: 1 data word (discriminant = RESOLVE = 5), 1 pointer
- Resolve: 1 data word (promiseId + union discriminant = 0 for cap), 1 pointer
- CapDescriptor: 1 data word (kind + export_id), 1 pointer
"""
function build_resolve_message(promise_id::ExportId, cap_kind::CapDescriptorType.T, export_id::ExportId)
    # Layout:
    # Word 0: Root pointer to Message struct
    # Word 1: Message data section (discriminant = RESOLVE = 5)
    # Word 2: Message pointer section -> Resolve struct
    # Word 3: Resolve data section (promiseId, union discriminant = 0 for cap)
    # Word 4: Resolve pointer section -> CapDescriptor
    # Word 5: CapDescriptor data section (kind + export_id)
    # Word 6: CapDescriptor pointer section (unused)

    segment = Vector{UInt8}(undef, 56)  # 7 words
    fill!(segment, 0)

    # Word 0: Root pointer to Message struct at word 1
    root_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 1, reinterpret(UInt8, [root_ptr]), 1, 8)

    # Word 1: Message struct data section - discriminant = RESOLVE = 5
    segment[9] = 0x05

    # Word 2: Message pointer section -> Resolve struct at word 3
    # Resolve: 1 data word, 1 pointer
    resolve_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 17, reinterpret(UInt8, [resolve_ptr]), 1, 8)

    # Word 3: Resolve data section
    # - promiseId (UInt32 at offset 0)
    copyto!(segment, 25, reinterpret(UInt8, [UInt32(promise_id)]), 1, 4)
    # - union discriminant = 0 (cap) at offset 4
    segment[29] = 0x00

    # Word 4: Resolve pointer section -> CapDescriptor at word 5
    # CapDescriptor: 1 data word, 1 pointer
    cap_desc_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 33, reinterpret(UInt8, [cap_desc_ptr]), 1, 8)

    # Word 5: CapDescriptor data section
    # - kind (UInt16 at offset 0)
    copyto!(segment, 41, reinterpret(UInt8, [UInt16(Int(cap_kind))]), 1, 2)
    # - export_id (UInt32 at offset 4) for senderHosted/senderPromise
    copyto!(segment, 45, reinterpret(UInt8, [UInt32(export_id)]), 1, 4)

    # Word 6: CapDescriptor pointer section (unused)

    used_size = 56  # 7 words

    # Build message with header
    num_segments = UInt32(0)
    segment_size = UInt32(used_size ÷ 8)

    message = Vector{UInt8}(undef, 8 + used_size)
    Capnp._store_le_uint32!(message, 1, num_segments)
    Capnp._store_le_uint32!(message, 5, segment_size)
    copyto!(message, 9, segment, 1, used_size)

    return message
end

"""
    build_resolve_exception(promise_id::ExportId, reason::String, exception_type::ExceptionType.T) -> Vector{UInt8}

Build a Resolve message that resolves a promised capability to an exception.
This is used when the promise fails to resolve to a valid capability.

Layout:
- Message: 1 data word (RESOLVE), 1 pointer
- Resolve: 1 data word (promiseId, discriminant=1 for exception), 1 pointer
- Exception: 1 data word (type at offset 4), 1 pointer (reason text)
- Text: reason bytes + NUL
"""
function build_resolve_exception(promise_id::ExportId, reason::String, exception_type::ExceptionType.T)
    reason_bytes = Vector{UInt8}(reason)
    reason_len = length(reason_bytes)
    reason_words = cld(reason_len + 1, 8)  # Include NUL terminator

    # Layout:
    # Word 0: Root pointer to Message
    # Word 1: Message data (discriminant = RESOLVE = 5)
    # Word 2: Message pointer -> Resolve
    # Word 3: Resolve data (promiseId, discriminant = 1 for exception)
    # Word 4: Resolve pointer -> Exception
    # Word 5: Exception data (type at offset 4)
    # Word 6: Exception pointer -> Text
    # Word 7+: Text data

    total_words = 7 + reason_words
    segment = Vector{UInt8}(undef, total_words * 8)
    fill!(segment, 0)

    # Word 0: Root pointer
    root_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 1, reinterpret(UInt8, [root_ptr]), 1, 8)

    # Word 1: Message discriminant = RESOLVE = 5
    segment[9] = 0x05

    # Word 2: Message pointer -> Resolve (1 data, 1 ptr)
    resolve_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 17, reinterpret(UInt8, [resolve_ptr]), 1, 8)

    # Word 3: Resolve data
    copyto!(segment, 25, reinterpret(UInt8, [UInt32(promise_id)]), 1, 4)
    segment[29] = 0x01  # discriminant = exception

    # Word 4: Resolve pointer -> Exception (1 data, 1 ptr)
    exc_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 33, reinterpret(UInt8, [exc_ptr]), 1, 8)

    # Word 5: Exception data (type at offset 4)
    type_value = UInt16(Int(exception_type))
    copyto!(segment, 45, reinterpret(UInt8, [type_value]), 1, 2)

    # Word 6: Exception pointer -> Text
    # Text list pointer: type=1, offset=0, size=2 (byte), count=reason_len+1
    text_ptr = UInt64(1) | (UInt64(0) << 2) | (UInt64(2) << 32) | (UInt64(reason_len + 1) << 35)
    copyto!(segment, 49, reinterpret(UInt8, [text_ptr]), 1, 8)

    # Word 7+: Text data
    if reason_len > 0
        copyto!(segment, 57, reason_bytes, 1, reason_len)
    end
    segment[57+reason_len] = 0x00  # NUL terminator

    used_size = total_words * 8

    # Build message with header
    num_segments = UInt32(0)
    segment_size = UInt32(total_words)

    message = Vector{UInt8}(undef, 8 + used_size)
    Capnp._store_le_uint32!(message, 1, num_segments)
    Capnp._store_le_uint32!(message, 5, segment_size)
    copyto!(message, 9, segment, 1, used_size)

    return message
end


# ============================================================================
# Save/Restore Message Builders (Level 2 Persistent Capabilities)
# ============================================================================

"""
    build_save_call(question_id::QuestionId, target_import_id::ImportId) -> Vector{UInt8}

Build a Call message to invoke Persistent.save() on a capability.
This calls method 0 on the Persistent interface.

The Persistent interface ID is 0xc8cb212fcd9f5691.
"""
function build_save_call(question_id::QuestionId, target_import_id::ImportId)
    # Persistent interface constants
    persistent_interface_id = 0xc8cb212fcd9f5691
    save_method_id = UInt16(0)

    target = ParsedMessageTarget(MessageTargetType.IMPORTED_CAP, target_import_id)

    builder = build_call(question_id, target, persistent_interface_id, save_method_id, (params, loc) -> nothing; data_word_count = UInt16(0), pointer_count = UInt16(0))

    io = IOBuffer()
    Capnp.writeMessageToStream(builder, io)
    return take!(io)
end

"""
    ParsedSaveResults

Parsed results from a Persistent.save() call.
Contains the sturdy reference data.
"""
struct ParsedSaveResults
    sturdy_ref_data::Vector{UInt8}  # Raw sturdy ref bytes
end

"""
    parse_save_results(seg::Vector{UInt8}, results_start::Int) -> ParsedSaveResults

Parse SaveResults from a Return message's results payload.
SaveResults contains a SturdyRef which we extract as raw bytes.
"""
function parse_save_results(seg::Vector{UInt8}, results_start::Int)
    # SaveResults has 0 data words, 1 pointer (sturdyRef)
    # Get the sturdyRef pointer
    ref_ptr = get_struct_pointer(seg, results_start)

    if ref_ptr === nothing || ref_ptr == 0
        return ParsedSaveResults(UInt8[])
    end

    # For DefaultSturdyRef format:
    # Struct with 0 data words, 2 pointers (hostId: Data, objectId: Data)
    ref_offset, _ref_data_size, _ref_ptr_count = decode_struct_pointer(ref_ptr)
    ref_start = results_start + 1 + ref_offset

    # Read hostId data pointer at pointer 0
    host_ptr = get_struct_pointer(seg, ref_start)
    # Read objectId data pointer at pointer 1
    object_ptr = get_struct_pointer(seg, ref_start + 1)

    # Extract the data bytes
    host_bytes = extract_data_bytes(seg, ref_start, host_ptr)
    object_bytes = extract_data_bytes(seg, ref_start + 1, object_ptr)

    # Serialize as DefaultSturdyRef format
    buffer = IOBuffer()
    write(buffer, UInt32(length(host_bytes)))
    write(buffer, host_bytes)
    write(buffer, UInt32(length(object_bytes)))
    write(buffer, object_bytes)

    return ParsedSaveResults(take!(buffer))
end

"""
Extract raw bytes from a data list pointer.
"""
function extract_data_bytes(seg::Vector{UInt8}, ptr_word::Int, ptr::UInt64)
    if ptr == 0
        return UInt8[]
    end

    # Check if it's a list pointer (type = 1)
    if (ptr & 0x3) != 1
        return UInt8[]
    end

    offset = Int((ptr >> 2) & 0x3FFFFFFF)
    if offset & 0x20000000 != 0
        offset -= 0x40000000
    end

    elem_size = Int((ptr >> 32) & 0x7)
    elem_count = Int((ptr >> 35) & 0x1FFFFFFF)

    if elem_size != 2  # Size code 2 = byte elements
        return UInt8[]
    end

    data_start = (ptr_word + 1 + offset - 1) * 8 + 1
    if data_start > 0 && data_start + elem_count - 1 <= length(seg)
        return seg[data_start:(data_start+elem_count-1)]
    end

    return UInt8[]
end

"""
    build_restore_call(question_id::QuestionId, restorer_import_id::ImportId, sturdy_ref_data::Vector{UInt8}) -> Vector{UInt8}

Build a Call message to invoke Persistent.Restore on the bootstrap restorer.
This is used to restore a capability from a SturdyRef on a new connection.

Note: In Cap'n Proto, restore is typically done via the bootstrap capability
which acts as a restorer. The sturdy_ref contains the data needed to find the capability.
"""
function build_restore_call(question_id::QuestionId, restorer_import_id::ImportId, sturdy_ref_data::Vector{UInt8})
    target = ParsedMessageTarget(MessageTargetType.IMPORTED_CAP, restorer_import_id)
    restorer_interface_id = UInt64(0)

    # In handwritten build_restore_call, it passed sturdy_ref_data as the Payload.content pointer itself (a List pointer).
    # Since we modified build_call to pass `content_ptr_loc`, we can write the list pointer directly.
    builder = build_call(
        question_id,
        target,
        restorer_interface_id,
        UInt16(0),
        (params, content_ptr_loc) -> begin
            if !isempty(sturdy_ref_data)
                # Write a data list directly to content_ptr_loc
                list_loc, list_seg, list_off = Capnp.alloc(params.traverser, content_ptr_loc, length(sturdy_ref_data))
                list_ptr = Capnp.SimpleListPointer{UInt8,typeof(params.traverser)}(params.traverser, list_seg, list_off, Capnp.Byte, UInt32(length(sturdy_ref_data)))
                Capnp.write_list_pointer(content_ptr_loc, list_ptr)
                # Copy data
                segment = params.traverser.segments[list_seg]
                copyto!(segment, list_off * 8 + 1, sturdy_ref_data, 1, length(sturdy_ref_data))
            end
        end;
        data_word_count = UInt16(0),
        pointer_count = UInt16(0),
    )

    io = IOBuffer()
    Capnp.writeMessageToStream(builder, io)
    return take!(io)
end

"""
    ParsedRestoreResults

Parsed results from a restore call.
Contains either a capability import ID or an error.
"""
struct ParsedRestoreResults
    success::Bool
    import_id::Union{ImportId,Nothing}  # The restored capability
    error_type::Union{Symbol,Nothing}   # :not_found, :unauthorized, :expired
    error_reason::Union{String,Nothing}
end

"""
    parse_restore_results(seg::Vector{UInt8}, results_start::Int) -> ParsedRestoreResults

Parse results from a restore call.
The result contains a capability pointer or an exception.
"""
function parse_restore_results(seg::Vector{UInt8}, results_start::Int)
    # Results should contain a capability pointer
    cap_ptr = get_struct_pointer(seg, results_start)

    if cap_ptr === nothing || cap_ptr == 0
        return ParsedRestoreResults(false, nothing, :failed, "Empty restore result")
    end

    # Check if it's a capability pointer (type 3)
    ptr_type = cap_ptr & 0x3
    if ptr_type == 3
        # Capability pointer - extract index
        cap_index = UInt32((cap_ptr >> 32) & 0xFFFFFFFF)
        return ParsedRestoreResults(true, ImportId(cap_index), nothing, nothing)
    end

    # Not a capability pointer - might be an error struct
    return ParsedRestoreResults(false, nothing, :failed, "Invalid restore result format")
end

# Exports
export MessageType, ReturnType, MessageTargetType, SendResultsToType
export ResolveType, CapDescriptorType, PromisedAnswerOpType
export PromisedAnswerOp, ParsedPromisedAnswer, ParsedCapDescriptor
export ParsedBootstrap, ParsedMessageTarget, ParsedCall, ParsedFinish, ParsedRelease, ParsedResolve, ParsedReturn, ParsedMessage

export parse_rpc_message, parse_cap_descriptor, parse_promised_answer
export build_bootstrap_request, build_return_message, build_capability_return, build_bootstrap_return, build_exception_return
export build_resolve_message, build_resolve_exception
export ParsedSaveResults, build_save_call, parse_save_results
export ParsedRestoreResults, build_restore_call, parse_restore_results
export build_call
"""
    build_call(question_id::QuestionId, target::ParsedMessageTarget,
               interface_id::UInt64, method_id::UInt16,
               params_builder::Function;
               send_results_to::SendResultsToType.T = SendResultsToType.CALLER,
               allow_third_party_tail_call::Bool = false,
               data_word_count::UInt16 = UInt16(0),
               pointer_count::UInt16 = UInt16(0)) -> AllocMessageBuilder

Build a generic Call message and return the MessageBuilder.
The params_builder callback receives the pre-allocated StructPointer for the method parameters.
"""
function build_call(
    question_id::QuestionId,
    target::ParsedMessageTarget,
    interface_id::UInt64,
    method_id::UInt16,
    params_builder::Function;
    send_results_to::SendResultsToType.T = SendResultsToType.CALLER,
    allow_third_party_tail_call::Bool = false,
    data_word_count::UInt16 = UInt16(0),
    pointer_count::UInt16 = UInt16(0),
)
    builder = Capnp.AllocMessageBuilder()

    # Root pointer
    root_ptr_loc = Capnp.WirePointer(1, 0)
    Capnp.alloc(builder, root_ptr_loc, 8)

    # Message struct (1 data word, 1 pointer)
    msg_loc, msg_seg, msg_off = Capnp.alloc(builder, root_ptr_loc, 8 * (1 + 1))
    msg_ptr = Capnp.StructPointer(builder, msg_seg, msg_off, UInt16(1), UInt16(1))
    Capnp.write_root_struct_pointer(msg_ptr)

    # Message discriminant = CALL (2)
    Capnp.write_bits(msg_ptr, 0, UInt16, 2)

    # Call struct (3 data words, 2 pointers)
    call_ptr_loc = Capnp.WirePointer(msg_seg, msg_off + 1)
    call_loc, call_seg, call_off = Capnp.alloc(builder, call_ptr_loc, 8 * (3 + 2))
    call_ptr = Capnp.StructPointer(builder, call_seg, call_off, UInt16(3), UInt16(2))
    Capnp.write_struct_pointer(call_ptr_loc, call_ptr)

    Capnp.write_bits(call_ptr, 0, UInt32, question_id)
    Capnp.write_bits(call_ptr, 4, UInt16, method_id)
    Capnp.write_bits(call_ptr, 6, UInt16, UInt16(Int(send_results_to)))
    Capnp.write_bits(call_ptr, 8, UInt64, interface_id)
    Capnp.write_bool(call_ptr, 16*8, allow_third_party_tail_call)

    # MessageTarget struct (1 data word, 1 pointer)
    target_ptr_loc = Capnp.WirePointer(call_seg, call_off + 3)
    target_loc, target_seg, target_off = Capnp.alloc(builder, target_ptr_loc, 8 * (1 + 1))
    target_ptr = Capnp.StructPointer(builder, target_seg, target_off, UInt16(1), UInt16(1))
    Capnp.write_struct_pointer(target_ptr_loc, target_ptr)

    Capnp.write_bits(target_ptr, 0, UInt16, UInt16(Int(target.kind)))
    if target.kind == MessageTargetType.IMPORTED_CAP && target.imported_cap !== nothing
        Capnp.write_bits(target_ptr, 4*8, UInt32, target.imported_cap)
    elseif target.kind == MessageTargetType.PROMISED_ANSWER
        pa_ptr_loc = Capnp.WirePointer(target_seg, target_off + 1)
        pa_loc, pa_seg, pa_off = Capnp.alloc(builder, pa_ptr_loc, 8 * (1 + 1))
        pa_ptr = Capnp.StructPointer(builder, pa_seg, pa_off, UInt16(1), UInt16(1))
        Capnp.write_struct_pointer(pa_ptr_loc, pa_ptr)
        Capnp.write_bits(pa_ptr, 0, UInt32, target.promised_answer.question_id)
        # Transform array
        transform_ptr_loc = Capnp.WirePointer(pa_seg, pa_off + 1)
        if !isempty(target.promised_answer.transform)
            # Not implemented for generic transform yet
            # transform_loc, transform_seg, transform_off = Capnp.alloc(...)
        end
    end

    # Payload struct (0 data words, 2 pointers)
    payload_ptr_loc = Capnp.WirePointer(call_seg, call_off + 4)
    payload_loc, payload_seg, payload_off = Capnp.alloc(builder, payload_ptr_loc, 8 * (0 + 2))
    payload_ptr = Capnp.StructPointer(builder, payload_seg, payload_off, UInt16(0), UInt16(2))
    Capnp.write_struct_pointer(payload_ptr_loc, payload_ptr)

    # Params struct (data_word_count data words, pointer_count pointers)
    content_ptr_loc = Capnp.WirePointer(payload_seg, payload_off + 0)
    params_loc, params_seg, params_off = Capnp.alloc(builder, content_ptr_loc, 8 * (data_word_count + pointer_count))
    params_struct_ptr = Capnp.StructPointer(builder, params_seg, params_off, data_word_count, pointer_count)
    Capnp.write_struct_pointer(content_ptr_loc, params_struct_ptr)

    # Invoke user callback to fill params
    params_builder(params_struct_ptr, content_ptr_loc)

    # CapTable handling
    if !isempty(builder.capabilities)
        captable_ptr_loc = Capnp.WirePointer(payload_seg, payload_off + 1)
        num_caps = length(builder.capabilities)
        # CapDescriptor: 1 data word, 1 pointer -> 2 words per element
        # Composite list
        cap_list_loc, cap_list_seg, cap_list_off = Capnp.alloc(builder, captable_ptr_loc, 8 * (1 + num_caps * 2))
        cap_list_ptr = Capnp.CompositeListPointer(builder, cap_list_seg, cap_list_off, UInt32(num_caps), UInt16(1), UInt16(1))
        Capnp.write_list_pointer(captable_ptr_loc, cap_list_ptr)

        for (i, cap_desc) in enumerate(builder.capabilities)
            # Element struct pointer
            item_ptr = cap_list_ptr[i]
            # Write kind and fields based on what it is
            if cap_desc isa ParsedCapDescriptor
                Capnp.write_bits(item_ptr, 0, UInt16, UInt16(Int(cap_desc.kind)))
                if cap_desc.kind == CapDescriptorType.SENDER_HOSTED && cap_desc.sender_hosted !== nothing
                    Capnp.write_bits(item_ptr, 4*8, UInt32, cap_desc.sender_hosted)
                elseif cap_desc.kind == CapDescriptorType.SENDER_PROMISE && cap_desc.sender_promise !== nothing
                    Capnp.write_bits(item_ptr, 4*8, UInt32, cap_desc.sender_promise)
                elseif cap_desc.kind == CapDescriptorType.RECEIVER_HOSTED && cap_desc.receiver_hosted !== nothing
                    Capnp.write_bits(item_ptr, 4*8, UInt32, cap_desc.receiver_hosted)
                elseif cap_desc.kind == CapDescriptorType.RECEIVER_ANSWER && cap_desc.receiver_answer !== nothing
                    # Write PromisedAnswer at pointer 0
                    pa_loc = Capnp.WirePointer(item_ptr.segment, item_ptr.offset + 1)
                    pa_alloc_loc, pa_seg, pa_off = Capnp.alloc(builder, pa_loc, 8 * (1 + 1))
                    pa_ptr = Capnp.StructPointer(builder, pa_seg, pa_off, UInt16(1), UInt16(1))
                    Capnp.write_struct_pointer(pa_loc, pa_ptr)
                    Capnp.write_bits(pa_ptr, 0, UInt32, cap_desc.receiver_answer.question_id)
                end
            end
        end
    end

    return builder
end

function parse_return(reader::Capnp.MessageReader, seg::Vector{UInt8}, msg_struct_start::Int, msg_ptr_section_start::Int)
    return_ptr = get_struct_pointer(seg, msg_ptr_section_start)
    if return_ptr === nothing || return_ptr == 0
        throw(RemoteException("Invalid Return message: null pointer", ExceptionType.FAILED))
    end

    ret_offset, ret_data_size, _ = decode_struct_pointer(return_ptr)
    struct_start = msg_ptr_section_start + 1 + ret_offset
    ptr_section_start = struct_start + ret_data_size

    answer_id = read_data_field(seg, struct_start, 0, UInt32)
    release_param_caps = read_data_field(seg, struct_start, 4, UInt8) == 0 # default true, XOR encoding
    kind_raw = read_data_field(seg, struct_start, 6, UInt16)
    kind = ReturnType.T(kind_raw)

    if kind == ReturnType.RESULTS
        # Pointer 0 is Payload
        payload_ptr_raw = get_struct_pointer(seg, ptr_section_start)
        if payload_ptr_raw !== nothing && payload_ptr_raw != 0
            payload_offset, payload_data_size, payload_ptr_count = decode_struct_pointer(payload_ptr_raw)
            payload_start = ptr_section_start + 1 + payload_offset

            # Create a proper StructPointer for Payload
            # It has 0 data words, 2 pointers (content, capTable)
            payload_seg_idx = 1 # single segment assumption for parsing
            # The offset in StructPointer is 0-based words from segment start
            payload_word_idx = payload_start - 1
            payload_ptr = Capnp.StructPointer(reader, UInt32(payload_seg_idx), UInt32(payload_word_idx), UInt16(payload_data_size), UInt16(payload_ptr_count))

            # Read capTable (pointer 1 of Payload)
            cap_table = ParsedCapDescriptor[]
            cap_list_ptr_raw = get_struct_pointer(seg, payload_start + 1)
            if cap_list_ptr_raw !== nothing && cap_list_ptr_raw != 0
                list_type = cap_list_ptr_raw & 0x3
                if list_type == 1
                    list_offset = Int((cap_list_ptr_raw >> 2) & 0x3FFFFFFF)
                    if list_offset & 0x20000000 != 0
                        list_offset -= 0x40000000
                    end
                    size_code = Int((cap_list_ptr_raw >> 32) & 0x7)
                    count = Int((cap_list_ptr_raw >> 35) & 0x1FFFFFFF)

                    if size_code == 7 # composite list
                        ptr_word = payload_start + 1
                        tag_word_idx = ptr_word + 1 + list_offset
                        list_start = tag_word_idx + 1
                        # tag word
                        tag = get_struct_pointer(seg, tag_word_idx)
                        elem_data = Int((tag >> 32) & 0xFFFF)
                        elem_ptrs = Int((tag >> 48) & 0xFFFF)
                        elem_count = Int((tag >> 2) & 0x3FFFFFFF)

                        for i = 0:(elem_count-1)
                            elem_start = list_start + i * (elem_data + elem_ptrs)
                            push!(cap_table, parse_cap_descriptor(seg, elem_start, elem_data))
                        end
                    end
                end
            end

            return ParsedMessage(MessageType.RETURN, nothing, nothing, nothing, nothing, nothing, ParsedReturn(AnswerId(answer_id), release_param_caps, kind, payload_ptr, cap_table, nothing, nothing))
        end
    elseif kind == ReturnType.EXCEPTION
        exc_ptr = get_struct_pointer(seg, ptr_section_start)
        exception_reason = ""
        exception_type = ExceptionType.FAILED

        if exc_ptr !== nothing && exc_ptr != 0
            exc_offset, exc_data_size, _ = decode_struct_pointer(exc_ptr)
            exc_start = ptr_section_start + 1 + exc_offset
            exc_ptr_section = exc_start + exc_data_size

            type_raw = read_data_field(seg, exc_start, 4, UInt16)
            if type_raw <= 3
                exception_type = ExceptionType.T(type_raw)
            end

            text_ptr = get_struct_pointer(seg, exc_ptr_section)
            if text_ptr !== nothing && text_ptr != 0
                list_type = text_ptr & 0x3
                if list_type == 1
                    list_offset = Int((text_ptr >> 2) & 0x3FFFFFFF)
                    if list_offset & 0x20000000 != 0
                        list_offset -= 0x40000000
                    end
                    elem_count = Int((text_ptr >> 35) & 0x1FFFFFFF)
                    text_start = (exc_ptr_section + list_offset) * 8 + 1
                    if text_start > 0 && text_start + elem_count - 1 <= length(seg)
                        text_bytes = seg[text_start:(text_start+elem_count-2)]
                        exception_reason = String(text_bytes)
                    end
                end
            end
        end
        return ParsedMessage(MessageType.RETURN, nothing, nothing, nothing, nothing, nothing, ParsedReturn(AnswerId(answer_id), release_param_caps, kind, nothing, ParsedCapDescriptor[], exception_reason, exception_type))
    end

    return ParsedMessage(MessageType.RETURN, nothing, nothing, nothing, nothing, nothing, ParsedReturn(AnswerId(answer_id), release_param_caps, kind, nothing, ParsedCapDescriptor[], nothing, nothing))
end

"""
    build_finish_message(question_id::QuestionId, release_result_caps::Bool=false)

Build a Finish message.
"""
function build_finish_message(question_id::QuestionId, release_result_caps::Bool = false)
    segment = fill!(Vector{UInt8}(undef, 32), 0)

    # Word 0: Root pointer to Message struct at word 1
    root_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 1, reinterpret(UInt8, [root_ptr]), 1, 8)

    # Word 1: Message struct data section (discriminant = FINISH = 4)
    segment[9] = 0x04

    # Word 2: Message pointer section -> Finish struct at word 3
    finish_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(0) << 48)
    copyto!(segment, 17, reinterpret(UInt8, [finish_ptr]), 1, 8)

    # Word 3: Finish struct data
    # questionId = question_id at offset 0
    copyto!(segment, 25, reinterpret(UInt8, [UInt32(question_id)]), 1, 4)
    # releaseResultCaps = release_result_caps at offset 4 (bit 0) -> default is true (XOR encoded)
    segment[29] = release_result_caps ? 0x00 : 0x01

    # Add frame header
    message = Vector{UInt8}(undef, 8 + length(segment))
    Capnp._store_le_uint32!(message, 1, 0)
    Capnp._store_le_uint32!(message, 5, 4)
    copyto!(message, 9, segment, 1, length(segment))

    return message
end

export build_finish_message

"""
    build_release_message(import_id::ImportId, reference_count::UInt32)

Build a Release message.
"""
function build_release_message(import_id::ImportId, reference_count::UInt32)
    segment = fill!(Vector{UInt8}(undef, 32), 0)

    # Word 0: Root pointer to Message struct at word 1
    root_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(1) << 48)
    copyto!(segment, 1, reinterpret(UInt8, [root_ptr]), 1, 8)

    # Word 1: Message struct data section (discriminant = RELEASE = 6)
    segment[9] = 0x06

    # Word 2: Message pointer section -> Release struct at word 3
    # data_word_count = 1, pointer_count = 0
    release_ptr = UInt64(0) | (UInt64(1) << 32) | (UInt64(0) << 48)
    copyto!(segment, 17, reinterpret(UInt8, [release_ptr]), 1, 8)

    # Word 3: Release struct data
    # id = import_id at offset 0
    copyto!(segment, 25, reinterpret(UInt8, [UInt32(import_id)]), 1, 4)
    # referenceCount = reference_count at offset 4
    copyto!(segment, 29, reinterpret(UInt8, [reference_count]), 1, 4)

    # Add frame header
    message = Vector{UInt8}(undef, 8 + length(segment))
    Capnp._store_le_uint32!(message, 1, 0)
    Capnp._store_le_uint32!(message, 5, 4)
    copyto!(message, 9, segment, 1, length(segment))

    return message
end

export build_release_message
