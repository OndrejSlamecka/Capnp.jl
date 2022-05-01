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
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_Parameter_data_word_count) && p.pointer_count == Node_Parameter_pointer_count
            p
        end
        function initRoot_Node_Parameter(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*1)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Node_Parameter_getName(ptr)
            p = Capnp.read_list_pointer(ptr, 0, 0)
            Capnp.read_text(p)
        end
        function Node_Parameter_setName(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        const Node_NestedNode_data_word_count = 1
        const Node_NestedNode_pointer_count = 1
        function root_Node_NestedNode(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_NestedNode_data_word_count) && p.pointer_count == Node_NestedNode_pointer_count
            p
        end
        function initRoot_Node_NestedNode(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*2)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Node_NestedNode_getName(ptr)
            p = Capnp.read_list_pointer(ptr, 1, 0)
            Capnp.read_text(p)
        end
        function Node_NestedNode_setName(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Node_NestedNode_getId(ptr)
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Node_NestedNode_setId(ptr, value)
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        const Node_SourceInfo_Member_data_word_count = 0
        const Node_SourceInfo_Member_pointer_count = 1
        function root_Node_SourceInfo_Member(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_SourceInfo_Member_data_word_count) && p.pointer_count == Node_SourceInfo_Member_pointer_count
            p
        end
        function initRoot_Node_SourceInfo_Member(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*1)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Node_SourceInfo_Member_getDocComment(ptr)
            p = Capnp.read_list_pointer(ptr, 0, 0)
            Capnp.read_text(p)
        end
        function Node_SourceInfo_Member_setDocComment(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        const Node_SourceInfo_data_word_count = 1
        const Node_SourceInfo_pointer_count = 2
        function root_Node_SourceInfo(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_SourceInfo_data_word_count) && p.pointer_count == Node_SourceInfo_pointer_count
            p
        end
        function initRoot_Node_SourceInfo(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Node_SourceInfo_getId(ptr)
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Node_SourceInfo_setId(ptr, value)
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Node_SourceInfo_getDocComment(ptr)
            p = Capnp.read_list_pointer(ptr, 1, 0)
            Capnp.read_text(p)
        end
        function Node_SourceInfo_setDocComment(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Node_SourceInfo_getMembers(ptr::Nothing)
            []
        end
        function Node_SourceInfo_getMembers(ptr)
            p = Capnp.read_list_pointer(ptr, 1, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Node_SourceInfo_Member_data_word_count) && p.pointer_count == Node_SourceInfo_Member_pointer_count
            p
        end
        function Node_SourceInfo_initMembers(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (0 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(0), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        const Node_data_word_count = 5
        const Node_pointer_count = 6
        @enum Node_union::UInt16 Node_union_file Node_union_struct Node_union_enum Node_union_interface Node_union_const Node_union_annotation 
        function Node_which(ptr::Capnp.StructPointer)
            Node_union(Capnp.read_bits(ptr, 12, UInt16))
        end
        function root_Node(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_data_word_count) && p.pointer_count == Node_pointer_count
            p
        end
        function initRoot_Node(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Node_getId(ptr)
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Node_setId(ptr, value)
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Node_getDisplayName(ptr)
            p = Capnp.read_list_pointer(ptr, 5, 0)
            Capnp.read_text(p)
        end
        function Node_setDisplayName(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 5)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Node_getDisplayNamePrefixLength(ptr)
            value = Capnp.read_bits(ptr, 8, UInt32)
            value
        end
        function Node_setDisplayNamePrefixLength(ptr, value)
            Capnp.write_bits(ptr, 8, UInt32, value)
        end
        function Node_getScopeId(ptr)
            value = Capnp.read_bits(ptr, 16, UInt64)
            value
        end
        function Node_setScopeId(ptr, value)
            Capnp.write_bits(ptr, 16, UInt64, value)
        end
        function Node_getNestedNodes(ptr::Nothing)
            []
        end
        function Node_getNestedNodes(ptr)
            p = Capnp.read_list_pointer(ptr, 5, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Node_NestedNode_data_word_count) && p.pointer_count == Node_NestedNode_pointer_count
            p
        end
        function Node_initNestedNodes(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 6)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_getAnnotations(ptr::Nothing)
            []
        end
        function Node_getAnnotations(ptr)
            p = Capnp.read_list_pointer(ptr, 5, 2, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Annotation_data_word_count) && p.pointer_count == Annotation_pointer_count
            p
        end
        function Node_initAnnotations(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 7)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_setFile(ptr)
            Capnp.write_bits(ptr, 12, UInt16, 0) # union discriminant
        end
        function Node_getStruct(ptr::Capnp.StructPointer)
            ptr
        end
        function Node_initStruct(ptr)
            Capnp.write_bits(ptr, 12, UInt16, 1) # union discriminant
            ptr
        end
        function root_Node_struct(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_struct_data_word_count) && p.pointer_count == Node_struct_pointer_count
            p
        end
        function initRoot_Node_struct(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Node_struct_getDataWordCount(ptr)
            value = Capnp.read_bits(ptr, 14, UInt16)
            value
        end
        function Node_struct_setDataWordCount(ptr, value)
            Capnp.write_bits(ptr, 14, UInt16, value)
        end
        function Node_struct_getPointerCount(ptr)
            value = Capnp.read_bits(ptr, 24, UInt16)
            value
        end
        function Node_struct_setPointerCount(ptr, value)
            Capnp.write_bits(ptr, 24, UInt16, value)
        end
        function Node_struct_getPreferredListEncoding(ptr)
            value = Capnp.read_bits(ptr, 26, ElementSize)
            value
        end
        function Node_struct_setPreferredListEncoding(ptr, value)
            value = Capnp.write_bits(ptr, 26, ElementSize, value)
        end
        function Node_struct_getIsGroup(ptr)
            value = Capnp.read_bool(ptr, 224)
            value
        end
        function Node_struct_setIsGroup(ptr, value)
            Capnp.write_bool(ptr, 224, value)
        end
        function Node_struct_getDiscriminantCount(ptr)
            value = Capnp.read_bits(ptr, 30, UInt16)
            value
        end
        function Node_struct_setDiscriminantCount(ptr, value)
            Capnp.write_bits(ptr, 30, UInt16, value)
        end
        function Node_struct_getDiscriminantOffset(ptr)
            value = Capnp.read_bits(ptr, 32, UInt32)
            value
        end
        function Node_struct_setDiscriminantOffset(ptr, value)
            Capnp.write_bits(ptr, 32, UInt32, value)
        end
        function Node_struct_getFields(ptr::Nothing)
            []
        end
        function Node_struct_getFields(ptr)
            p = Capnp.read_list_pointer(ptr, 5, 3, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Field_data_word_count) && p.pointer_count == Field_pointer_count
            p
        end
        function Node_struct_initFields(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 8)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (3 + 4)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(3), UInt16(4))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_getEnum(ptr::Capnp.StructPointer)
            ptr
        end
        function Node_initEnum(ptr)
            Capnp.write_bits(ptr, 12, UInt16, 2) # union discriminant
            ptr
        end
        function root_Node_enum(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_enum_data_word_count) && p.pointer_count == Node_enum_pointer_count
            p
        end
        function initRoot_Node_enum(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Node_enum_getEnumerants(ptr::Nothing)
            []
        end
        function Node_enum_getEnumerants(ptr)
            p = Capnp.read_list_pointer(ptr, 5, 3, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Enumerant_data_word_count) && p.pointer_count == Enumerant_pointer_count
            p
        end
        function Node_enum_initEnumerants(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 8)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_getInterface(ptr::Capnp.StructPointer)
            ptr
        end
        function Node_initInterface(ptr)
            Capnp.write_bits(ptr, 12, UInt16, 3) # union discriminant
            ptr
        end
        function root_Node_interface(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_interface_data_word_count) && p.pointer_count == Node_interface_pointer_count
            p
        end
        function initRoot_Node_interface(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Node_interface_getMethods(ptr::Nothing)
            []
        end
        function Node_interface_getMethods(ptr)
            p = Capnp.read_list_pointer(ptr, 5, 3, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Method_data_word_count) && p.pointer_count == Method_pointer_count
            p
        end
        function Node_interface_initMethods(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 8)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (3 + 5)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(3), UInt16(5))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_interface_getSuperclasses(ptr::Nothing)
            []
        end
        function Node_interface_getSuperclasses(ptr)
            p = Capnp.read_list_pointer(ptr, 5, 4, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Superclass_data_word_count) && p.pointer_count == Superclass_pointer_count
            p
        end
        function Node_interface_initSuperclasses(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 9)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_getConst(ptr::Capnp.StructPointer)
            ptr
        end
        function Node_initConst(ptr)
            Capnp.write_bits(ptr, 12, UInt16, 4) # union discriminant
            ptr
        end
        function root_Node_const(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_const_data_word_count) && p.pointer_count == Node_const_pointer_count
            p
        end
        function initRoot_Node_const(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Node_const_getType(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 5, 3)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function Node_const_initType(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 8)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_const_getValue(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 5, 4)
            @assert isnothing(p) || (p.data_word_count == Value_data_word_count) && p.pointer_count == Value_pointer_count
            p
        end
        function Node_const_initValue(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 9)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*3)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(2), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_getAnnotation(ptr::Capnp.StructPointer)
            ptr
        end
        function Node_initAnnotation(ptr)
            Capnp.write_bits(ptr, 12, UInt16, 5) # union discriminant
            ptr
        end
        function root_Node_annotation(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Node_annotation_data_word_count) && p.pointer_count == Node_annotation_pointer_count
            p
        end
        function initRoot_Node_annotation(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Node_annotation_getType(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 5, 3)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function Node_annotation_initType(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 8)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_annotation_getTargetsFile(ptr)
            value = Capnp.read_bool(ptr, 112)
            value
        end
        function Node_annotation_setTargetsFile(ptr, value)
            Capnp.write_bool(ptr, 112, value)
        end
        function Node_annotation_getTargetsConst(ptr)
            value = Capnp.read_bool(ptr, 113)
            value
        end
        function Node_annotation_setTargetsConst(ptr, value)
            Capnp.write_bool(ptr, 113, value)
        end
        function Node_annotation_getTargetsEnum(ptr)
            value = Capnp.read_bool(ptr, 114)
            value
        end
        function Node_annotation_setTargetsEnum(ptr, value)
            Capnp.write_bool(ptr, 114, value)
        end
        function Node_annotation_getTargetsEnumerant(ptr)
            value = Capnp.read_bool(ptr, 115)
            value
        end
        function Node_annotation_setTargetsEnumerant(ptr, value)
            Capnp.write_bool(ptr, 115, value)
        end
        function Node_annotation_getTargetsStruct(ptr)
            value = Capnp.read_bool(ptr, 116)
            value
        end
        function Node_annotation_setTargetsStruct(ptr, value)
            Capnp.write_bool(ptr, 116, value)
        end
        function Node_annotation_getTargetsField(ptr)
            value = Capnp.read_bool(ptr, 117)
            value
        end
        function Node_annotation_setTargetsField(ptr, value)
            Capnp.write_bool(ptr, 117, value)
        end
        function Node_annotation_getTargetsUnion(ptr)
            value = Capnp.read_bool(ptr, 118)
            value
        end
        function Node_annotation_setTargetsUnion(ptr, value)
            Capnp.write_bool(ptr, 118, value)
        end
        function Node_annotation_getTargetsGroup(ptr)
            value = Capnp.read_bool(ptr, 119)
            value
        end
        function Node_annotation_setTargetsGroup(ptr, value)
            Capnp.write_bool(ptr, 119, value)
        end
        function Node_annotation_getTargetsInterface(ptr)
            value = Capnp.read_bool(ptr, 120)
            value
        end
        function Node_annotation_setTargetsInterface(ptr, value)
            Capnp.write_bool(ptr, 120, value)
        end
        function Node_annotation_getTargetsMethod(ptr)
            value = Capnp.read_bool(ptr, 121)
            value
        end
        function Node_annotation_setTargetsMethod(ptr, value)
            Capnp.write_bool(ptr, 121, value)
        end
        function Node_annotation_getTargetsParam(ptr)
            value = Capnp.read_bool(ptr, 122)
            value
        end
        function Node_annotation_setTargetsParam(ptr, value)
            Capnp.write_bool(ptr, 122, value)
        end
        function Node_annotation_getTargetsAnnotation(ptr)
            value = Capnp.read_bool(ptr, 123)
            value
        end
        function Node_annotation_setTargetsAnnotation(ptr, value)
            Capnp.write_bool(ptr, 123, value)
        end
        function Node_getParameters(ptr::Nothing)
            []
        end
        function Node_getParameters(ptr)
            p = Capnp.read_list_pointer(ptr, 5, 5, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Node_Parameter_data_word_count) && p.pointer_count == Node_Parameter_pointer_count
            p
        end
        function Node_initParameters(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 10)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (0 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(0), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_getIsGeneric(ptr)
            value = Capnp.read_bool(ptr, 288)
            value
        end
        function Node_setIsGeneric(ptr, value)
            Capnp.write_bool(ptr, 288, value)
        end
        const Field_noDiscriminant = 65535
        const Field_data_word_count = 3
        const Field_pointer_count = 4
        @enum Field_union::UInt16 Field_union_slot Field_union_group 
        function Field_which(ptr::Capnp.StructPointer)
            Field_union(Capnp.read_bits(ptr, 8, UInt16))
        end
        function root_Field(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Field_data_word_count) && p.pointer_count == Field_pointer_count
            p
        end
        function initRoot_Field(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*7)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Field_getName(ptr)
            p = Capnp.read_list_pointer(ptr, 3, 0)
            Capnp.read_text(p)
        end
        function Field_setName(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Field_getCodeOrder(ptr)
            value = Capnp.read_bits(ptr, 0, UInt16)
            value
        end
        function Field_setCodeOrder(ptr, value)
            Capnp.write_bits(ptr, 0, UInt16, value)
        end
        function Field_getAnnotations(ptr::Nothing)
            []
        end
        function Field_getAnnotations(ptr)
            p = Capnp.read_list_pointer(ptr, 3, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Annotation_data_word_count) && p.pointer_count == Annotation_pointer_count
            p
        end
        function Field_initAnnotations(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 4)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Field_getDiscriminantValue(ptr)
            value = Capnp.read_bits(ptr, 2, UInt16)
            value = xor(value, UInt16(65535))
            value
        end
        function Field_setDiscriminantValue(ptr, value)
            Capnp.write_bits(ptr, 2, UInt16, value)
        end
        function Field_getSlot(ptr::Capnp.StructPointer)
            ptr
        end
        function Field_initSlot(ptr)
            Capnp.write_bits(ptr, 8, UInt16, 0) # union discriminant
            ptr
        end
        function root_Field_slot(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Field_slot_data_word_count) && p.pointer_count == Field_slot_pointer_count
            p
        end
        function initRoot_Field_slot(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*7)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Field_slot_getOffset(ptr)
            value = Capnp.read_bits(ptr, 4, UInt32)
            value
        end
        function Field_slot_setOffset(ptr, value)
            Capnp.write_bits(ptr, 4, UInt32, value)
        end
        function Field_slot_getType(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 3, 2)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function Field_slot_initType(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 5)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Field_slot_getDefaultValue(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 3, 3)
            @assert isnothing(p) || (p.data_word_count == Value_data_word_count) && p.pointer_count == Value_pointer_count
            p
        end
        function Field_slot_initDefaultValue(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 6)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*3)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(2), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Field_slot_getHadExplicitDefault(ptr)
            value = Capnp.read_bool(ptr, 128)
            value
        end
        function Field_slot_setHadExplicitDefault(ptr, value)
            Capnp.write_bool(ptr, 128, value)
        end
        function Field_getGroup(ptr::Capnp.StructPointer)
            ptr
        end
        function Field_initGroup(ptr)
            Capnp.write_bits(ptr, 8, UInt16, 1) # union discriminant
            ptr
        end
        function root_Field_group(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Field_group_data_word_count) && p.pointer_count == Field_group_pointer_count
            p
        end
        function initRoot_Field_group(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*7)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Field_group_getTypeId(ptr)
            value = Capnp.read_bits(ptr, 16, UInt64)
            value
        end
        function Field_group_setTypeId(ptr, value)
            Capnp.write_bits(ptr, 16, UInt64, value)
        end
        function Field_getOrdinal(ptr::Capnp.StructPointer)
            ptr
        end
        function Field_initOrdinal(ptr)
            ptr
        end
        @enum Field_ordinal_union::UInt16 Field_ordinal_union_implicit Field_ordinal_union_explicit 
        function Field_ordinal_which(ptr::Capnp.StructPointer)
            Field_ordinal_union(Capnp.read_bits(ptr, 10, UInt16))
        end
        function root_Field_ordinal(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Field_ordinal_data_word_count) && p.pointer_count == Field_ordinal_pointer_count
            p
        end
        function initRoot_Field_ordinal(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*7)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Field_ordinal_setImplicit(ptr)
            Capnp.write_bits(ptr, 10, UInt16, 0) # union discriminant
        end
        function Field_ordinal_getExplicit(ptr)
            value = Capnp.read_bits(ptr, 12, UInt16)
            value
        end
        function Field_ordinal_setExplicit(ptr, value)
            Capnp.write_bits(ptr, 12, UInt16, value)
            Capnp.write_bits(ptr, 10, UInt16, 1) # union discriminant
        end
        const Enumerant_data_word_count = 1
        const Enumerant_pointer_count = 2
        function root_Enumerant(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Enumerant_data_word_count) && p.pointer_count == Enumerant_pointer_count
            p
        end
        function initRoot_Enumerant(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Enumerant_getName(ptr)
            p = Capnp.read_list_pointer(ptr, 1, 0)
            Capnp.read_text(p)
        end
        function Enumerant_setName(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Enumerant_getCodeOrder(ptr)
            value = Capnp.read_bits(ptr, 0, UInt16)
            value
        end
        function Enumerant_setCodeOrder(ptr, value)
            Capnp.write_bits(ptr, 0, UInt16, value)
        end
        function Enumerant_getAnnotations(ptr::Nothing)
            []
        end
        function Enumerant_getAnnotations(ptr)
            p = Capnp.read_list_pointer(ptr, 1, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Annotation_data_word_count) && p.pointer_count == Annotation_pointer_count
            p
        end
        function Enumerant_initAnnotations(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        const Superclass_data_word_count = 1
        const Superclass_pointer_count = 1
        function root_Superclass(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Superclass_data_word_count) && p.pointer_count == Superclass_pointer_count
            p
        end
        function initRoot_Superclass(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*2)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Superclass_getId(ptr)
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Superclass_setId(ptr, value)
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Superclass_getBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 1, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Superclass_initBrand(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        const Method_data_word_count = 3
        const Method_pointer_count = 5
        function root_Method(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Method_data_word_count) && p.pointer_count == Method_pointer_count
            p
        end
        function initRoot_Method(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*8)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(5))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Method_getName(ptr)
            p = Capnp.read_list_pointer(ptr, 3, 0)
            Capnp.read_text(p)
        end
        function Method_setName(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Method_getCodeOrder(ptr)
            value = Capnp.read_bits(ptr, 0, UInt16)
            value
        end
        function Method_setCodeOrder(ptr, value)
            Capnp.write_bits(ptr, 0, UInt16, value)
        end
        function Method_getParamStructType(ptr)
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Method_setParamStructType(ptr, value)
            Capnp.write_bits(ptr, 8, UInt64, value)
        end
        function Method_getResultStructType(ptr)
            value = Capnp.read_bits(ptr, 16, UInt64)
            value
        end
        function Method_setResultStructType(ptr, value)
            Capnp.write_bits(ptr, 16, UInt64, value)
        end
        function Method_getAnnotations(ptr::Nothing)
            []
        end
        function Method_getAnnotations(ptr)
            p = Capnp.read_list_pointer(ptr, 3, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Annotation_data_word_count) && p.pointer_count == Annotation_pointer_count
            p
        end
        function Method_initAnnotations(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 4)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_getParamBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 3, 2)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Method_initParamBrand(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 5)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_getResultBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 3, 3)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Method_initResultBrand(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 6)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_getImplicitParameters(ptr::Nothing)
            []
        end
        function Method_getImplicitParameters(ptr)
            p = Capnp.read_list_pointer(ptr, 3, 4, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Node_Parameter_data_word_count) && p.pointer_count == Node_Parameter_pointer_count
            p
        end
        function Method_initImplicitParameters(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 7)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (0 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(0), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        const Type_data_word_count = 3
        const Type_pointer_count = 1
        @enum Type_union::UInt16 Type_union_void Type_union_bool Type_union_int8 Type_union_int16 Type_union_int32 Type_union_int64 Type_union_uint8 Type_union_uint16 Type_union_uint32 Type_union_uint64 Type_union_float32 Type_union_float64 Type_union_text Type_union_data Type_union_list Type_union_enum Type_union_struct Type_union_interface Type_union_anyPointer 
        function Type_which(ptr::Capnp.StructPointer)
            Type_union(Capnp.read_bits(ptr, 0, UInt16))
        end
        function root_Type(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function initRoot_Type(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Type_setVoid(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 0) # union discriminant
        end
        function Type_setBool(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 1) # union discriminant
        end
        function Type_setInt8(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 2) # union discriminant
        end
        function Type_setInt16(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 3) # union discriminant
        end
        function Type_setInt32(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 4) # union discriminant
        end
        function Type_setInt64(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 5) # union discriminant
        end
        function Type_setUint8(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 6) # union discriminant
        end
        function Type_setUint16(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 7) # union discriminant
        end
        function Type_setUint32(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 8) # union discriminant
        end
        function Type_setUint64(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 9) # union discriminant
        end
        function Type_setFloat32(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 10) # union discriminant
        end
        function Type_setFloat64(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 11) # union discriminant
        end
        function Type_setText(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 12) # union discriminant
        end
        function Type_setData(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 13) # union discriminant
        end
        function Type_getList(ptr::Capnp.StructPointer)
            ptr
        end
        function Type_initList(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 14) # union discriminant
            ptr
        end
        function root_Type_list(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_list_data_word_count) && p.pointer_count == Type_list_pointer_count
            p
        end
        function initRoot_Type_list(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Type_list_getElementType(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function Type_list_initElementType(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_getEnum(ptr::Capnp.StructPointer)
            ptr
        end
        function Type_initEnum(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 15) # union discriminant
            ptr
        end
        function root_Type_enum(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_enum_data_word_count) && p.pointer_count == Type_enum_pointer_count
            p
        end
        function initRoot_Type_enum(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Type_enum_getTypeId(ptr)
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Type_enum_setTypeId(ptr, value)
            Capnp.write_bits(ptr, 8, UInt64, value)
        end
        function Type_enum_getBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Type_enum_initBrand(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_getStruct(ptr::Capnp.StructPointer)
            ptr
        end
        function Type_initStruct(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 16) # union discriminant
            ptr
        end
        function root_Type_struct(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_struct_data_word_count) && p.pointer_count == Type_struct_pointer_count
            p
        end
        function initRoot_Type_struct(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Type_struct_getTypeId(ptr)
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Type_struct_setTypeId(ptr, value)
            Capnp.write_bits(ptr, 8, UInt64, value)
        end
        function Type_struct_getBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Type_struct_initBrand(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_getInterface(ptr::Capnp.StructPointer)
            ptr
        end
        function Type_initInterface(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 17) # union discriminant
            ptr
        end
        function root_Type_interface(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_interface_data_word_count) && p.pointer_count == Type_interface_pointer_count
            p
        end
        function initRoot_Type_interface(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Type_interface_getTypeId(ptr)
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Type_interface_setTypeId(ptr, value)
            Capnp.write_bits(ptr, 8, UInt64, value)
        end
        function Type_interface_getBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 3, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Type_interface_initBrand(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_getAnyPointer(ptr::Capnp.StructPointer)
            ptr
        end
        function Type_initAnyPointer(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 18) # union discriminant
            ptr
        end
        @enum Type_anyPointer_union::UInt16 Type_anyPointer_union_unconstrained Type_anyPointer_union_parameter Type_anyPointer_union_implicitMethodParameter 
        function Type_anyPointer_which(ptr::Capnp.StructPointer)
            Type_anyPointer_union(Capnp.read_bits(ptr, 8, UInt16))
        end
        function root_Type_anyPointer(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_anyPointer_data_word_count) && p.pointer_count == Type_anyPointer_pointer_count
            p
        end
        function initRoot_Type_anyPointer(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Type_anyPointer_getUnconstrained(ptr::Capnp.StructPointer)
            ptr
        end
        function Type_anyPointer_initUnconstrained(ptr)
            Capnp.write_bits(ptr, 8, UInt16, 0) # union discriminant
            ptr
        end
        @enum Type_anyPointer_unconstrained_union::UInt16 Type_anyPointer_unconstrained_union_anyKind Type_anyPointer_unconstrained_union_struct Type_anyPointer_unconstrained_union_list Type_anyPointer_unconstrained_union_capability 
        function Type_anyPointer_unconstrained_which(ptr::Capnp.StructPointer)
            Type_anyPointer_unconstrained_union(Capnp.read_bits(ptr, 10, UInt16))
        end
        function root_Type_anyPointer_unconstrained(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_anyPointer_unconstrained_data_word_count) && p.pointer_count == Type_anyPointer_unconstrained_pointer_count
            p
        end
        function initRoot_Type_anyPointer_unconstrained(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Type_anyPointer_unconstrained_setAnyKind(ptr)
            Capnp.write_bits(ptr, 10, UInt16, 0) # union discriminant
        end
        function Type_anyPointer_unconstrained_setStruct(ptr)
            Capnp.write_bits(ptr, 10, UInt16, 1) # union discriminant
        end
        function Type_anyPointer_unconstrained_setList(ptr)
            Capnp.write_bits(ptr, 10, UInt16, 2) # union discriminant
        end
        function Type_anyPointer_unconstrained_setCapability(ptr)
            Capnp.write_bits(ptr, 10, UInt16, 3) # union discriminant
        end
        function Type_anyPointer_getParameter(ptr::Capnp.StructPointer)
            ptr
        end
        function Type_anyPointer_initParameter(ptr)
            Capnp.write_bits(ptr, 8, UInt16, 1) # union discriminant
            ptr
        end
        function root_Type_anyPointer_parameter(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_anyPointer_parameter_data_word_count) && p.pointer_count == Type_anyPointer_parameter_pointer_count
            p
        end
        function initRoot_Type_anyPointer_parameter(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Type_anyPointer_parameter_getScopeId(ptr)
            value = Capnp.read_bits(ptr, 16, UInt64)
            value
        end
        function Type_anyPointer_parameter_setScopeId(ptr, value)
            Capnp.write_bits(ptr, 16, UInt64, value)
        end
        function Type_anyPointer_parameter_getParameterIndex(ptr)
            value = Capnp.read_bits(ptr, 10, UInt16)
            value
        end
        function Type_anyPointer_parameter_setParameterIndex(ptr, value)
            Capnp.write_bits(ptr, 10, UInt16, value)
        end
        function Type_anyPointer_getImplicitMethodParameter(ptr::Capnp.StructPointer)
            ptr
        end
        function Type_anyPointer_initImplicitMethodParameter(ptr)
            Capnp.write_bits(ptr, 8, UInt16, 2) # union discriminant
            ptr
        end
        function root_Type_anyPointer_implicitMethodParameter(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Type_anyPointer_implicitMethodParameter_data_word_count) && p.pointer_count == Type_anyPointer_implicitMethodParameter_pointer_count
            p
        end
        function initRoot_Type_anyPointer_implicitMethodParameter(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Type_anyPointer_implicitMethodParameter_getParameterIndex(ptr)
            value = Capnp.read_bits(ptr, 10, UInt16)
            value
        end
        function Type_anyPointer_implicitMethodParameter_setParameterIndex(ptr, value)
            Capnp.write_bits(ptr, 10, UInt16, value)
        end
        const Brand_Scope_data_word_count = 2
        const Brand_Scope_pointer_count = 1
        @enum Brand_Scope_union::UInt16 Brand_Scope_union_bind Brand_Scope_union_inherit 
        function Brand_Scope_which(ptr::Capnp.StructPointer)
            Brand_Scope_union(Capnp.read_bits(ptr, 8, UInt16))
        end
        function root_Brand_Scope(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_Scope_data_word_count) && p.pointer_count == Brand_Scope_pointer_count
            p
        end
        function initRoot_Brand_Scope(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(2), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Brand_Scope_getScopeId(ptr)
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Brand_Scope_setScopeId(ptr, value)
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Brand_Scope_getBind(ptr::Nothing)
            []
        end
        function Brand_Scope_getBind(ptr)
            p = Capnp.read_list_pointer(ptr, 2, 0, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Brand_Binding_data_word_count) && p.pointer_count == Brand_Binding_pointer_count
            p
        end
        function Brand_Scope_initBind(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_bits(ptr, 8, UInt16, 0) # union discriminant
            child_ptr
        end
        function Brand_Scope_setInherit(ptr)
            Capnp.write_bits(ptr, 8, UInt16, 1) # union discriminant
        end
        const Brand_Binding_data_word_count = 1
        const Brand_Binding_pointer_count = 1
        @enum Brand_Binding_union::UInt16 Brand_Binding_union_unbound Brand_Binding_union_type 
        function Brand_Binding_which(ptr::Capnp.StructPointer)
            Brand_Binding_union(Capnp.read_bits(ptr, 0, UInt16))
        end
        function root_Brand_Binding(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_Binding_data_word_count) && p.pointer_count == Brand_Binding_pointer_count
            p
        end
        function initRoot_Brand_Binding(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*2)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Brand_Binding_setUnbound(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 0) # union discriminant
        end
        function Brand_Binding_getType(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 1, 0)
            @assert isnothing(p) || (p.data_word_count == Type_data_word_count) && p.pointer_count == Type_pointer_count
            p
        end
        function Brand_Binding_initType(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            Capnp.write_bits(ptr, 0, UInt16, 1) # union discriminant
            child_ptr
        end
        const Brand_data_word_count = 0
        const Brand_pointer_count = 1
        function root_Brand(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function initRoot_Brand(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*1)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Brand_getScopes(ptr::Nothing)
            []
        end
        function Brand_getScopes(ptr)
            p = Capnp.read_list_pointer(ptr, 0, 0, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Brand_Scope_data_word_count) && p.pointer_count == Brand_Scope_pointer_count
            p
        end
        function Brand_initScopes(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (2 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(2), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        const Value_data_word_count = 2
        const Value_pointer_count = 1
        @enum Value_union::UInt16 Value_union_void Value_union_bool Value_union_int8 Value_union_int16 Value_union_int32 Value_union_int64 Value_union_uint8 Value_union_uint16 Value_union_uint32 Value_union_uint64 Value_union_float32 Value_union_float64 Value_union_text Value_union_data Value_union_list Value_union_enum Value_union_struct Value_union_interface Value_union_anyPointer 
        function Value_which(ptr::Capnp.StructPointer)
            Value_union(Capnp.read_bits(ptr, 0, UInt16))
        end
        function root_Value(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Value_data_word_count) && p.pointer_count == Value_pointer_count
            p
        end
        function initRoot_Value(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(2), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Value_setVoid(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 0) # union discriminant
        end
        function Value_getBool(ptr)
            value = Capnp.read_bool(ptr, 16)
            value
        end
        function Value_setBool(ptr, value)
            Capnp.write_bool(ptr, 16, value)
            Capnp.write_bits(ptr, 0, UInt16, 1) # union discriminant
        end
        function Value_getInt8(ptr)
            value = Capnp.read_bits(ptr, 2, UInt8)
            value
        end
        function Value_setInt8(ptr, value)
            Capnp.write_bits(ptr, 2, UInt8, value)
            Capnp.write_bits(ptr, 0, UInt16, 2) # union discriminant
        end
        function Value_getInt16(ptr)
            value = Capnp.read_bits(ptr, 2, UInt16)
            value
        end
        function Value_setInt16(ptr, value)
            Capnp.write_bits(ptr, 2, UInt16, value)
            Capnp.write_bits(ptr, 0, UInt16, 3) # union discriminant
        end
        function Value_getInt32(ptr)
            value = Capnp.read_bits(ptr, 4, UInt32)
            value
        end
        function Value_setInt32(ptr, value)
            Capnp.write_bits(ptr, 4, UInt32, value)
            Capnp.write_bits(ptr, 0, UInt16, 4) # union discriminant
        end
        function Value_getInt64(ptr)
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Value_setInt64(ptr, value)
            Capnp.write_bits(ptr, 8, UInt64, value)
            Capnp.write_bits(ptr, 0, UInt16, 5) # union discriminant
        end
        function Value_getUint8(ptr)
            value = Capnp.read_bits(ptr, 2, UInt8)
            value
        end
        function Value_setUint8(ptr, value)
            Capnp.write_bits(ptr, 2, UInt8, value)
            Capnp.write_bits(ptr, 0, UInt16, 6) # union discriminant
        end
        function Value_getUint16(ptr)
            value = Capnp.read_bits(ptr, 2, UInt16)
            value
        end
        function Value_setUint16(ptr, value)
            Capnp.write_bits(ptr, 2, UInt16, value)
            Capnp.write_bits(ptr, 0, UInt16, 7) # union discriminant
        end
        function Value_getUint32(ptr)
            value = Capnp.read_bits(ptr, 4, UInt32)
            value
        end
        function Value_setUint32(ptr, value)
            Capnp.write_bits(ptr, 4, UInt32, value)
            Capnp.write_bits(ptr, 0, UInt16, 8) # union discriminant
        end
        function Value_getUint64(ptr)
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Value_setUint64(ptr, value)
            Capnp.write_bits(ptr, 8, UInt64, value)
            Capnp.write_bits(ptr, 0, UInt16, 9) # union discriminant
        end
        function Value_getFloat32(ptr)
            value = Capnp.read_bits(ptr, 4, Float32)
            value
        end
        function Value_setFloat32(ptr, value)
            Capnp.write_bits(ptr, 4, Float32, value)
            Capnp.write_bits(ptr, 0, UInt16, 10) # union discriminant
        end
        function Value_getFloat64(ptr)
            value = Capnp.read_bits(ptr, 8, Float64)
            value
        end
        function Value_setFloat64(ptr, value)
            Capnp.write_bits(ptr, 8, Float64, value)
            Capnp.write_bits(ptr, 0, UInt16, 11) # union discriminant
        end
        function Value_getText(ptr)
            p = Capnp.read_list_pointer(ptr, 2, 0)
            Capnp.read_text(p)
        end
        function Value_setText(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_bits(ptr, 0, UInt16, 12) # union discriminant
            Capnp.write_text(child_ptr, txt)
        end
        # Value's data has type Capnp.Generator.SchemaData() which is not supported by Capnp.jl yet
        function Value_getList(ptr)
            value = Capnp.read_bits(ptr, 2, Int64)
            if value == 0
                Nothing
            else
                throw("TODO")
            end
        end
        function Value_getEnum(ptr)
            value = Capnp.read_bits(ptr, 2, UInt16)
            value
        end
        function Value_setEnum(ptr, value)
            Capnp.write_bits(ptr, 2, UInt16, value)
            Capnp.write_bits(ptr, 0, UInt16, 15) # union discriminant
        end
        function Value_getStruct(ptr)
            value = Capnp.read_bits(ptr, 2, Int64)
            if value == 0
                Nothing
            else
                throw("TODO")
            end
        end
        function Value_setInterface(ptr)
            Capnp.write_bits(ptr, 0, UInt16, 17) # union discriminant
        end
        function Value_getAnyPointer(ptr)
            value = Capnp.read_bits(ptr, 2, Int64)
            if value == 0
                Nothing
            else
                throw("TODO")
            end
        end
        const Annotation_data_word_count = 1
        const Annotation_pointer_count = 2
        function root_Annotation(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == Annotation_data_word_count) && p.pointer_count == Annotation_pointer_count
            p
        end
        function initRoot_Annotation(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function Annotation_getId(ptr)
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Annotation_setId(ptr, value)
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Annotation_getValue(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 1, 0)
            @assert isnothing(p) || (p.data_word_count == Value_data_word_count) && p.pointer_count == Value_pointer_count
            p
        end
        function Annotation_initValue(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*3)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(2), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Annotation_getBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 1, 1)
            @assert isnothing(p) || (p.data_word_count == Brand_data_word_count) && p.pointer_count == Brand_pointer_count
            p
        end
        function Annotation_initBrand(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        @enum ElementSize::UInt16 ElementSize_empty ElementSize_bit ElementSize_byte ElementSize_twoBytes ElementSize_fourBytes ElementSize_eightBytes ElementSize_pointer ElementSize_inlineComposite 
        const CapnpVersion_data_word_count = 1
        const CapnpVersion_pointer_count = 0
        function root_CapnpVersion(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == CapnpVersion_data_word_count) && p.pointer_count == CapnpVersion_pointer_count
            p
        end
        function initRoot_CapnpVersion(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*1)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(0))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function CapnpVersion_getMajor(ptr)
            value = Capnp.read_bits(ptr, 0, UInt16)
            value
        end
        function CapnpVersion_setMajor(ptr, value)
            Capnp.write_bits(ptr, 0, UInt16, value)
        end
        function CapnpVersion_getMinor(ptr)
            value = Capnp.read_bits(ptr, 2, UInt8)
            value
        end
        function CapnpVersion_setMinor(ptr, value)
            Capnp.write_bits(ptr, 2, UInt8, value)
        end
        function CapnpVersion_getMicro(ptr)
            value = Capnp.read_bits(ptr, 3, UInt8)
            value
        end
        function CapnpVersion_setMicro(ptr, value)
            Capnp.write_bits(ptr, 3, UInt8, value)
        end
        const CodeGeneratorRequest_RequestedFile_Import_data_word_count = 1
        const CodeGeneratorRequest_RequestedFile_Import_pointer_count = 1
        function root_CodeGeneratorRequest_RequestedFile_Import(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == CodeGeneratorRequest_RequestedFile_Import_data_word_count) && p.pointer_count == CodeGeneratorRequest_RequestedFile_Import_pointer_count
            p
        end
        function initRoot_CodeGeneratorRequest_RequestedFile_Import(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*2)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function CodeGeneratorRequest_RequestedFile_Import_getId(ptr)
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function CodeGeneratorRequest_RequestedFile_Import_setId(ptr, value)
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function CodeGeneratorRequest_RequestedFile_Import_getName(ptr)
            p = Capnp.read_list_pointer(ptr, 1, 0)
            Capnp.read_text(p)
        end
        function CodeGeneratorRequest_RequestedFile_Import_setName(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        const CodeGeneratorRequest_RequestedFile_data_word_count = 1
        const CodeGeneratorRequest_RequestedFile_pointer_count = 2
        function root_CodeGeneratorRequest_RequestedFile(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == CodeGeneratorRequest_RequestedFile_data_word_count) && p.pointer_count == CodeGeneratorRequest_RequestedFile_pointer_count
            p
        end
        function initRoot_CodeGeneratorRequest_RequestedFile(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function CodeGeneratorRequest_RequestedFile_getId(ptr)
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function CodeGeneratorRequest_RequestedFile_setId(ptr, value)
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function CodeGeneratorRequest_RequestedFile_getFilename(ptr)
            p = Capnp.read_list_pointer(ptr, 1, 0)
            Capnp.read_text(p)
        end
        function CodeGeneratorRequest_RequestedFile_setFilename(ptr, txt)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function CodeGeneratorRequest_RequestedFile_getImports(ptr::Nothing)
            []
        end
        function CodeGeneratorRequest_RequestedFile_getImports(ptr)
            p = Capnp.read_list_pointer(ptr, 1, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == CodeGeneratorRequest_RequestedFile_Import_data_word_count) && p.pointer_count == CodeGeneratorRequest_RequestedFile_Import_pointer_count
            p
        end
        function CodeGeneratorRequest_RequestedFile_initImports(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        const CodeGeneratorRequest_data_word_count = 0
        const CodeGeneratorRequest_pointer_count = 4
        function root_CodeGeneratorRequest(message)
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            @assert isnothing(p) || (p.data_word_count == CodeGeneratorRequest_data_word_count) && p.pointer_count == CodeGeneratorRequest_pointer_count
            p
        end
        function initRoot_CodeGeneratorRequest(builder)
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(0), UInt16(4))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function CodeGeneratorRequest_getNodes(ptr::Nothing)
            []
        end
        function CodeGeneratorRequest_getNodes(ptr)
            p = Capnp.read_list_pointer(ptr, 0, 0, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Node_data_word_count) && p.pointer_count == Node_pointer_count
            p
        end
        function CodeGeneratorRequest_initNodes(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (5 + 6)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(5), UInt16(6))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_getRequestedFiles(ptr::Nothing)
            []
        end
        function CodeGeneratorRequest_getRequestedFiles(ptr)
            p = Capnp.read_list_pointer(ptr, 0, 1, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == CodeGeneratorRequest_RequestedFile_data_word_count) && p.pointer_count == CodeGeneratorRequest_RequestedFile_pointer_count
            p
        end
        function CodeGeneratorRequest_initRequestedFiles(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_getCapnpVersion(ptr::Capnp.StructPointer{T}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, 0, 2)
            @assert isnothing(p) || (p.data_word_count == CapnpVersion_data_word_count) && p.pointer_count == CapnpVersion_pointer_count
            p
        end
        function CodeGeneratorRequest_initCapnpVersion(ptr)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(1), UInt16(0))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_getSourceInfo(ptr::Nothing)
            []
        end
        function CodeGeneratorRequest_getSourceInfo(ptr)
            p = Capnp.read_list_pointer(ptr, 0, 3, Capnp.CapnpStruct)
            @assert isempty(p) || p isa Capnp.SimpleListPointer ||
               (p isa Capnp.CompositeListPointer && p.data_word_count == Node_SourceInfo_data_word_count) && p.pointer_count == Node_SourceInfo_pointer_count
            p
        end
        function CodeGeneratorRequest_initSourceInfo(ptr, size)
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
    end
end
end

