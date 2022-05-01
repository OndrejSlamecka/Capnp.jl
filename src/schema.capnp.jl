begin
if !@isdefined(capnp); eval(:(module capnp end)); end
@eval capnp begin
    if !@isdefined(schema); eval(:(module schema end)); end
    @eval schema begin
        # Generated from src/schema.capnp
        using Capnp
        const Node_Parameter_data_word_count = 0
        const Node_Parameter_pointer_count = 1
        function root_Node_Parameter(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_Parameter_data_word_count) && p.pointer_count == Node_Parameter_pointer_count
            p
        end
        function initRoot_Node_Parameter(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*1)
            ptr = StructPointer(builder, segment, offset, UInt16(0), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Node_Parameter_getName(ptr)
            p = read_list_pointer(ptr, 0, 0)
            read_text(p)
        end
        function Node_Parameter_setName(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 0)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_text(child_ptr, txt)
        end
        const Node_NestedNode_data_word_count = 1
        const Node_NestedNode_pointer_count = 1
        function root_Node_NestedNode(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_NestedNode_data_word_count) && p.pointer_count == Node_NestedNode_pointer_count
            p
        end
        function initRoot_Node_NestedNode(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*2)
            ptr = StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Node_NestedNode_getName(ptr)
            p = read_list_pointer(ptr, 1, 0)
            read_text(p)
        end
        function Node_NestedNode_setName(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_text(child_ptr, txt)
        end
        function Node_NestedNode_getId(ptr)
            value = read_bits(ptr, 0, UInt64)
            value
        end
        function Node_NestedNode_setId(ptr, value)
            write_bits(ptr, 0, UInt64, value)
        end
        const Node_SourceInfo_Member_data_word_count = 0
        const Node_SourceInfo_Member_pointer_count = 1
        function root_Node_SourceInfo_Member(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_SourceInfo_Member_data_word_count) && p.pointer_count == Node_SourceInfo_Member_pointer_count
            p
        end
        function initRoot_Node_SourceInfo_Member(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*1)
            ptr = StructPointer(builder, segment, offset, UInt16(0), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Node_SourceInfo_Member_getDocComment(ptr)
            p = read_list_pointer(ptr, 0, 0)
            read_text(p)
        end
        function Node_SourceInfo_Member_setDocComment(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 0)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_text(child_ptr, txt)
        end
        const Node_SourceInfo_data_word_count = 1
        const Node_SourceInfo_pointer_count = 2
        function root_Node_SourceInfo(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_SourceInfo_data_word_count) && p.pointer_count == Node_SourceInfo_pointer_count
            p
        end
        function initRoot_Node_SourceInfo(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*3)
            ptr = StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Node_SourceInfo_getId(ptr)
            value = read_bits(ptr, 0, UInt64)
            value
        end
        function Node_SourceInfo_setId(ptr, value)
            write_bits(ptr, 0, UInt64, value)
        end
        function Node_SourceInfo_getDocComment(ptr)
            p = read_list_pointer(ptr, 1, 0)
            read_text(p)
        end
        function Node_SourceInfo_setDocComment(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_text(child_ptr, txt)
        end
        function Node_SourceInfo_initMembers(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (0 + 1)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(0), UInt16(1))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_SourceInfo_getMembers(ptr::Nothing)
            []
        end
        function Node_SourceInfo_getMembers(ptr)
            p = read_list_pointer(ptr, 1, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Node_SourceInfo_Member_data_word_count) && p.pointer_count == Node_SourceInfo_Member_pointer_count
            p
        end
        const Node_data_word_count = 5
        const Node_pointer_count = 6
        @enum Node_union::UInt16 Node_union_file Node_union_struct Node_union_enum Node_union_interface Node_union_const Node_union_annotation 
        function Node_which(ptr::StructPointer)
            Node_union(read_bits(ptr, 12, UInt16))
        end
        function root_Node(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_data_word_count) && p.pointer_count == Node_pointer_count
            p
        end
        function initRoot_Node(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*11)
            ptr = StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Node_getId(ptr)
            value = read_bits(ptr, 0, UInt64)
            value
        end
        function Node_setId(ptr, value)
            write_bits(ptr, 0, UInt64, value)
        end
        function Node_getDisplayName(ptr)
            p = read_list_pointer(ptr, 5, 0)
            read_text(p)
        end
        function Node_setDisplayName(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 5)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_text(child_ptr, txt)
        end
        function Node_getDisplayNamePrefixLength(ptr)
            value = read_bits(ptr, 8, UInt32)
            value
        end
        function Node_setDisplayNamePrefixLength(ptr, value)
            write_bits(ptr, 8, UInt32, value)
        end
        function Node_getScopeId(ptr)
            value = read_bits(ptr, 16, UInt64)
            value
        end
        function Node_setScopeId(ptr, value)
            write_bits(ptr, 16, UInt64, value)
        end
        function Node_initNestedNodes(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 6)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_getNestedNodes(ptr::Nothing)
            []
        end
        function Node_getNestedNodes(ptr)
            p = read_list_pointer(ptr, 5, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Node_NestedNode_data_word_count) && p.pointer_count == Node_NestedNode_pointer_count
            p
        end
        function Node_initAnnotations(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 7)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_getAnnotations(ptr::Nothing)
            []
        end
        function Node_getAnnotations(ptr)
            p = read_list_pointer(ptr, 5, 2, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Annotation_data_word_count) && p.pointer_count == Annotation_pointer_count
            p
        end
        function Node_setFile(ptr)
            write_bits(ptr, 12, UInt16, 0) # union discriminant
        end
        function Node_getStruct(ptr::StructPointer)
            ptr
        end
        function Node_initStruct(ptr)
            write_bits(ptr, 12, UInt16, 1) # union discriminant
            ptr
        end
        function root_Node_struct(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_struct_data_word_count) && p.pointer_count == Node_struct_pointer_count
            p
        end
        function initRoot_Node_struct(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*11)
            ptr = StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Node_struct_getDataWordCount(ptr)
            value = read_bits(ptr, 14, UInt16)
            value
        end
        function Node_struct_setDataWordCount(ptr, value)
            write_bits(ptr, 14, UInt16, value)
        end
        function Node_struct_getPointerCount(ptr)
            value = read_bits(ptr, 24, UInt16)
            value
        end
        function Node_struct_setPointerCount(ptr, value)
            write_bits(ptr, 24, UInt16, value)
        end
        function Node_struct_getPreferredListEncoding(ptr)
            value = read_bits(ptr, 26, ElementSize)
            value
        end
        function Node_struct_setPreferredListEncoding(ptr, value)
            value = write_bits(ptr, 26, ElementSize, value)
        end
        function Node_struct_getIsGroup(ptr)
            value = read_bool(ptr, 224)
            value
        end
        function Node_struct_setIsGroup(ptr, value)
            write_bool(ptr, 224, value)
        end
        function Node_struct_getDiscriminantCount(ptr)
            value = read_bits(ptr, 30, UInt16)
            value
        end
        function Node_struct_setDiscriminantCount(ptr, value)
            write_bits(ptr, 30, UInt16, value)
        end
        function Node_struct_getDiscriminantOffset(ptr)
            value = read_bits(ptr, 32, UInt32)
            value
        end
        function Node_struct_setDiscriminantOffset(ptr, value)
            write_bits(ptr, 32, UInt32, value)
        end
        function Node_struct_initFields(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 8)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (3 + 4)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(3), UInt16(4))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_struct_getFields(ptr::Nothing)
            []
        end
        function Node_struct_getFields(ptr)
            p = read_list_pointer(ptr, 5, 3, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Field_data_word_count) && p.pointer_count == Field_pointer_count
            p
        end
        function Node_getEnum(ptr::StructPointer)
            ptr
        end
        function Node_initEnum(ptr)
            write_bits(ptr, 12, UInt16, 2) # union discriminant
            ptr
        end
        function root_Node_enum(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_enum_data_word_count) && p.pointer_count == Node_enum_pointer_count
            p
        end
        function initRoot_Node_enum(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*11)
            ptr = StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Node_enum_initEnumerants(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 8)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_enum_getEnumerants(ptr::Nothing)
            []
        end
        function Node_enum_getEnumerants(ptr)
            p = read_list_pointer(ptr, 5, 3, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Enumerant_data_word_count) && p.pointer_count == Enumerant_pointer_count
            p
        end
        function Node_getInterface(ptr::StructPointer)
            ptr
        end
        function Node_initInterface(ptr)
            write_bits(ptr, 12, UInt16, 3) # union discriminant
            ptr
        end
        function root_Node_interface(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_interface_data_word_count) && p.pointer_count == Node_interface_pointer_count
            p
        end
        function initRoot_Node_interface(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*11)
            ptr = StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Node_interface_initMethods(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 8)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (3 + 5)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(3), UInt16(5))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_interface_getMethods(ptr::Nothing)
            []
        end
        function Node_interface_getMethods(ptr)
            p = read_list_pointer(ptr, 5, 3, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Method_data_word_count) && p.pointer_count == Method_pointer_count
            p
        end
        function Node_interface_initSuperclasses(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 9)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_interface_getSuperclasses(ptr::Nothing)
            []
        end
        function Node_interface_getSuperclasses(ptr)
            p = read_list_pointer(ptr, 5, 4, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Superclass_data_word_count) && p.pointer_count == Superclass_pointer_count
            p
        end
        function Node_getConst(ptr::StructPointer)
            ptr
        end
        function Node_initConst(ptr)
            write_bits(ptr, 12, UInt16, 4) # union discriminant
            ptr
        end
        function root_Node_const(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_const_data_word_count) && p.pointer_count == Node_const_pointer_count
            p
        end
        function initRoot_Node_const(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*11)
            ptr = StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Node_const_getType(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 5, 3)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function Node_const_initType(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 8)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_const_getValue(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 5, 4)
            @assert isnothing(p) || (p.data_word_count == Value_data_word_count) && p.pointer_count == Value_pointer_count
            p
        end
        function Node_const_initValue(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 9)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*3)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(2), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_getAnnotation(ptr::StructPointer)
            ptr
        end
        function Node_initAnnotation(ptr)
            write_bits(ptr, 12, UInt16, 5) # union discriminant
            ptr
        end
        function root_Node_annotation(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_annotation_data_word_count) && p.pointer_count == Node_annotation_pointer_count
            p
        end
        function initRoot_Node_annotation(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*11)
            ptr = StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Node_annotation_getType(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 5, 3)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function Node_annotation_initType(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 8)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_annotation_getTargetsFile(ptr)
            value = read_bool(ptr, 112)
            value
        end
        function Node_annotation_setTargetsFile(ptr, value)
            write_bool(ptr, 112, value)
        end
        function Node_annotation_getTargetsConst(ptr)
            value = read_bool(ptr, 113)
            value
        end
        function Node_annotation_setTargetsConst(ptr, value)
            write_bool(ptr, 113, value)
        end
        function Node_annotation_getTargetsEnum(ptr)
            value = read_bool(ptr, 114)
            value
        end
        function Node_annotation_setTargetsEnum(ptr, value)
            write_bool(ptr, 114, value)
        end
        function Node_annotation_getTargetsEnumerant(ptr)
            value = read_bool(ptr, 115)
            value
        end
        function Node_annotation_setTargetsEnumerant(ptr, value)
            write_bool(ptr, 115, value)
        end
        function Node_annotation_getTargetsStruct(ptr)
            value = read_bool(ptr, 116)
            value
        end
        function Node_annotation_setTargetsStruct(ptr, value)
            write_bool(ptr, 116, value)
        end
        function Node_annotation_getTargetsField(ptr)
            value = read_bool(ptr, 117)
            value
        end
        function Node_annotation_setTargetsField(ptr, value)
            write_bool(ptr, 117, value)
        end
        function Node_annotation_getTargetsUnion(ptr)
            value = read_bool(ptr, 118)
            value
        end
        function Node_annotation_setTargetsUnion(ptr, value)
            write_bool(ptr, 118, value)
        end
        function Node_annotation_getTargetsGroup(ptr)
            value = read_bool(ptr, 119)
            value
        end
        function Node_annotation_setTargetsGroup(ptr, value)
            write_bool(ptr, 119, value)
        end
        function Node_annotation_getTargetsInterface(ptr)
            value = read_bool(ptr, 120)
            value
        end
        function Node_annotation_setTargetsInterface(ptr, value)
            write_bool(ptr, 120, value)
        end
        function Node_annotation_getTargetsMethod(ptr)
            value = read_bool(ptr, 121)
            value
        end
        function Node_annotation_setTargetsMethod(ptr, value)
            write_bool(ptr, 121, value)
        end
        function Node_annotation_getTargetsParam(ptr)
            value = read_bool(ptr, 122)
            value
        end
        function Node_annotation_setTargetsParam(ptr, value)
            write_bool(ptr, 122, value)
        end
        function Node_annotation_getTargetsAnnotation(ptr)
            value = read_bool(ptr, 123)
            value
        end
        function Node_annotation_setTargetsAnnotation(ptr, value)
            write_bool(ptr, 123, value)
        end
        function Node_initParameters(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 10)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (0 + 1)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(0), UInt16(1))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_getParameters(ptr::Nothing)
            []
        end
        function Node_getParameters(ptr)
            p = read_list_pointer(ptr, 5, 5, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Node_Parameter_data_word_count) && p.pointer_count == Node_Parameter_pointer_count
            p
        end
        function Node_getIsGeneric(ptr)
            value = read_bool(ptr, 288)
            value
        end
        function Node_setIsGeneric(ptr, value)
            write_bool(ptr, 288, value)
        end
        const Field_noDiscriminant = 65535
        const Field_data_word_count = 3
        const Field_pointer_count = 4
        @enum Field_union::UInt16 Field_union_slot Field_union_group 
        function Field_which(ptr::StructPointer)
            Field_union(read_bits(ptr, 8, UInt16))
        end
        function root_Field(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Field_data_word_count) && p.pointer_count == Field_pointer_count
            p
        end
        function initRoot_Field(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*7)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Field_getName(ptr)
            p = read_list_pointer(ptr, 3, 0)
            read_text(p)
        end
        function Field_setName(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_text(child_ptr, txt)
        end
        function Field_getCodeOrder(ptr)
            value = read_bits(ptr, 0, UInt16)
            value
        end
        function Field_setCodeOrder(ptr, value)
            write_bits(ptr, 0, UInt16, value)
        end
        function Field_initAnnotations(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 4)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Field_getAnnotations(ptr::Nothing)
            []
        end
        function Field_getAnnotations(ptr)
            p = read_list_pointer(ptr, 3, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Annotation_data_word_count) && p.pointer_count == Annotation_pointer_count
            p
        end
        function Field_getDiscriminantValue(ptr)
            value = read_bits(ptr, 2, UInt16)
            value = xor(value, UInt16(65535))
            value
        end
        function Field_setDiscriminantValue(ptr, value)
            write_bits(ptr, 2, UInt16, value)
        end
        function Field_getSlot(ptr::StructPointer)
            ptr
        end
        function Field_initSlot(ptr)
            write_bits(ptr, 8, UInt16, 0) # union discriminant
            ptr
        end
        function root_Field_slot(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Field_slot_data_word_count) && p.pointer_count == Field_slot_pointer_count
            p
        end
        function initRoot_Field_slot(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*7)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Field_slot_getOffset(ptr)
            value = read_bits(ptr, 4, UInt32)
            value
        end
        function Field_slot_setOffset(ptr, value)
            write_bits(ptr, 4, UInt32, value)
        end
        function Field_slot_getType(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 3, 2)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function Field_slot_initType(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 5)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Field_slot_getDefaultValue(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 3, 3)
            @assert isnothing(p) || (p.data_word_count == Value_data_word_count) && p.pointer_count == Value_pointer_count
            p
        end
        function Field_slot_initDefaultValue(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 6)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*3)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(2), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Field_slot_getHadExplicitDefault(ptr)
            value = read_bool(ptr, 128)
            value
        end
        function Field_slot_setHadExplicitDefault(ptr, value)
            write_bool(ptr, 128, value)
        end
        function Field_getGroup(ptr::StructPointer)
            ptr
        end
        function Field_initGroup(ptr)
            write_bits(ptr, 8, UInt16, 1) # union discriminant
            ptr
        end
        function root_Field_group(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Field_group_data_word_count) && p.pointer_count == Field_group_pointer_count
            p
        end
        function initRoot_Field_group(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*7)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Field_group_getTypeId(ptr)
            value = read_bits(ptr, 16, UInt64)
            value
        end
        function Field_group_setTypeId(ptr, value)
            write_bits(ptr, 16, UInt64, value)
        end
        function Field_getOrdinal(ptr::StructPointer)
            ptr
        end
        function Field_initOrdinal(ptr)
            ptr
        end
        @enum Field_ordinal_union::UInt16 Field_ordinal_union_implicit Field_ordinal_union_explicit 
        function Field_ordinal_which(ptr::StructPointer)
            Field_ordinal_union(read_bits(ptr, 10, UInt16))
        end
        function root_Field_ordinal(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Field_ordinal_data_word_count) && p.pointer_count == Field_ordinal_pointer_count
            p
        end
        function initRoot_Field_ordinal(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*7)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Field_ordinal_setImplicit(ptr)
            write_bits(ptr, 10, UInt16, 0) # union discriminant
        end
        function Field_ordinal_getExplicit(ptr)
            value = read_bits(ptr, 12, UInt16)
            value
        end
        function Field_ordinal_setExplicit(ptr, value)
            write_bits(ptr, 12, UInt16, value)
            write_bits(ptr, 10, UInt16, 1) # union discriminant
        end
        const Enumerant_data_word_count = 1
        const Enumerant_pointer_count = 2
        function root_Enumerant(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Enumerant_data_word_count) && p.pointer_count == Enumerant_pointer_count
            p
        end
        function initRoot_Enumerant(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*3)
            ptr = StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Enumerant_getName(ptr)
            p = read_list_pointer(ptr, 1, 0)
            read_text(p)
        end
        function Enumerant_setName(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_text(child_ptr, txt)
        end
        function Enumerant_getCodeOrder(ptr)
            value = read_bits(ptr, 0, UInt16)
            value
        end
        function Enumerant_setCodeOrder(ptr, value)
            write_bits(ptr, 0, UInt16, value)
        end
        function Enumerant_initAnnotations(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Enumerant_getAnnotations(ptr::Nothing)
            []
        end
        function Enumerant_getAnnotations(ptr)
            p = read_list_pointer(ptr, 1, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Annotation_data_word_count) && p.pointer_count == Annotation_pointer_count
            p
        end
        const Superclass_data_word_count = 1
        const Superclass_pointer_count = 1
        function root_Superclass(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Superclass_data_word_count) && p.pointer_count == Superclass_pointer_count
            p
        end
        function initRoot_Superclass(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*2)
            ptr = StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Superclass_getId(ptr)
            value = read_bits(ptr, 0, UInt64)
            value
        end
        function Superclass_setId(ptr, value)
            write_bits(ptr, 0, UInt64, value)
        end
        function Superclass_getBrand(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 1, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Superclass_initBrand(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        const Method_data_word_count = 3
        const Method_pointer_count = 5
        function root_Method(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Method_data_word_count) && p.pointer_count == Method_pointer_count
            p
        end
        function initRoot_Method(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*8)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(5))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Method_getName(ptr)
            p = read_list_pointer(ptr, 3, 0)
            read_text(p)
        end
        function Method_setName(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_text(child_ptr, txt)
        end
        function Method_getCodeOrder(ptr)
            value = read_bits(ptr, 0, UInt16)
            value
        end
        function Method_setCodeOrder(ptr, value)
            write_bits(ptr, 0, UInt16, value)
        end
        function Method_getParamStructType(ptr)
            value = read_bits(ptr, 8, UInt64)
            value
        end
        function Method_setParamStructType(ptr, value)
            write_bits(ptr, 8, UInt64, value)
        end
        function Method_getResultStructType(ptr)
            value = read_bits(ptr, 16, UInt64)
            value
        end
        function Method_setResultStructType(ptr, value)
            write_bits(ptr, 16, UInt64, value)
        end
        function Method_initAnnotations(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 4)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_getAnnotations(ptr::Nothing)
            []
        end
        function Method_getAnnotations(ptr)
            p = read_list_pointer(ptr, 3, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Annotation_data_word_count) && p.pointer_count == Annotation_pointer_count
            p
        end
        function Method_getParamBrand(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 3, 2)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Method_initParamBrand(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 5)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_getResultBrand(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 3, 3)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Method_initResultBrand(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 6)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_initImplicitParameters(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 7)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (0 + 1)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(0), UInt16(1))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_getImplicitParameters(ptr::Nothing)
            []
        end
        function Method_getImplicitParameters(ptr)
            p = read_list_pointer(ptr, 3, 4, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Node_Parameter_data_word_count) && p.pointer_count == Node_Parameter_pointer_count
            p
        end
        const Type_data_word_count = 3
        const Type_pointer_count = 1
        @enum Type_union::UInt16 Type_union_void Type_union_bool Type_union_int8 Type_union_int16 Type_union_int32 Type_union_int64 Type_union_uint8 Type_union_uint16 Type_union_uint32 Type_union_uint64 Type_union_float32 Type_union_float64 Type_union_text Type_union_data Type_union_list Type_union_enum Type_union_struct Type_union_interface Type_union_anyPointer 
        function Type_which(ptr::StructPointer)
            Type_union(read_bits(ptr, 0, UInt16))
        end
        function root_Type(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function initRoot_Type(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*4)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Type_setVoid(ptr)
            write_bits(ptr, 0, UInt16, 0) # union discriminant
        end
        function Type_setBool(ptr)
            write_bits(ptr, 0, UInt16, 1) # union discriminant
        end
        function Type_setInt8(ptr)
            write_bits(ptr, 0, UInt16, 2) # union discriminant
        end
        function Type_setInt16(ptr)
            write_bits(ptr, 0, UInt16, 3) # union discriminant
        end
        function Type_setInt32(ptr)
            write_bits(ptr, 0, UInt16, 4) # union discriminant
        end
        function Type_setInt64(ptr)
            write_bits(ptr, 0, UInt16, 5) # union discriminant
        end
        function Type_setUint8(ptr)
            write_bits(ptr, 0, UInt16, 6) # union discriminant
        end
        function Type_setUint16(ptr)
            write_bits(ptr, 0, UInt16, 7) # union discriminant
        end
        function Type_setUint32(ptr)
            write_bits(ptr, 0, UInt16, 8) # union discriminant
        end
        function Type_setUint64(ptr)
            write_bits(ptr, 0, UInt16, 9) # union discriminant
        end
        function Type_setFloat32(ptr)
            write_bits(ptr, 0, UInt16, 10) # union discriminant
        end
        function Type_setFloat64(ptr)
            write_bits(ptr, 0, UInt16, 11) # union discriminant
        end
        function Type_setText(ptr)
            write_bits(ptr, 0, UInt16, 12) # union discriminant
        end
        function Type_setData(ptr)
            write_bits(ptr, 0, UInt16, 13) # union discriminant
        end
        function Type_getList(ptr::StructPointer)
            ptr
        end
        function Type_initList(ptr)
            write_bits(ptr, 0, UInt16, 14) # union discriminant
            ptr
        end
        function root_Type_list(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_list_data_word_count) && p.pointer_count == Type_list_pointer_count
            p
        end
        function initRoot_Type_list(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*4)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Type_list_getElementType(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function Type_list_initElementType(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_getEnum(ptr::StructPointer)
            ptr
        end
        function Type_initEnum(ptr)
            write_bits(ptr, 0, UInt16, 15) # union discriminant
            ptr
        end
        function root_Type_enum(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_enum_data_word_count) && p.pointer_count == Type_enum_pointer_count
            p
        end
        function initRoot_Type_enum(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*4)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Type_enum_getTypeId(ptr)
            value = read_bits(ptr, 8, UInt64)
            value
        end
        function Type_enum_setTypeId(ptr, value)
            write_bits(ptr, 8, UInt64, value)
        end
        function Type_enum_getBrand(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Type_enum_initBrand(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_getStruct(ptr::StructPointer)
            ptr
        end
        function Type_initStruct(ptr)
            write_bits(ptr, 0, UInt16, 16) # union discriminant
            ptr
        end
        function root_Type_struct(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_struct_data_word_count) && p.pointer_count == Type_struct_pointer_count
            p
        end
        function initRoot_Type_struct(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*4)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Type_struct_getTypeId(ptr)
            value = read_bits(ptr, 8, UInt64)
            value
        end
        function Type_struct_setTypeId(ptr, value)
            write_bits(ptr, 8, UInt64, value)
        end
        function Type_struct_getBrand(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Type_struct_initBrand(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_getInterface(ptr::StructPointer)
            ptr
        end
        function Type_initInterface(ptr)
            write_bits(ptr, 0, UInt16, 17) # union discriminant
            ptr
        end
        function root_Type_interface(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_interface_data_word_count) && p.pointer_count == Type_interface_pointer_count
            p
        end
        function initRoot_Type_interface(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*4)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Type_interface_getTypeId(ptr)
            value = read_bits(ptr, 8, UInt64)
            value
        end
        function Type_interface_setTypeId(ptr, value)
            write_bits(ptr, 8, UInt64, value)
        end
        function Type_interface_getBrand(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Type_interface_initBrand(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_getAnyPointer(ptr::StructPointer)
            ptr
        end
        function Type_initAnyPointer(ptr)
            write_bits(ptr, 0, UInt16, 18) # union discriminant
            ptr
        end
        @enum Type_anyPointer_union::UInt16 Type_anyPointer_union_unconstrained Type_anyPointer_union_parameter Type_anyPointer_union_implicitMethodParameter 
        function Type_anyPointer_which(ptr::StructPointer)
            Type_anyPointer_union(read_bits(ptr, 8, UInt16))
        end
        function root_Type_anyPointer(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_anyPointer_data_word_count) && p.pointer_count == Type_anyPointer_pointer_count
            p
        end
        function initRoot_Type_anyPointer(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*4)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Type_anyPointer_getUnconstrained(ptr::StructPointer)
            ptr
        end
        function Type_anyPointer_initUnconstrained(ptr)
            write_bits(ptr, 8, UInt16, 0) # union discriminant
            ptr
        end
        @enum Type_anyPointer_unconstrained_union::UInt16 Type_anyPointer_unconstrained_union_anyKind Type_anyPointer_unconstrained_union_struct Type_anyPointer_unconstrained_union_list Type_anyPointer_unconstrained_union_capability 
        function Type_anyPointer_unconstrained_which(ptr::StructPointer)
            Type_anyPointer_unconstrained_union(read_bits(ptr, 10, UInt16))
        end
        function root_Type_anyPointer_unconstrained(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_anyPointer_unconstrained_data_word_count) && p.pointer_count == Type_anyPointer_unconstrained_pointer_count
            p
        end
        function initRoot_Type_anyPointer_unconstrained(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*4)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Type_anyPointer_unconstrained_setAnyKind(ptr)
            write_bits(ptr, 10, UInt16, 0) # union discriminant
        end
        function Type_anyPointer_unconstrained_setStruct(ptr)
            write_bits(ptr, 10, UInt16, 1) # union discriminant
        end
        function Type_anyPointer_unconstrained_setList(ptr)
            write_bits(ptr, 10, UInt16, 2) # union discriminant
        end
        function Type_anyPointer_unconstrained_setCapability(ptr)
            write_bits(ptr, 10, UInt16, 3) # union discriminant
        end
        function Type_anyPointer_getParameter(ptr::StructPointer)
            ptr
        end
        function Type_anyPointer_initParameter(ptr)
            write_bits(ptr, 8, UInt16, 1) # union discriminant
            ptr
        end
        function root_Type_anyPointer_parameter(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_anyPointer_parameter_data_word_count) && p.pointer_count == Type_anyPointer_parameter_pointer_count
            p
        end
        function initRoot_Type_anyPointer_parameter(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*4)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Type_anyPointer_parameter_getScopeId(ptr)
            value = read_bits(ptr, 16, UInt64)
            value
        end
        function Type_anyPointer_parameter_setScopeId(ptr, value)
            write_bits(ptr, 16, UInt64, value)
        end
        function Type_anyPointer_parameter_getParameterIndex(ptr)
            value = read_bits(ptr, 10, UInt16)
            value
        end
        function Type_anyPointer_parameter_setParameterIndex(ptr, value)
            write_bits(ptr, 10, UInt16, value)
        end
        function Type_anyPointer_getImplicitMethodParameter(ptr::StructPointer)
            ptr
        end
        function Type_anyPointer_initImplicitMethodParameter(ptr)
            write_bits(ptr, 8, UInt16, 2) # union discriminant
            ptr
        end
        function root_Type_anyPointer_implicitMethodParameter(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_anyPointer_implicitMethodParameter_data_word_count) && p.pointer_count == Type_anyPointer_implicitMethodParameter_pointer_count
            p
        end
        function initRoot_Type_anyPointer_implicitMethodParameter(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*4)
            ptr = StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Type_anyPointer_implicitMethodParameter_getParameterIndex(ptr)
            value = read_bits(ptr, 10, UInt16)
            value
        end
        function Type_anyPointer_implicitMethodParameter_setParameterIndex(ptr, value)
            write_bits(ptr, 10, UInt16, value)
        end
        const Brand_Scope_data_word_count = 2
        const Brand_Scope_pointer_count = 1
        @enum Brand_Scope_union::UInt16 Brand_Scope_union_bind Brand_Scope_union_inherit 
        function Brand_Scope_which(ptr::StructPointer)
            Brand_Scope_union(read_bits(ptr, 8, UInt16))
        end
        function root_Brand_Scope(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_Scope_data_word_count) && p.pointer_count == Brand_Scope_pointer_count
            p
        end
        function initRoot_Brand_Scope(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*3)
            ptr = StructPointer(builder, segment, offset, UInt16(2), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Brand_Scope_getScopeId(ptr)
            value = read_bits(ptr, 0, UInt64)
            value
        end
        function Brand_Scope_setScopeId(ptr, value)
            write_bits(ptr, 0, UInt64, value)
        end
        function Brand_Scope_initBind(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            write_list_pointer(pointer_location, child_ptr)
            write_bits(ptr, 8, UInt16, 0) # union discriminant
            child_ptr
        end
        function Brand_Scope_getBind(ptr::Nothing)
            []
        end
        function Brand_Scope_getBind(ptr)
            p = read_list_pointer(ptr, 2, 0, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Brand_Binding_data_word_count) && p.pointer_count == Brand_Binding_pointer_count
            p
        end
        function Brand_Scope_setInherit(ptr)
            write_bits(ptr, 8, UInt16, 1) # union discriminant
        end
        const Brand_Binding_data_word_count = 1
        const Brand_Binding_pointer_count = 1
        @enum Brand_Binding_union::UInt16 Brand_Binding_union_unbound Brand_Binding_union_type 
        function Brand_Binding_which(ptr::StructPointer)
            Brand_Binding_union(read_bits(ptr, 0, UInt16))
        end
        function root_Brand_Binding(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_Binding_data_word_count) && p.pointer_count == Brand_Binding_pointer_count
            p
        end
        function initRoot_Brand_Binding(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*2)
            ptr = StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Brand_Binding_setUnbound(ptr)
            write_bits(ptr, 0, UInt16, 0) # union discriminant
        end
        function Brand_Binding_getType(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 1, 0)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function Brand_Binding_initType(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            write_bits(ptr, 0, UInt16, 1) # union discriminant
            child_ptr
        end
        const Brand_data_word_count = 0
        const Brand_pointer_count = 1
        function root_Brand(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function initRoot_Brand(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*1)
            ptr = StructPointer(builder, segment, offset, UInt16(0), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Brand_initScopes(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 0)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (2 + 1)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(2), UInt16(1))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Brand_getScopes(ptr::Nothing)
            []
        end
        function Brand_getScopes(ptr)
            p = read_list_pointer(ptr, 0, 0, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Brand_Scope_data_word_count) && p.pointer_count == Brand_Scope_pointer_count
            p
        end
        const Value_data_word_count = 2
        const Value_pointer_count = 1
        @enum Value_union::UInt16 Value_union_void Value_union_bool Value_union_int8 Value_union_int16 Value_union_int32 Value_union_int64 Value_union_uint8 Value_union_uint16 Value_union_uint32 Value_union_uint64 Value_union_float32 Value_union_float64 Value_union_text Value_union_data Value_union_list Value_union_enum Value_union_struct Value_union_interface Value_union_anyPointer 
        function Value_which(ptr::StructPointer)
            Value_union(read_bits(ptr, 0, UInt16))
        end
        function root_Value(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Value_data_word_count) && p.pointer_count == Value_pointer_count
            p
        end
        function initRoot_Value(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*3)
            ptr = StructPointer(builder, segment, offset, UInt16(2), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Value_setVoid(ptr)
            write_bits(ptr, 0, UInt16, 0) # union discriminant
        end
        function Value_getBool(ptr)
            value = read_bool(ptr, 16)
            value
        end
        function Value_setBool(ptr, value)
            write_bool(ptr, 16, value)
            write_bits(ptr, 0, UInt16, 1) # union discriminant
        end
        function Value_getInt8(ptr)
            value = read_bits(ptr, 2, UInt8)
            value
        end
        function Value_setInt8(ptr, value)
            write_bits(ptr, 2, UInt8, value)
            write_bits(ptr, 0, UInt16, 2) # union discriminant
        end
        function Value_getInt16(ptr)
            value = read_bits(ptr, 2, UInt16)
            value
        end
        function Value_setInt16(ptr, value)
            write_bits(ptr, 2, UInt16, value)
            write_bits(ptr, 0, UInt16, 3) # union discriminant
        end
        function Value_getInt32(ptr)
            value = read_bits(ptr, 4, UInt32)
            value
        end
        function Value_setInt32(ptr, value)
            write_bits(ptr, 4, UInt32, value)
            write_bits(ptr, 0, UInt16, 4) # union discriminant
        end
        function Value_getInt64(ptr)
            value = read_bits(ptr, 8, UInt64)
            value
        end
        function Value_setInt64(ptr, value)
            write_bits(ptr, 8, UInt64, value)
            write_bits(ptr, 0, UInt16, 5) # union discriminant
        end
        function Value_getUint8(ptr)
            value = read_bits(ptr, 2, UInt8)
            value
        end
        function Value_setUint8(ptr, value)
            write_bits(ptr, 2, UInt8, value)
            write_bits(ptr, 0, UInt16, 6) # union discriminant
        end
        function Value_getUint16(ptr)
            value = read_bits(ptr, 2, UInt16)
            value
        end
        function Value_setUint16(ptr, value)
            write_bits(ptr, 2, UInt16, value)
            write_bits(ptr, 0, UInt16, 7) # union discriminant
        end
        function Value_getUint32(ptr)
            value = read_bits(ptr, 4, UInt32)
            value
        end
        function Value_setUint32(ptr, value)
            write_bits(ptr, 4, UInt32, value)
            write_bits(ptr, 0, UInt16, 8) # union discriminant
        end
        function Value_getUint64(ptr)
            value = read_bits(ptr, 8, UInt64)
            value
        end
        function Value_setUint64(ptr, value)
            write_bits(ptr, 8, UInt64, value)
            write_bits(ptr, 0, UInt16, 9) # union discriminant
        end
        function Value_getFloat32(ptr)
            value = read_bits(ptr, 4, Float32)
            value
        end
        function Value_setFloat32(ptr, value)
            write_bits(ptr, 4, Float32, value)
            write_bits(ptr, 0, UInt16, 10) # union discriminant
        end
        function Value_getFloat64(ptr)
            value = read_bits(ptr, 8, Float64)
            value
        end
        function Value_setFloat64(ptr, value)
            write_bits(ptr, 8, Float64, value)
            write_bits(ptr, 0, UInt16, 11) # union discriminant
        end
        function Value_getText(ptr)
            p = read_list_pointer(ptr, 2, 0)
            read_text(p)
        end
        function Value_setText(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_bits(ptr, 0, UInt16, 12) # union discriminant
            write_text(child_ptr, txt)
        end
        # Value's data has type Capnp.Generator.SchemaData() which is not supported by Capnp.jl yet
        function Value_getList(ptr)
            value = read_bits(ptr, 2, Int64)
            if value == 0
                Nothing
            else
                throw("TODO")
            end
        end
        function Value_getEnum(ptr)
            value = read_bits(ptr, 2, UInt16)
            value
        end
        function Value_setEnum(ptr, value)
            write_bits(ptr, 2, UInt16, value)
            write_bits(ptr, 0, UInt16, 15) # union discriminant
        end
        function Value_getStruct(ptr)
            value = read_bits(ptr, 2, Int64)
            if value == 0
                Nothing
            else
                throw("TODO")
            end
        end
        function Value_setInterface(ptr)
            write_bits(ptr, 0, UInt16, 17) # union discriminant
        end
        function Value_getAnyPointer(ptr)
            value = read_bits(ptr, 2, Int64)
            if value == 0
                Nothing
            else
                throw("TODO")
            end
        end
        const Annotation_data_word_count = 1
        const Annotation_pointer_count = 2
        function root_Annotation(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Annotation_data_word_count) && p.pointer_count == Annotation_pointer_count
            p
        end
        function initRoot_Annotation(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*3)
            ptr = StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            write_root_struct_pointer(ptr)
            ptr
        end
        function Annotation_getId(ptr)
            value = read_bits(ptr, 0, UInt64)
            value
        end
        function Annotation_setId(ptr, value)
            write_bits(ptr, 0, UInt64, value)
        end
        function Annotation_getValue(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 1, 0)
            @assert isnothing(p) || (p.data_word_count == Value_data_word_count) && p.pointer_count == Value_pointer_count
            p
        end
        function Annotation_initValue(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*3)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(2), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Annotation_getBrand(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 1, 1)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Annotation_initBrand(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        @enum ElementSize::UInt16 ElementSize_empty ElementSize_bit ElementSize_byte ElementSize_twoBytes ElementSize_fourBytes ElementSize_eightBytes ElementSize_pointer ElementSize_inlineComposite 
        const CapnpVersion_data_word_count = 1
        const CapnpVersion_pointer_count = 0
        function root_CapnpVersion(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == CapnpVersion_data_word_count) && p.pointer_count == CapnpVersion_pointer_count
            p
        end
        function initRoot_CapnpVersion(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*1)
            ptr = StructPointer(builder, segment, offset, UInt16(1), UInt16(0))
            write_root_struct_pointer(ptr)
            ptr
        end
        function CapnpVersion_getMajor(ptr)
            value = read_bits(ptr, 0, UInt16)
            value
        end
        function CapnpVersion_setMajor(ptr, value)
            write_bits(ptr, 0, UInt16, value)
        end
        function CapnpVersion_getMinor(ptr)
            value = read_bits(ptr, 2, UInt8)
            value
        end
        function CapnpVersion_setMinor(ptr, value)
            write_bits(ptr, 2, UInt8, value)
        end
        function CapnpVersion_getMicro(ptr)
            value = read_bits(ptr, 3, UInt8)
            value
        end
        function CapnpVersion_setMicro(ptr, value)
            write_bits(ptr, 3, UInt8, value)
        end
        const CodeGeneratorRequest_RequestedFile_Import_data_word_count = 1
        const CodeGeneratorRequest_RequestedFile_Import_pointer_count = 1
        function root_CodeGeneratorRequest_RequestedFile_Import(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == CodeGeneratorRequest_RequestedFile_Import_data_word_count) && p.pointer_count == CodeGeneratorRequest_RequestedFile_Import_pointer_count
            p
        end
        function initRoot_CodeGeneratorRequest_RequestedFile_Import(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*2)
            ptr = StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            write_root_struct_pointer(ptr)
            ptr
        end
        function CodeGeneratorRequest_RequestedFile_Import_getId(ptr)
            value = read_bits(ptr, 0, UInt64)
            value
        end
        function CodeGeneratorRequest_RequestedFile_Import_setId(ptr, value)
            write_bits(ptr, 0, UInt64, value)
        end
        function CodeGeneratorRequest_RequestedFile_Import_getName(ptr)
            p = read_list_pointer(ptr, 1, 0)
            read_text(p)
        end
        function CodeGeneratorRequest_RequestedFile_Import_setName(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_text(child_ptr, txt)
        end
        const CodeGeneratorRequest_RequestedFile_data_word_count = 1
        const CodeGeneratorRequest_RequestedFile_pointer_count = 2
        function root_CodeGeneratorRequest_RequestedFile(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == CodeGeneratorRequest_RequestedFile_data_word_count) && p.pointer_count == CodeGeneratorRequest_RequestedFile_pointer_count
            p
        end
        function initRoot_CodeGeneratorRequest_RequestedFile(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*3)
            ptr = StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            write_root_struct_pointer(ptr)
            ptr
        end
        function CodeGeneratorRequest_RequestedFile_getId(ptr)
            value = read_bits(ptr, 0, UInt64)
            value
        end
        function CodeGeneratorRequest_RequestedFile_setId(ptr, value)
            write_bits(ptr, 0, UInt64, value)
        end
        function CodeGeneratorRequest_RequestedFile_getFilename(ptr)
            p = read_list_pointer(ptr, 1, 0)
            read_text(p)
        end
        function CodeGeneratorRequest_RequestedFile_setFilename(ptr, txt)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Byte, UInt32(length(txt) + 1))
            write_list_pointer(pointer_location, child_ptr)
            write_text(child_ptr, txt)
        end
        function CodeGeneratorRequest_RequestedFile_initImports(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_RequestedFile_getImports(ptr::Nothing)
            []
        end
        function CodeGeneratorRequest_RequestedFile_getImports(ptr)
            p = read_list_pointer(ptr, 1, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == CodeGeneratorRequest_RequestedFile_Import_data_word_count) && p.pointer_count == CodeGeneratorRequest_RequestedFile_Import_pointer_count
            p
        end
        const CodeGeneratorRequest_data_word_count = 0
        const CodeGeneratorRequest_pointer_count = 4
        function root_CodeGeneratorRequest(message)
            ptr = StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == CodeGeneratorRequest_data_word_count) && p.pointer_count == CodeGeneratorRequest_pointer_count
            p
        end
        function initRoot_CodeGeneratorRequest(builder)
            pointer_location = WirePointer(1, 0)
            alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = alloc(builder, pointer_location, 8*4)
            ptr = StructPointer(builder, segment, offset, UInt16(0), UInt16(4))
            write_root_struct_pointer(ptr)
            ptr
        end
        function CodeGeneratorRequest_initNodes(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 0)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (5 + 6)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(5), UInt16(6))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_getNodes(ptr::Nothing)
            []
        end
        function CodeGeneratorRequest_getNodes(ptr)
            p = read_list_pointer(ptr, 0, 0, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Node_data_word_count) && p.pointer_count == Node_pointer_count
            p
        end
        function CodeGeneratorRequest_initRequestedFiles(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_getRequestedFiles(ptr::Nothing)
            []
        end
        function CodeGeneratorRequest_getRequestedFiles(ptr)
            p = read_list_pointer(ptr, 0, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == CodeGeneratorRequest_RequestedFile_data_word_count) && p.pointer_count == CodeGeneratorRequest_RequestedFile_pointer_count
            p
        end
        function CodeGeneratorRequest_getCapnpVersion(ptr::StructPointer{T}) where T <: Reader
            p = read_struct_pointer(ptr, 0, 2)
            @assert isnothing(p) || (p.data_word_count == CapnpVersion_data_word_count) && p.pointer_count == CapnpVersion_pointer_count
            p
        end
        function CodeGeneratorRequest_initCapnpVersion(ptr)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = StructPointer(ptr.traverser, segment, offset, UInt16(1), UInt16(0))
            write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_initSourceInfo(ptr, size)
            pointer_location = WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_getSourceInfo(ptr::Nothing)
            []
        end
        function CodeGeneratorRequest_getSourceInfo(ptr)
            p = read_list_pointer(ptr, 0, 3, Capnp.CapnpStruct)
            @assert isempty(p) || p isa SimpleListPointer ||
               (p isa CompositeListPointer && p.data_word_count == Node_SourceInfo_data_word_count) && p.pointer_count == Node_SourceInfo_pointer_count
            p
        end
    end
end
end

