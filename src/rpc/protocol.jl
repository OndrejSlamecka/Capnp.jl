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
struct ParsedMessageTarget
    kind::MessageTargetType.T
    imported_cap::Union{ImportId, Nothing}
    # promised_answer would require additional fields
end

"""
    ParsedParams

Parsed parameters for a method call (e.g., Calculator.add params).
"""
struct ParsedParams
    left::Float64
    right::Float64
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
    params::Union{ParsedParams, Nothing}
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
    ParsedMessage

Union type for parsed RPC messages.
"""
struct ParsedMessage
    type::MessageType.T
    bootstrap::Union{ParsedBootstrap, Nothing}
    call::Union{ParsedCall, Nothing}
    finish::Union{ParsedFinish, Nothing}
    release::Union{ParsedRelease, Nothing}
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
        return parse_call(seg, struct_start, ptr_section_start)
    elseif msg_type == MessageType.FINISH
        return parse_finish(seg, struct_start)
    elseif msg_type == MessageType.RELEASE
        return parse_release(seg, ptr_section_start)
    else
        # Return an unimplemented message for unsupported types
        return ParsedMessage(msg_type, nothing, nothing, nothing, nothing)
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
    reinterpret(UInt64, @view seg[byte_offset:byte_offset+7])[1]
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
function read_data_field(seg::Vector{UInt8}, struct_word::Int, byte_offset::Int, ::Type{T}) where T
    byte_pos = (struct_word - 1) * 8 + byte_offset + 1  # Julia 1-based
    if byte_pos + sizeof(T) - 1 > length(seg)
        return zero(T)  # Default value for out-of-bounds
    end
    reinterpret(T, @view seg[byte_pos:byte_pos+sizeof(T)-1])[1]
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
    return ParsedMessage(MessageType.BOOTSTRAP, bootstrap, nothing, nothing, nothing)
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
function parse_call(seg::Vector{UInt8}, _msg_struct_start::Int, msg_ptr_section_start::Int)
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

    # Read Call fields from data section (Cap'n Proto packs fields by size)
    question_id = read_data_field(seg, call_start, 0, UInt32)
    method_id = read_data_field(seg, call_start, 4, UInt16)  # Packed after questionId
    interface_id = read_data_field(seg, call_start, 8, UInt64)  # Second word

    # Parse target (MessageTarget at pointer 0 of Call)
    target = parse_message_target(seg, call_ptr_section)

    # Parse params (Payload at pointer 1 of Call)
    params = parse_params(seg, call_ptr_section + 1)

    call = ParsedCall(
        QuestionId(question_id),
        target,
        interface_id,
        method_id,
        params
    )

    return ParsedMessage(MessageType.CALL, nothing, call, nothing, nothing)
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
function parse_params(seg::Vector{UInt8}, payload_ptr_word::Int)
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
    content_offset, _content_data_size, _content_ptr_count = decode_struct_pointer(content_ptr)
    params_start = payload_start + 1 + content_offset

    # Read left and right Float64 values
    left = read_data_field(seg, params_start, 0, Float64)
    right = read_data_field(seg, params_start, 8, Float64)

    return ParsedParams(left, right)
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
    target_offset, _target_data_size, _ = decode_struct_pointer(target_ptr)
    # Target struct starts at: pointer_word + 1 + offset
    target_start = call_ptr_section + 1 + target_offset

    # Read discriminant
    target_type_raw = read_data_field(seg, target_start, 0, UInt16)
    target_type = MessageTargetType.T(target_type_raw)

    if target_type == MessageTargetType.IMPORTED_CAP
        import_id = read_data_field(seg, target_start, 4, UInt32)
        return ParsedMessageTarget(target_type, ImportId(import_id))
    else
        # PromisedAnswer - not fully implemented for Level 0
        return ParsedMessageTarget(target_type, nothing)
    end
end

"""
Parse a Finish message.
Finish struct layout:
- questionId: UInt32 at data offset 0
- releaseResultCaps: Bool at data offset 4
"""
function parse_finish(_seg::Vector{UInt8}, _msg_struct_start::Int)
    # For Finish, the data is in the Message struct itself after the discriminant
    # Actually, looking at the schema, Finish is a separate struct pointed to

    # TODO: Need to properly locate the Finish struct pointer
    # For now, assume it's at Message pointer 0
    finish = ParsedFinish(QuestionId(0), true)
    return ParsedMessage(MessageType.FINISH, nothing, nothing, finish, nothing)
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
        return ParsedMessage(MessageType.RELEASE, nothing, nothing, nothing,
                           ParsedRelease(ImportId(0), UInt32(1)))
    end

    # Decode the Release struct
    rel_offset, _rel_data_size, _ = decode_struct_pointer(release_ptr)
    # Release struct starts at: pointer_word + 1 + offset
    rel_start = ptr_section_start + 1 + rel_offset

    id = read_data_field(seg, rel_start, 0, UInt32)
    ref_count = read_data_field(seg, rel_start, 4, UInt32)

    release = ParsedRelease(ImportId(id), ref_count)
    return ParsedMessage(MessageType.RELEASE, nothing, nothing, nothing, release)
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
function build_return_message(answer_id::AnswerId, result::Any;
                             has_exception::Bool=false,
                             exception_reason::String="",
                             _exception_type::ExceptionType.T=ExceptionType.FAILED)
    # For a simple implementation, we create a minimal Return message
    # Message struct with Return union variant

    # We need to build:
    # 1. Message struct (root) with union discriminant = RETURN (3)
    # 2. Return struct pointed from Message pointer 0

    # For now, create a minimal hardcoded message
    # This is a placeholder - full implementation would use the generated schema

    buffer = build_minimal_return(answer_id, result, has_exception, exception_reason)
    return buffer
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
function build_minimal_return(answer_id::AnswerId, result::Any,
                             has_exception::Bool, _exception_reason::String)
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
    # - UInt16 at offset 6: union discriminant (0=results, 1=exception)
    if has_exception
        segment[31] = 0x01
    end
    # else: leave as 0 (results)

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
    # The list points to word 9 but has 0 elements
    captable_ptr = UInt64(1) | (UInt64(1) << 2) | (UInt64(7) << 32) | (UInt64(0) << 35)
    copyto!(segment, 57, reinterpret(UInt8, [captable_ptr]), 1, 8)

    # Word 8: Result struct data (Float64 value)
    result_value = result isa Number ? Float64(result) : 0.0
    copyto!(segment, 65, reinterpret(UInt8, [result_value]), 1, 8)

    # Word 9: Empty composite list (no elements, so this is just padding)
    # For a 0-element composite list, no tag word is needed, but we add padding
    # to match C++ behavior

    used_size = 80  # 10 words (matching C++ output)

    # Build the full message with header (8 bytes) + segment (80 bytes) = 88 bytes
    num_segments = UInt32(0)  # 0 means 1 segment
    segment_size = UInt32(used_size ÷ 8)  # 10 words

    message = Vector{UInt8}(undef, 8 + used_size)  # 88 bytes
    copyto!(message, 1, reinterpret(UInt8, [num_segments]), 1, 4)
    copyto!(message, 5, reinterpret(UInt8, [segment_size]), 1, 4)
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
    # Payload.content: NULL (the capability is only in capTable for Bootstrap)
    # Payload.capTable: list of CapDescriptor

    # Word 6: content - NULL pointer (leave as 0)
    # The C++ library leaves content NULL for Bootstrap Return
    # The capability is referenced via capTable[0]

    # Word 7: capTable - list pointer to CapDescriptor list at word 8
    # List pointer format:
    #   Bits 0-1: type = 1 (list)
    #   Bits 2-31: offset from end of pointer (30 bits signed)
    #   Bits 32-34: element size code = 7 (composite)
    #   Bits 35-63: total word count for all elements (NOT including tag word)
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
    copyto!(message, 1, reinterpret(UInt8, [num_segments]), 1, 4)
    copyto!(message, 5, reinterpret(UInt8, [segment_size]), 1, 4)
    copyto!(message, 9, segment, 1, used_size)

    return message
end

# Exports
export MessageType, ReturnType, MessageTargetType, SendResultsToType
export ParsedBootstrap, ParsedMessageTarget, ParsedCall, ParsedFinish, ParsedRelease, ParsedMessage
export ParsedParams
export parse_rpc_message
export build_return_message, build_bootstrap_return
