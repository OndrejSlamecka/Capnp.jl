# Handwritten schema.capnp reader
# This code has been optimised only for the speed of writing it.

if !@isdefined(capnp)
    eval(:(module capnp end))
end
@eval capnp begin

    if !@isdefined(schema)
        eval(:(module schema end))
    end
    @eval schema begin

        using Capnp

        # Enumerant
        const Enumerant_data_word_count = 1
        const Enumerant_pointer_count = 2

        function Enumerant_getName(ptr::StructPointer)
            read_text(read_list_pointer(ptr, 1, 0))
        end
        function Enumerant_getCodeOrder(ptr::StructPointer)
            read_bits(ptr, 0, UInt16)
        end
        function Enumerant_getAnnotations(ptr::StructPointer)
            p = read_list_pointer(ptr, 1, 1)
            @assert isempty(p) || (p.data_word_count == Annotation_data_word_count && p.pointer_count == Annotation_pointer_count)
            p
        end

        # Type
        const Type_data_word_count = 3
        const Type_pointer_count = 1

        @enum Type_union::UInt16 Type_union_void Type_union_bool Type_union_int8 Type_union_int16 Type_union_int32 Type_union_int64 Type_union_uint8 Type_union_uint16 Type_union_uint32 Type_union_uint64 Type_union_float32 Type_union_float64 Type_union_text Type_union_data Type_union_list Type_union_enum Type_union_struct Type_union_interface Type_union_anyPointer

        @enum Type_anyPointer_unconstrained::UInt16 Type_anyPointer_unconstrained_anyKind Type_anyPointer_unconstrained_struct Type_anyPointer_unconstrained_list Type_anyPointer_unconstrained_capability

        function Type_which(ptr::StructPointer)
            Type_union(read_bits(ptr, 0, UInt16))
        end

        function Type_enum_getTypeId(ptr::StructPointer)
            read_bits(ptr, 8, UInt64)
        end
        function Type_enum_getBrand(ptr::StructPointer)
            p = read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count && p.pointer_count == Brand_pointer_count)
            p
        end

        function Type_list_getElementType(ptr::StructPointer)
            p = read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count && p.pointer_count == Type_pointer_count)
            p
        end
        function Type_struct_getTypeId(ptr::StructPointer)
            read_bits(ptr, 8, UInt64)
        end
        function Type_struct_getBrand(ptr::StructPointer)
            p = read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count && p.pointer_count == Brand_pointer_count)
            p
        end


        @enum Type_anyPointer_union::UInt16 Type_anyPointer_union_unconstrained Type_anyPointer_union_parameter Type_anyPointer_union_implicitMethodParameter

        function Type_anyPointer_which(ptr::StructPointer)
            Type_anyPointer_union(read_bits(ptr, 8, UInt16))
        end

        @enum Type_anyPointer_unconstrained_union::UInt16 Type_anyPointer_unconstrained_union_anyKind Type_anyPointer_unconstrained_union_struct Type_anyPointer_unconstrained_union_list Type_anyPointer_unconstrained_union_capability

        function Type_anyPointer_unconstrained_which(ptr::StructPointer)
            Type_anyPointer_unconstrained_union(read_bits(ptr, 10, UInt16))
        end

        function Type_anyPointer_parameter_getScopeId(ptr::StructPointer)
            read_bits(ptr, 16, UInt64)
        end
        function Type_anyPointer_parameter_getParameterIndex(ptr::StructPointer)
            read_bits(ptr, 10, UInt16)
        end

        function Type_anyPointer_implicitMethodParameter_getParameterIndex(ptr::StructPointer)
            read_bits(ptr, 10, UInt16)
        end


        # Value
        const Value_data_word_count = 2
        const Value_pointer_count = 1

        @enum Value_union::UInt16 Value_union_void Value_union_bool Value_union_int8 Value_union_int16 Value_union_int32 Value_union_int64 Value_union_uint8 Value_union_uint16 Value_union_uint32 Value_union_uint64 Value_union_float32 Value_union_float64 Value_union_text Value_union_data Value_union_list Value_union_enum Value_union_struct Value_union_interface Value_union_anyPointer

        function Value_which(ptr::StructPointer)
            Value_union(read_bits(ptr, 0, UInt16))
        end
        function Value_getVoid(ptr::StructPointer)
            nothing # TODO: not clear we should even define this
        end
        function Value_getBool(ptr::StructPointer)
            read_bool(ptr, 16)
        end
        function Value_getInt8(ptr::StructPointer)
            read_bits(ptr, 2, Int8)
        end
        function Value_getInt16(ptr::StructPointer)
            read_bits(ptr, 2, Int16)
        end
        function Value_getInt32(ptr::StructPointer)
            read_bits(ptr, 4, Int32)
        end
        function Value_getInt64(ptr::StructPointer)
            read_bits(ptr, 8, Int64)
        end
        function Value_getUint8(ptr::StructPointer)
            read_bits(ptr, 2, UInt8)
        end
        function Value_getUint16(ptr::StructPointer)
            read_bits(ptr, 2, UInt16)
        end
        function Value_getUint32(ptr::StructPointer)
            read_bits(ptr, 4, UInt32)
        end
        function Value_getUint64(ptr::StructPointer)
            read_bits(ptr, 8, UInt64)
        end
        function Value_getFloat32(ptr::StructPointer)
            read_bits(ptr, 4, Float32)
        end
        function Value_getFloat64(ptr::StructPointer)
            read_bits(ptr, 8, Float64)
        end
        function Value_getText(ptr::StructPointer)
            read_text(read_list_pointer(ptr, 2, 0))
        end
        function Value_getData(ptr::StructPointer)
            read_data(read_list_pointer(ptr, 2, 0))
        end
        function Value_getList(ptr::StructPointer)
            read_list_pointer(ptr, 2, 0)
        end
        function Value_getEnum(ptr::StructPointer)
            read_bits(ptr, 2, UInt16)
        end
        function Value_getStruct(ptr::StructPointer)
            throw("Implement me")
        end
        function Value_getInterface(ptr::StructPointer)
            throw("Implement me")
        end
        function Value_getAnyPointer(ptr::StructPointer)
            throw("Implement me")
        end

        # Brand_Binding
        const Brand_Binding_data_word_count = 1
        const Brand_Binding_pointer_count = 1

        @enum Brand_Binding_union::UInt16 Brand_Binding_union_unbound Brand_Binding_union_type

        function Brand_Binding_which(ptr::StructPointer)
            Brand_Binding_union(read_bits(ptr, 0, UInt64))
        end
        function Brand_Binding_getType(ptr::StructPointer)
            p = read_struct_pointer(ptr, 1, 0)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count && p.pointer_count == Type_pointer_count)
            p
        end

        # Brand_Scope
        const Brand_Scope_data_word_count = 2
        const Brand_Scope_pointer_count = 1

        @enum Brand_Scope_union::UInt16 Brand_Scope_union_bind Brand_Scope_union_inherit

        function Brand_Scope_getScopeId(ptr::StructPointer)
            read_bits(ptr, 0, UInt64)
        end
        function Brand_Scope_getUnion(ptr::StructPointer)
            read_bits(ptr, 8, UInt16)
        end
        function Brand_Scope_getBind(ptr::StructPointer)
            p = read_list_pointer(ptr, 1, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_Binding_data_word_count && p.pointer_count == Brand_Binding_pointer_count)
            p
        end

        # Brand
        const Brand_data_word_count = 0
        const Brand_pointer_count = 1

        function Brand_getScopes(ptr::Nothing)
            []
        end
        function Brand_getScopes(ptr::StructPointer)
            p = read_list_pointer(ptr, 0, 0)
            @assert isempty(p) || (p.data_word_count == Brand_Scope_data_word_count && p.pointer_count == Brand_Scope_pointer_count)
            p
        end

        # Annotation
        const Annotation_data_word_count = 1
        const Annotation_pointer_count = 2

        function Annotation_getId(ptr::StructPointer)
            read_bits(ptr, 0, UInt64)
        end
        function Annotation_getValue(ptr::StructPointer)
            p = read_struct_pointer(ptr, 1, 0)
            @assert isnothing(p) || (p.data_word_count == Value_data_word_count && p.pointer_count == Value_pointer_count)
            p
        end
        function Annotation_getBrand(ptr::StructPointer)
            p = read_struct_pointer(ptr, 1, 1)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count && p.pointer_count == Brand_pointer_count)
            p
        end

        # Field
        const Field_data_word_count = 3
        const Field_pointer_count = 4

        const Field_noDiscriminant = 0xffff # ::UInt16

        function Field_getName(ptr::StructPointer)
            n = read_text(read_list_pointer(ptr, 3, 0))
            n
        end
        function Field_getCodeOrder(ptr::StructPointer)
            read_bits(ptr, 0, UInt16)
        end
        function Field_getAnnotations(ptr::StructPointer)
            p = read_list_pointer(ptr, 3, 1)
            @assert isempty(p) || (p.data_word_count == Annotation_data_word_count && p.pointer_count == Annotation_pointer_count)
            p
        end
        function Field_getDiscriminantValue(ptr::StructPointer)
            value = read_bits(ptr, 2, UInt16)
            value = xor(value, Field_noDiscriminant)
            value
        end

        @enum Field_union::UInt16 Field_union_slot Field_union_group

        function Field_which(ptr::StructPointer)
            Field_union(read_bits(ptr, 8, UInt16))
        end
        function Field_slot_getOffset(ptr::StructPointer)
            read_bits(ptr, 4, UInt32)
        end
        function Field_slot_getType(ptr::StructPointer)
            p = read_struct_pointer(ptr, 3, 2)
            @assert p.data_word_count == Type_data_word_count && p.pointer_count == Type_pointer_count
            p
        end
        function Field_slot_getDefaultValue(ptr::StructPointer)
            p = read_struct_pointer(ptr, 3, 3)
            @assert p.data_word_count == Value_data_word_count && p.pointer_count == Value_pointer_count
            p
        end
        function Field_slot_getHadExplicitDefault(ptr::StructPointer)
            read_bool(ptr, 128)
        end
        function Field_group_getTypeId(ptr::StructPointer)
            read_bits(ptr, 16, UInt64)
        end

        @enum Field_ordinal_union::UInt16 Field_ordinal_union_implicit Field_ordinal_union_explicit

        function Field_ordinal_which(ptr::StructPointer)
            Field_ordinal_union(read_bits(ptr, 10, UInt16))
        end
        function Field_ordinal_getExplicit(ptr::StructPointer)
            read_bits(ptr, 12, UInt16)
        end

        # ElementSize
        @enum ElementSize::UInt16 Empty Bit Byte TwoBytes FourBytes EightBytes Pointer InlineComposite

        # Parameter
        const Parameter_data_word_count = 1
        const Parameter_pointer_count = 0

        function Parameter_getName(ptr::StructPointer)
            read_text(read_list_pointer(ptr, 0, 0))
        end

        # Node_NestedNode
        const Node_NestedNode_data_word_count = 1
        const Node_NestedNode_pointer_count = 1

        function Node_NestedNode_getId(ptr::StructPointer)
            read_bits(ptr, 0, UInt64)
        end
        function Node_NestedNode_getName(ptr::StructPointer)
            read_text(read_list_pointer(ptr, 1, 0))
        end

        # Node
        const Node_data_word_count = 5
        const Node_pointer_count = 6
        @enum Node_union Node_union_file Node_union_struct Node_union_enum Node_union_interface Node_union_const Node_union_annotation

        function Node_getId(ptr::StructPointer)
            read_bits(ptr, 0, UInt64)
        end
        function Node_getDisplayName(ptr::StructPointer)
            read_text(read_list_pointer(ptr, 5, 0))
        end
        function Node_getDisplayNamePrefixLength(ptr::StructPointer)
            read_bits(ptr, 8, UInt32)
        end
        function Node_getScopeId(ptr::StructPointer)
            read_bits(ptr, 16, UInt64)
        end
        function Node_getParameters(ptr::StructPointer)
            p = read_list_pointer(ptr, 5, 5)
            @assert isempty(p) || p isa SimpleListPointer || (p isa CompositeListPointer && p.data_word_count == Parameter_data_word_count && p.pointer_count == Parameter_pointer_count)
            p
        end
        function Node_getIsGeneric(ptr::StructPointer)
            read_bool(ptr, 288)
        end
        function Node_getNestedNodes(ptr::StructPointer)
            p = read_list_pointer(ptr, 5, 1)
            @assert isempty(p) || (p.data_word_count == Node_NestedNode_data_word_count && p.pointer_count == Node_NestedNode_pointer_count)
            p
        end
        function Node_getAnnotations(ptr::StructPointer)
            p = read_list_pointer(ptr, 5, 2)
            @assert isempty(p) || (p.data_word_count == Annotation_data_word_count && p.pointer_count == Annotation_pointer_count)
            p
        end
        function Node_which(ptr::StructPointer)
            Node_union(read_bits(ptr, 12, UInt16))
        end
        function Node_struct_getDataWordCount(ptr::StructPointer)
            read_bits(ptr, 14, UInt16)
        end
        function Node_struct_getPointerCount(ptr::StructPointer)
            read_bits(ptr, 24, UInt16)
        end
        function Node_struct_getPreferredListEncoding(ptr::StructPointer)
            read_bits(ptr, 26, ElementSize)
        end
        function Node_struct_getIsGroup(ptr::StructPointer)
            read_bool(ptr, 224)
        end
        function Node_struct_getDiscriminantCount(ptr::StructPointer)
            read_bits(ptr, 30, UInt16)
        end
        function Node_struct_getDiscriminantOffset(ptr::StructPointer)
            read_bits(ptr, 32, UInt16)
        end
        function Node_struct_getFields(ptr::StructPointer)
            p = read_list_pointer(ptr, 5, 3)
            @assert p.data_word_count == Field_data_word_count && p.pointer_count == Field_pointer_count
            p
        end

        function Node_const_getType(ptr::StructPointer)
            p = read_struct_pointer(ptr, 5, 3)
            @assert p.data_word_count == Type_data_word_count && p.pointer_count == Type_pointer_count
            p
        end
        function Node_const_getValue(ptr::StructPointer)
            p = read_struct_pointer(ptr, 5, 4)
            @assert p.data_word_count == Value_data_word_count && p.pointer_count == Value_pointer_count
            p
        end

        function Node_enum_getEnumerants(ptr::StructPointer)
            p = read_list_pointer(ptr, 5, 3)
            @assert p.data_word_count == Enumerant_data_word_count && p.pointer_count == Enumerant_pointer_count
            p
        end

        function Node_annotation_getType(ptr::StructPointer)
            p = read_struct_pointer(ptr, 5, 3)
            @assert p.data_word_count == Type_data_word_count && p.pointer_count == Type_pointer_count
            p
        end
        function Node_annotation_getTargetsFile(ptr::StructPointer)
            read_bool(ptr, 112)
        end
        function Node_annotation_getTargetsConst(ptr::StructPointer)
            read_bool(ptr, 113)
        end
        function Node_annotation_getTargetsEnum(ptr::StructPointer)
            read_bool(ptr, 114)
        end
        function Node_annotation_getTargetsEnumerant(ptr::StructPointer)
            read_bool(ptr, 115)
        end
        function Node_annotation_getTargetsStruct(ptr::StructPointer)
            read_bool(ptr, 116)
        end
        function Node_annotation_getTargetsField(ptr::StructPointer)
            read_bool(ptr, 117)
        end
        function Node_annotation_getTargetsUnion(ptr::StructPointer)
            read_bool(ptr, 118)
        end
        function Node_annotation_getTargetsGroup(ptr::StructPointer)
            read_bool(ptr, 119)
        end
        function Node_annotation_getTargetsInterface(ptr::StructPointer)
            read_bool(ptr, 120)
        end
        function Node_annotation_getTargetsMethod(ptr::StructPointer)
            read_bool(ptr, 121)
        end
        function Node_annotation_getTargetsParam(ptr::StructPointer)
            read_bool(ptr, 122)
        end
        function Node_annotation_getTargetsAnnotation(ptr::StructPointer)
            read_bool(ptr, 123)
        end

        # Import
        const CodeGeneratorRequest_RequestedFile_Import_data_word_count = 1
        const CodeGeneratorRequest_RequestedFile_Import_pointer_count = 1

        function CodeGeneratorRequest_RequestedFile_Import_getId(ptr::StructPointer)
            read_bits(ptr, 0, UInt64)
        end
        function CodeGeneratorRequest_RequestedFile_Import_getName(ptr::StructPointer)
            read_text(read_list_pointer(ptr, 1, 0))
        end


        # RequestedFile
        const CodeGeneratorRequest_RequestedFile_data_word_count = 1
        const CodeGeneratorRequest_RequestedFile_pointer_count = 2

        function CodeGeneratorRequest_RequestedFile_getId(ptr::StructPointer)
            read_bits(ptr, 0, UInt64)
        end
        function CodeGeneratorRequest_RequestedFile_getFilename(ptr::StructPointer)
            read_text(read_list_pointer(ptr, 1, 0))
        end
        function CodeGeneratorRequest_RequestedFile_getImports(ptr::StructPointer)
            p = read_list_pointer(ptr, 1, 1)
            @assert p.data_word_count == CodeGeneratorRequest_RequestedFile_Import_data_word_count && p.pointer_count == CodeGeneratorRequest_RequestedFile_Import_pointer_count
            p
        end

        # CapnpVersion
        const CapnpVersion_data_word_count = 1
        const CapnpVersion_pointer_count = 0

        function CapnpVersion_getMajor(ptr::StructPointer)
            read_bits(ptr, 0, UInt16)
        end
        function CapnpVersion_getMinor(ptr::StructPointer)
            read_bits(ptr, 2, UInt8)
        end
        function CapnpVersion_getMicro(ptr::StructPointer)
            read_bits(ptr, 3, UInt8)
        end

        # CodeGeneratorRequest
        const CodeGeneratorRequest_data_word_count = 0
        const CodeGeneratorRequest_pointer_count = 4

        function root_CodeGeneratorRequest(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert p.data_word_count == CodeGeneratorRequest_data_word_count && p.pointer_count == CodeGeneratorRequest_pointer_count
            p
        end

        function CodeGeneratorRequest_getNodes(ptr)
            p = read_list_pointer(ptr, 0, 0)
            @assert p.data_word_count == Node_data_word_count && p.pointer_count == Node_pointer_count
            p
        end

        function CodeGeneratorRequest_getRequestedFiles(ptr)
            p = read_list_pointer(ptr, 0, 1)
            @assert p.data_word_count == CodeGeneratorRequest_RequestedFile_data_word_count && p.pointer_count == CodeGeneratorRequest_RequestedFile_pointer_count
            p
        end

        function CodeGeneratorRequest_getCapnpVersion(ptr)
            p = read_struct_pointer(ptr, 0, 2)
            @assert p.data_word_count == CapnpVersion_data_word_count && p.pointer_count == CapnpVersion_pointer_count
            p
        end

    end # module schema
end # module capnp
