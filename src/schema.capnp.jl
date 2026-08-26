module capnp
    module schema
        # Generated from src/schema.capnp
        using Capnp
        const Node_Parameter_data_word_count = 0
        const Node_Parameter_pointer_count = 1
        function root(message, ::Type{Val{:Node_Parameter}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Node_Parameter_data_word_count, Node_Parameter_pointer_count, "Node_Parameter")
            p
        end
        function root_Node_Parameter(message)
            Base.depwarn("root_Node_Parameter is deprecated, use root(message, Val{:Node_Parameter}) instead", :root_Node_Parameter)
            root(message, Val{:Node_Parameter})
        end
        function init_root!(builder, ::Type{Val{:Node_Parameter}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*1)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Node_Parameter(builder)
            Base.depwarn("initRoot_Node_Parameter is deprecated, use init_root!(builder, Val{:Node_Parameter}) instead", :initRoot_Node_Parameter)
            init_root!(builder, Val{:Node_Parameter})
        end
        function get_name(ptr, ::Type{Val{:Node_Parameter}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function Node_Parameter_getName(ptr)
            Base.depwarn("Node_Parameter_getName is deprecated, use get_name(ptr, Val{:Node_Parameter}) instead", :Node_Parameter_getName)
            get_name(ptr, Val{:Node_Parameter})
        end
        function set_name!(ptr, txt, ::Type{Val{:Node_Parameter}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Node_Parameter_setName(ptr, txt)
            Base.depwarn("Node_Parameter_setName is deprecated, use set_name!(ptr, txt, Val{:Node_Parameter}) instead", :Node_Parameter_setName)
            set_name!(ptr, txt, Val{:Node_Parameter})
        end
        const Node_NestedNode_data_word_count = 1
        const Node_NestedNode_pointer_count = 1
        function root(message, ::Type{Val{:Node_NestedNode}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Node_NestedNode_data_word_count, Node_NestedNode_pointer_count, "Node_NestedNode")
            p
        end
        function root_Node_NestedNode(message)
            Base.depwarn("root_Node_NestedNode is deprecated, use root(message, Val{:Node_NestedNode}) instead", :root_Node_NestedNode)
            root(message, Val{:Node_NestedNode})
        end
        function init_root!(builder, ::Type{Val{:Node_NestedNode}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*2)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Node_NestedNode(builder)
            Base.depwarn("initRoot_Node_NestedNode is deprecated, use init_root!(builder, Val{:Node_NestedNode}) instead", :initRoot_Node_NestedNode)
            init_root!(builder, Val{:Node_NestedNode})
        end
        function get_name(ptr, ::Type{Val{:Node_NestedNode}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function Node_NestedNode_getName(ptr)
            Base.depwarn("Node_NestedNode_getName is deprecated, use get_name(ptr, Val{:Node_NestedNode}) instead", :Node_NestedNode_getName)
            get_name(ptr, Val{:Node_NestedNode})
        end
        function set_name!(ptr, txt, ::Type{Val{:Node_NestedNode}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Node_NestedNode_setName(ptr, txt)
            Base.depwarn("Node_NestedNode_setName is deprecated, use set_name!(ptr, txt, Val{:Node_NestedNode}) instead", :Node_NestedNode_setName)
            set_name!(ptr, txt, Val{:Node_NestedNode})
        end
        function get_id(ptr, ::Type{Val{:Node_NestedNode}})
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Node_NestedNode_getId(ptr)
            Base.depwarn("Node_NestedNode_getId is deprecated, use get_id(ptr, Val{:Node_NestedNode}) instead", :Node_NestedNode_getId)
            get_id(ptr, Val{:Node_NestedNode})
        end
        function set_id!(ptr, value, ::Type{Val{:Node_NestedNode}})
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Node_NestedNode_setId(ptr, value)
            Base.depwarn("Node_NestedNode_setId is deprecated, use set_id!(ptr, value, Val{:Node_NestedNode}) instead", :Node_NestedNode_setId)
            set_id!(ptr, value, Val{:Node_NestedNode})
        end
        const Node_SourceInfo_Member_data_word_count = 0
        const Node_SourceInfo_Member_pointer_count = 1
        function root(message, ::Type{Val{:Node_SourceInfo_Member}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Node_SourceInfo_Member_data_word_count, Node_SourceInfo_Member_pointer_count, "Node_SourceInfo_Member")
            p
        end
        function root_Node_SourceInfo_Member(message)
            Base.depwarn("root_Node_SourceInfo_Member is deprecated, use root(message, Val{:Node_SourceInfo_Member}) instead", :root_Node_SourceInfo_Member)
            root(message, Val{:Node_SourceInfo_Member})
        end
        function init_root!(builder, ::Type{Val{:Node_SourceInfo_Member}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*1)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Node_SourceInfo_Member(builder)
            Base.depwarn("initRoot_Node_SourceInfo_Member is deprecated, use init_root!(builder, Val{:Node_SourceInfo_Member}) instead", :initRoot_Node_SourceInfo_Member)
            init_root!(builder, Val{:Node_SourceInfo_Member})
        end
        function get_doc_comment(ptr, ::Type{Val{:Node_SourceInfo_Member}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function Node_SourceInfo_Member_getDocComment(ptr)
            Base.depwarn("Node_SourceInfo_Member_getDocComment is deprecated, use get_doc_comment(ptr, Val{:Node_SourceInfo_Member}) instead", :Node_SourceInfo_Member_getDocComment)
            get_doc_comment(ptr, Val{:Node_SourceInfo_Member})
        end
        function set_doc_comment!(ptr, txt, ::Type{Val{:Node_SourceInfo_Member}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Node_SourceInfo_Member_setDocComment(ptr, txt)
            Base.depwarn("Node_SourceInfo_Member_setDocComment is deprecated, use set_doc_comment!(ptr, txt, Val{:Node_SourceInfo_Member}) instead", :Node_SourceInfo_Member_setDocComment)
            set_doc_comment!(ptr, txt, Val{:Node_SourceInfo_Member})
        end
        const Node_SourceInfo_data_word_count = 1
        const Node_SourceInfo_pointer_count = 2
        function root(message, ::Type{Val{:Node_SourceInfo}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Node_SourceInfo_data_word_count, Node_SourceInfo_pointer_count, "Node_SourceInfo")
            p
        end
        function root_Node_SourceInfo(message)
            Base.depwarn("root_Node_SourceInfo is deprecated, use root(message, Val{:Node_SourceInfo}) instead", :root_Node_SourceInfo)
            root(message, Val{:Node_SourceInfo})
        end
        function init_root!(builder, ::Type{Val{:Node_SourceInfo}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Node_SourceInfo(builder)
            Base.depwarn("initRoot_Node_SourceInfo is deprecated, use init_root!(builder, Val{:Node_SourceInfo}) instead", :initRoot_Node_SourceInfo)
            init_root!(builder, Val{:Node_SourceInfo})
        end
        function get_id(ptr, ::Type{Val{:Node_SourceInfo}})
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Node_SourceInfo_getId(ptr)
            Base.depwarn("Node_SourceInfo_getId is deprecated, use get_id(ptr, Val{:Node_SourceInfo}) instead", :Node_SourceInfo_getId)
            get_id(ptr, Val{:Node_SourceInfo})
        end
        function set_id!(ptr, value, ::Type{Val{:Node_SourceInfo}})
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Node_SourceInfo_setId(ptr, value)
            Base.depwarn("Node_SourceInfo_setId is deprecated, use set_id!(ptr, value, Val{:Node_SourceInfo}) instead", :Node_SourceInfo_setId)
            set_id!(ptr, value, Val{:Node_SourceInfo})
        end
        function get_doc_comment(ptr, ::Type{Val{:Node_SourceInfo}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function Node_SourceInfo_getDocComment(ptr)
            Base.depwarn("Node_SourceInfo_getDocComment is deprecated, use get_doc_comment(ptr, Val{:Node_SourceInfo}) instead", :Node_SourceInfo_getDocComment)
            get_doc_comment(ptr, Val{:Node_SourceInfo})
        end
        function set_doc_comment!(ptr, txt, ::Type{Val{:Node_SourceInfo}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Node_SourceInfo_setDocComment(ptr, txt)
            Base.depwarn("Node_SourceInfo_setDocComment is deprecated, use set_doc_comment!(ptr, txt, Val{:Node_SourceInfo}) instead", :Node_SourceInfo_setDocComment)
            set_doc_comment!(ptr, txt, Val{:Node_SourceInfo})
        end
        function get_members(ptr::Nothing, ::Type{Val{:Node_SourceInfo}})
            []
        end
        function Node_SourceInfo_getMembers(ptr::Nothing)
            Base.depwarn("Node_SourceInfo_getMembers is deprecated, use get_members(ptr, Val{:Node_SourceInfo}) instead", :Node_SourceInfo_getMembers)
            get_members(ptr, Val{:Node_SourceInfo})
        end
        function get_members(ptr, ::Type{Val{:Node_SourceInfo}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 1, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Node_SourceInfo_Member_data_word_count, Node_SourceInfo_Member_pointer_count, "Node_SourceInfo_Member")
            p
        end
        function Node_SourceInfo_getMembers(ptr)
            Base.depwarn("Node_SourceInfo_getMembers is deprecated, use get_members(ptr, Val{:Node_SourceInfo}) instead", :Node_SourceInfo_getMembers)
            get_members(ptr, Val{:Node_SourceInfo})
        end
        function init_members!(ptr, size, ::Type{Val{:Node_SourceInfo}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (0 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(0), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_SourceInfo_initMembers(ptr, size)
            Base.depwarn("Node_SourceInfo_initMembers is deprecated, use init_members!(ptr, size, Val{:Node_SourceInfo}) instead", :Node_SourceInfo_initMembers)
            init_members!(ptr, size, Val{:Node_SourceInfo})
        end
        const Node_data_word_count = 5
        const Node_pointer_count = 6
        @enum Node_union::UInt16 Node_union_file Node_union_struct Node_union_enum Node_union_interface Node_union_const Node_union_annotation 
        function which(ptr::Capnp.StructPointer, ::Type{Val{:Node}})
            Node_union(Capnp.read_bits(ptr, 12, UInt16))
        end
        function Node_which(ptr::Capnp.StructPointer)
            Base.depwarn("Node_which is deprecated, use which(ptr, Val{:Node}) instead", :Node_which)
            which(ptr, Val{:Node})
        end
        function root(message, ::Type{Val{:Node}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Node_data_word_count, Node_pointer_count, "Node")
            p
        end
        function root_Node(message)
            Base.depwarn("root_Node is deprecated, use root(message, Val{:Node}) instead", :root_Node)
            root(message, Val{:Node})
        end
        function init_root!(builder, ::Type{Val{:Node}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Node(builder)
            Base.depwarn("initRoot_Node is deprecated, use init_root!(builder, Val{:Node}) instead", :initRoot_Node)
            init_root!(builder, Val{:Node})
        end
        function get_id(ptr, ::Type{Val{:Node}})
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Node_getId(ptr)
            Base.depwarn("Node_getId is deprecated, use get_id(ptr, Val{:Node}) instead", :Node_getId)
            get_id(ptr, Val{:Node})
        end
        function set_id!(ptr, value, ::Type{Val{:Node}})
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Node_setId(ptr, value)
            Base.depwarn("Node_setId is deprecated, use set_id!(ptr, value, Val{:Node}) instead", :Node_setId)
            set_id!(ptr, value, Val{:Node})
        end
        function get_display_name(ptr, ::Type{Val{:Node}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function Node_getDisplayName(ptr)
            Base.depwarn("Node_getDisplayName is deprecated, use get_display_name(ptr, Val{:Node}) instead", :Node_getDisplayName)
            get_display_name(ptr, Val{:Node})
        end
        function set_display_name!(ptr, txt, ::Type{Val{:Node}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Node_setDisplayName(ptr, txt)
            Base.depwarn("Node_setDisplayName is deprecated, use set_display_name!(ptr, txt, Val{:Node}) instead", :Node_setDisplayName)
            set_display_name!(ptr, txt, Val{:Node})
        end
        function get_display_name_prefix_length(ptr, ::Type{Val{:Node}})
            value = Capnp.read_bits(ptr, 8, UInt32)
            value
        end
        function Node_getDisplayNamePrefixLength(ptr)
            Base.depwarn("Node_getDisplayNamePrefixLength is deprecated, use get_display_name_prefix_length(ptr, Val{:Node}) instead", :Node_getDisplayNamePrefixLength)
            get_display_name_prefix_length(ptr, Val{:Node})
        end
        function set_display_name_prefix_length!(ptr, value, ::Type{Val{:Node}})
            Capnp.write_bits(ptr, 8, UInt32, value)
        end
        function Node_setDisplayNamePrefixLength(ptr, value)
            Base.depwarn("Node_setDisplayNamePrefixLength is deprecated, use set_display_name_prefix_length!(ptr, value, Val{:Node}) instead", :Node_setDisplayNamePrefixLength)
            set_display_name_prefix_length!(ptr, value, Val{:Node})
        end
        function get_scope_id(ptr, ::Type{Val{:Node}})
            value = Capnp.read_bits(ptr, 16, UInt64)
            value
        end
        function Node_getScopeId(ptr)
            Base.depwarn("Node_getScopeId is deprecated, use get_scope_id(ptr, Val{:Node}) instead", :Node_getScopeId)
            get_scope_id(ptr, Val{:Node})
        end
        function set_scope_id!(ptr, value, ::Type{Val{:Node}})
            Capnp.write_bits(ptr, 16, UInt64, value)
        end
        function Node_setScopeId(ptr, value)
            Base.depwarn("Node_setScopeId is deprecated, use set_scope_id!(ptr, value, Val{:Node}) instead", :Node_setScopeId)
            set_scope_id!(ptr, value, Val{:Node})
        end
        function get_nested_nodes(ptr::Nothing, ::Type{Val{:Node}})
            []
        end
        function Node_getNestedNodes(ptr::Nothing)
            Base.depwarn("Node_getNestedNodes is deprecated, use get_nested_nodes(ptr, Val{:Node}) instead", :Node_getNestedNodes)
            get_nested_nodes(ptr, Val{:Node})
        end
        function get_nested_nodes(ptr, ::Type{Val{:Node}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 1, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Node_NestedNode_data_word_count, Node_NestedNode_pointer_count, "Node_NestedNode")
            p
        end
        function Node_getNestedNodes(ptr)
            Base.depwarn("Node_getNestedNodes is deprecated, use get_nested_nodes(ptr, Val{:Node}) instead", :Node_getNestedNodes)
            get_nested_nodes(ptr, Val{:Node})
        end
        function init_nested_nodes!(ptr, size, ::Type{Val{:Node}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_initNestedNodes(ptr, size)
            Base.depwarn("Node_initNestedNodes is deprecated, use init_nested_nodes!(ptr, size, Val{:Node}) instead", :Node_initNestedNodes)
            init_nested_nodes!(ptr, size, Val{:Node})
        end
        function get_annotations(ptr::Nothing, ::Type{Val{:Node}})
            []
        end
        function Node_getAnnotations(ptr::Nothing)
            Base.depwarn("Node_getAnnotations is deprecated, use get_annotations(ptr, Val{:Node}) instead", :Node_getAnnotations)
            get_annotations(ptr, Val{:Node})
        end
        function get_annotations(ptr, ::Type{Val{:Node}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 2, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Annotation_data_word_count, Annotation_pointer_count, "Annotation")
            p
        end
        function Node_getAnnotations(ptr)
            Base.depwarn("Node_getAnnotations is deprecated, use get_annotations(ptr, Val{:Node}) instead", :Node_getAnnotations)
            get_annotations(ptr, Val{:Node})
        end
        function init_annotations!(ptr, size, ::Type{Val{:Node}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_initAnnotations(ptr, size)
            Base.depwarn("Node_initAnnotations is deprecated, use init_annotations!(ptr, size, Val{:Node}) instead", :Node_initAnnotations)
            init_annotations!(ptr, size, Val{:Node})
        end
        function set_file!(ptr, ::Type{Val{:Node}})
            Capnp.write_bits(ptr, 12, UInt16, 0) # union discriminant
        end
        function Node_setFile(ptr)
            Base.depwarn("Node_setFile is deprecated, use set_file!(ptr, Val{:Node}) instead", :Node_setFile)
            set_file!(ptr, Val{:Node})
        end
        function get_struct(ptr::Capnp.StructPointer, ::Type{Val{:Node}})
            ptr
        end
        function Node_getStruct(ptr::Capnp.StructPointer)
            Base.depwarn("Node_getStruct is deprecated, use get_struct(ptr, Val{:Node}) instead", :Node_getStruct)
            get_struct(ptr, Val{:Node})
        end
        function init_struct!(ptr, ::Type{Val{:Node}})
            Capnp.write_bits(ptr, 12, UInt16, 1) # union discriminant
            ptr
        end
        function Node_initStruct(ptr)
            Base.depwarn("Node_initStruct is deprecated, use init_struct!(ptr, Val{:Node}) instead", :Node_initStruct)
            init_struct!(ptr, Val{:Node})
        end
        function root(message, ::Type{Val{:Node_struct}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Node_struct_data_word_count, Node_struct_pointer_count, "Node_struct")
            p
        end
        function root_Node_struct(message)
            Base.depwarn("root_Node_struct is deprecated, use root(message, Val{:Node_struct}) instead", :root_Node_struct)
            root(message, Val{:Node_struct})
        end
        function init_root!(builder, ::Type{Val{:Node_struct}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Node_struct(builder)
            Base.depwarn("initRoot_Node_struct is deprecated, use init_root!(builder, Val{:Node_struct}) instead", :initRoot_Node_struct)
            init_root!(builder, Val{:Node_struct})
        end
        function get_data_word_count(ptr, ::Type{Val{:Node_struct}})
            value = Capnp.read_bits(ptr, 14, UInt16)
            value
        end
        function Node_struct_getDataWordCount(ptr)
            Base.depwarn("Node_struct_getDataWordCount is deprecated, use get_data_word_count(ptr, Val{:Node_struct}) instead", :Node_struct_getDataWordCount)
            get_data_word_count(ptr, Val{:Node_struct})
        end
        function set_data_word_count!(ptr, value, ::Type{Val{:Node_struct}})
            Capnp.write_bits(ptr, 14, UInt16, value)
        end
        function Node_struct_setDataWordCount(ptr, value)
            Base.depwarn("Node_struct_setDataWordCount is deprecated, use set_data_word_count!(ptr, value, Val{:Node_struct}) instead", :Node_struct_setDataWordCount)
            set_data_word_count!(ptr, value, Val{:Node_struct})
        end
        function get_pointer_count(ptr, ::Type{Val{:Node_struct}})
            value = Capnp.read_bits(ptr, 24, UInt16)
            value
        end
        function Node_struct_getPointerCount(ptr)
            Base.depwarn("Node_struct_getPointerCount is deprecated, use get_pointer_count(ptr, Val{:Node_struct}) instead", :Node_struct_getPointerCount)
            get_pointer_count(ptr, Val{:Node_struct})
        end
        function set_pointer_count!(ptr, value, ::Type{Val{:Node_struct}})
            Capnp.write_bits(ptr, 24, UInt16, value)
        end
        function Node_struct_setPointerCount(ptr, value)
            Base.depwarn("Node_struct_setPointerCount is deprecated, use set_pointer_count!(ptr, value, Val{:Node_struct}) instead", :Node_struct_setPointerCount)
            set_pointer_count!(ptr, value, Val{:Node_struct})
        end
        function get_preferred_list_encoding(ptr, ::Type{Val{:Node_struct}})
            value = Capnp.read_bits(ptr, 26, ElementSize)
            value
        end
        function Node_struct_getPreferredListEncoding(ptr)
            Base.depwarn("Node_struct_getPreferredListEncoding is deprecated, use get_preferred_list_encoding(ptr, Val{:Node_struct}) instead", :Node_struct_getPreferredListEncoding)
            get_preferred_list_encoding(ptr, Val{:Node_struct})
        end
        function set_preferred_list_encoding!(ptr, value, ::Type{Val{:Node_struct}})
            Capnp.write_bits(ptr, 26, ElementSize, value)
        end
        function Node_struct_setPreferredListEncoding(ptr, value)
            Base.depwarn("Node_struct_setPreferredListEncoding is deprecated, use set_preferred_list_encoding!(ptr, value, Val{:Node_struct}) instead", :Node_struct_setPreferredListEncoding)
            set_preferred_list_encoding!(ptr, value, Val{:Node_struct})
        end
        function get_is_group(ptr, ::Type{Val{:Node_struct}})
            value = Capnp.read_bool(ptr, 224)
            value
        end
        function Node_struct_getIsGroup(ptr)
            Base.depwarn("Node_struct_getIsGroup is deprecated, use get_is_group(ptr, Val{:Node_struct}) instead", :Node_struct_getIsGroup)
            get_is_group(ptr, Val{:Node_struct})
        end
        function set_is_group!(ptr, value, ::Type{Val{:Node_struct}})
            Capnp.write_bool(ptr, 224, value)
        end
        function Node_struct_setIsGroup(ptr, value)
            Base.depwarn("Node_struct_setIsGroup is deprecated, use set_is_group!(ptr, value, Val{:Node_struct}) instead", :Node_struct_setIsGroup)
            set_is_group!(ptr, value, Val{:Node_struct})
        end
        function get_discriminant_count(ptr, ::Type{Val{:Node_struct}})
            value = Capnp.read_bits(ptr, 30, UInt16)
            value
        end
        function Node_struct_getDiscriminantCount(ptr)
            Base.depwarn("Node_struct_getDiscriminantCount is deprecated, use get_discriminant_count(ptr, Val{:Node_struct}) instead", :Node_struct_getDiscriminantCount)
            get_discriminant_count(ptr, Val{:Node_struct})
        end
        function set_discriminant_count!(ptr, value, ::Type{Val{:Node_struct}})
            Capnp.write_bits(ptr, 30, UInt16, value)
        end
        function Node_struct_setDiscriminantCount(ptr, value)
            Base.depwarn("Node_struct_setDiscriminantCount is deprecated, use set_discriminant_count!(ptr, value, Val{:Node_struct}) instead", :Node_struct_setDiscriminantCount)
            set_discriminant_count!(ptr, value, Val{:Node_struct})
        end
        function get_discriminant_offset(ptr, ::Type{Val{:Node_struct}})
            value = Capnp.read_bits(ptr, 32, UInt32)
            value
        end
        function Node_struct_getDiscriminantOffset(ptr)
            Base.depwarn("Node_struct_getDiscriminantOffset is deprecated, use get_discriminant_offset(ptr, Val{:Node_struct}) instead", :Node_struct_getDiscriminantOffset)
            get_discriminant_offset(ptr, Val{:Node_struct})
        end
        function set_discriminant_offset!(ptr, value, ::Type{Val{:Node_struct}})
            Capnp.write_bits(ptr, 32, UInt32, value)
        end
        function Node_struct_setDiscriminantOffset(ptr, value)
            Base.depwarn("Node_struct_setDiscriminantOffset is deprecated, use set_discriminant_offset!(ptr, value, Val{:Node_struct}) instead", :Node_struct_setDiscriminantOffset)
            set_discriminant_offset!(ptr, value, Val{:Node_struct})
        end
        function get_fields(ptr::Nothing, ::Type{Val{:Node_struct}})
            []
        end
        function Node_struct_getFields(ptr::Nothing)
            Base.depwarn("Node_struct_getFields is deprecated, use get_fields(ptr, Val{:Node_struct}) instead", :Node_struct_getFields)
            get_fields(ptr, Val{:Node_struct})
        end
        function get_fields(ptr, ::Type{Val{:Node_struct}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 3, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Field_data_word_count, Field_pointer_count, "Field")
            p
        end
        function Node_struct_getFields(ptr)
            Base.depwarn("Node_struct_getFields is deprecated, use get_fields(ptr, Val{:Node_struct}) instead", :Node_struct_getFields)
            get_fields(ptr, Val{:Node_struct})
        end
        function init_fields!(ptr, size, ::Type{Val{:Node_struct}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (3 + 4)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(3), UInt16(4))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_struct_initFields(ptr, size)
            Base.depwarn("Node_struct_initFields is deprecated, use init_fields!(ptr, size, Val{:Node_struct}) instead", :Node_struct_initFields)
            init_fields!(ptr, size, Val{:Node_struct})
        end
        function get_enum(ptr::Capnp.StructPointer, ::Type{Val{:Node}})
            ptr
        end
        function Node_getEnum(ptr::Capnp.StructPointer)
            Base.depwarn("Node_getEnum is deprecated, use get_enum(ptr, Val{:Node}) instead", :Node_getEnum)
            get_enum(ptr, Val{:Node})
        end
        function init_enum!(ptr, ::Type{Val{:Node}})
            Capnp.write_bits(ptr, 12, UInt16, 2) # union discriminant
            ptr
        end
        function Node_initEnum(ptr)
            Base.depwarn("Node_initEnum is deprecated, use init_enum!(ptr, Val{:Node}) instead", :Node_initEnum)
            init_enum!(ptr, Val{:Node})
        end
        function root(message, ::Type{Val{:Node_enum}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Node_enum_data_word_count, Node_enum_pointer_count, "Node_enum")
            p
        end
        function root_Node_enum(message)
            Base.depwarn("root_Node_enum is deprecated, use root(message, Val{:Node_enum}) instead", :root_Node_enum)
            root(message, Val{:Node_enum})
        end
        function init_root!(builder, ::Type{Val{:Node_enum}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Node_enum(builder)
            Base.depwarn("initRoot_Node_enum is deprecated, use init_root!(builder, Val{:Node_enum}) instead", :initRoot_Node_enum)
            init_root!(builder, Val{:Node_enum})
        end
        function get_enumerants(ptr::Nothing, ::Type{Val{:Node_enum}})
            []
        end
        function Node_enum_getEnumerants(ptr::Nothing)
            Base.depwarn("Node_enum_getEnumerants is deprecated, use get_enumerants(ptr, Val{:Node_enum}) instead", :Node_enum_getEnumerants)
            get_enumerants(ptr, Val{:Node_enum})
        end
        function get_enumerants(ptr, ::Type{Val{:Node_enum}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 3, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Enumerant_data_word_count, Enumerant_pointer_count, "Enumerant")
            p
        end
        function Node_enum_getEnumerants(ptr)
            Base.depwarn("Node_enum_getEnumerants is deprecated, use get_enumerants(ptr, Val{:Node_enum}) instead", :Node_enum_getEnumerants)
            get_enumerants(ptr, Val{:Node_enum})
        end
        function init_enumerants!(ptr, size, ::Type{Val{:Node_enum}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_enum_initEnumerants(ptr, size)
            Base.depwarn("Node_enum_initEnumerants is deprecated, use init_enumerants!(ptr, size, Val{:Node_enum}) instead", :Node_enum_initEnumerants)
            init_enumerants!(ptr, size, Val{:Node_enum})
        end
        function get_interface(ptr::Capnp.StructPointer, ::Type{Val{:Node}})
            ptr
        end
        function Node_getInterface(ptr::Capnp.StructPointer)
            Base.depwarn("Node_getInterface is deprecated, use get_interface(ptr, Val{:Node}) instead", :Node_getInterface)
            get_interface(ptr, Val{:Node})
        end
        function init_interface!(ptr, ::Type{Val{:Node}})
            Capnp.write_bits(ptr, 12, UInt16, 3) # union discriminant
            ptr
        end
        function Node_initInterface(ptr)
            Base.depwarn("Node_initInterface is deprecated, use init_interface!(ptr, Val{:Node}) instead", :Node_initInterface)
            init_interface!(ptr, Val{:Node})
        end
        function root(message, ::Type{Val{:Node_interface}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Node_interface_data_word_count, Node_interface_pointer_count, "Node_interface")
            p
        end
        function root_Node_interface(message)
            Base.depwarn("root_Node_interface is deprecated, use root(message, Val{:Node_interface}) instead", :root_Node_interface)
            root(message, Val{:Node_interface})
        end
        function init_root!(builder, ::Type{Val{:Node_interface}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Node_interface(builder)
            Base.depwarn("initRoot_Node_interface is deprecated, use init_root!(builder, Val{:Node_interface}) instead", :initRoot_Node_interface)
            init_root!(builder, Val{:Node_interface})
        end
        function get_methods(ptr::Nothing, ::Type{Val{:Node_interface}})
            []
        end
        function Node_interface_getMethods(ptr::Nothing)
            Base.depwarn("Node_interface_getMethods is deprecated, use get_methods(ptr, Val{:Node_interface}) instead", :Node_interface_getMethods)
            get_methods(ptr, Val{:Node_interface})
        end
        function get_methods(ptr, ::Type{Val{:Node_interface}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 3, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Method_data_word_count, Method_pointer_count, "Method")
            p
        end
        function Node_interface_getMethods(ptr)
            Base.depwarn("Node_interface_getMethods is deprecated, use get_methods(ptr, Val{:Node_interface}) instead", :Node_interface_getMethods)
            get_methods(ptr, Val{:Node_interface})
        end
        function init_methods!(ptr, size, ::Type{Val{:Node_interface}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (3 + 5)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(3), UInt16(5))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_interface_initMethods(ptr, size)
            Base.depwarn("Node_interface_initMethods is deprecated, use init_methods!(ptr, size, Val{:Node_interface}) instead", :Node_interface_initMethods)
            init_methods!(ptr, size, Val{:Node_interface})
        end
        function get_superclasses(ptr::Nothing, ::Type{Val{:Node_interface}})
            []
        end
        function Node_interface_getSuperclasses(ptr::Nothing)
            Base.depwarn("Node_interface_getSuperclasses is deprecated, use get_superclasses(ptr, Val{:Node_interface}) instead", :Node_interface_getSuperclasses)
            get_superclasses(ptr, Val{:Node_interface})
        end
        function get_superclasses(ptr, ::Type{Val{:Node_interface}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 4, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Superclass_data_word_count, Superclass_pointer_count, "Superclass")
            p
        end
        function Node_interface_getSuperclasses(ptr)
            Base.depwarn("Node_interface_getSuperclasses is deprecated, use get_superclasses(ptr, Val{:Node_interface}) instead", :Node_interface_getSuperclasses)
            get_superclasses(ptr, Val{:Node_interface})
        end
        function init_superclasses!(ptr, size, ::Type{Val{:Node_interface}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 4)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_interface_initSuperclasses(ptr, size)
            Base.depwarn("Node_interface_initSuperclasses is deprecated, use init_superclasses!(ptr, size, Val{:Node_interface}) instead", :Node_interface_initSuperclasses)
            init_superclasses!(ptr, size, Val{:Node_interface})
        end
        function get_const(ptr::Capnp.StructPointer, ::Type{Val{:Node}})
            ptr
        end
        function Node_getConst(ptr::Capnp.StructPointer)
            Base.depwarn("Node_getConst is deprecated, use get_const(ptr, Val{:Node}) instead", :Node_getConst)
            get_const(ptr, Val{:Node})
        end
        function init_const!(ptr, ::Type{Val{:Node}})
            Capnp.write_bits(ptr, 12, UInt16, 4) # union discriminant
            ptr
        end
        function Node_initConst(ptr)
            Base.depwarn("Node_initConst is deprecated, use init_const!(ptr, Val{:Node}) instead", :Node_initConst)
            init_const!(ptr, Val{:Node})
        end
        function root(message, ::Type{Val{:Node_const}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Node_const_data_word_count, Node_const_pointer_count, "Node_const")
            p
        end
        function root_Node_const(message)
            Base.depwarn("root_Node_const is deprecated, use root(message, Val{:Node_const}) instead", :root_Node_const)
            root(message, Val{:Node_const})
        end
        function init_root!(builder, ::Type{Val{:Node_const}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Node_const(builder)
            Base.depwarn("initRoot_Node_const is deprecated, use init_root!(builder, Val{:Node_const}) instead", :initRoot_Node_const)
            init_root!(builder, Val{:Node_const})
        end
        function get_type(ptr::Capnp.StructPointer{T}, ::Type{Val{:Node_const}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 3)
            Capnp.validate_struct_pointer(p, Type_data_word_count, Type_pointer_count, "Type")
            p
        end
        function Node_const_getType(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Node_const_getType is deprecated, use get_type(ptr, Val{:Node_const}) instead", :Node_const_getType)
            get_type(ptr, Val{:Node_const})
        end
        function get_type(promise::Capnp.RPC.Promise, ::Type{Val{:Node_const}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(3))])
        end
        function init_type!(ptr, ::Type{Val{:Node_const}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_const_initType(ptr)
            Base.depwarn("Node_const_initType is deprecated, use init_type!(ptr, Val{:Node_const}) instead", :Node_const_initType)
            init_type!(ptr, Val{:Node_const})
        end
        function get_value(ptr::Capnp.StructPointer{T}, ::Type{Val{:Node_const}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 4)
            Capnp.validate_struct_pointer(p, Value_data_word_count, Value_pointer_count, "Value")
            p
        end
        function Node_const_getValue(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Node_const_getValue is deprecated, use get_value(ptr, Val{:Node_const}) instead", :Node_const_getValue)
            get_value(ptr, Val{:Node_const})
        end
        function get_value(promise::Capnp.RPC.Promise, ::Type{Val{:Node_const}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(4))])
        end
        function init_value!(ptr, ::Type{Val{:Node_const}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 4)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*3)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(2), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_const_initValue(ptr)
            Base.depwarn("Node_const_initValue is deprecated, use init_value!(ptr, Val{:Node_const}) instead", :Node_const_initValue)
            init_value!(ptr, Val{:Node_const})
        end
        function get_annotation(ptr::Capnp.StructPointer, ::Type{Val{:Node}})
            ptr
        end
        function Node_getAnnotation(ptr::Capnp.StructPointer)
            Base.depwarn("Node_getAnnotation is deprecated, use get_annotation(ptr, Val{:Node}) instead", :Node_getAnnotation)
            get_annotation(ptr, Val{:Node})
        end
        function init_annotation!(ptr, ::Type{Val{:Node}})
            Capnp.write_bits(ptr, 12, UInt16, 5) # union discriminant
            ptr
        end
        function Node_initAnnotation(ptr)
            Base.depwarn("Node_initAnnotation is deprecated, use init_annotation!(ptr, Val{:Node}) instead", :Node_initAnnotation)
            init_annotation!(ptr, Val{:Node})
        end
        function root(message, ::Type{Val{:Node_annotation}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Node_annotation_data_word_count, Node_annotation_pointer_count, "Node_annotation")
            p
        end
        function root_Node_annotation(message)
            Base.depwarn("root_Node_annotation is deprecated, use root(message, Val{:Node_annotation}) instead", :root_Node_annotation)
            root(message, Val{:Node_annotation})
        end
        function init_root!(builder, ::Type{Val{:Node_annotation}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*11)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(5), UInt16(6))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Node_annotation(builder)
            Base.depwarn("initRoot_Node_annotation is deprecated, use init_root!(builder, Val{:Node_annotation}) instead", :initRoot_Node_annotation)
            init_root!(builder, Val{:Node_annotation})
        end
        function get_type(ptr::Capnp.StructPointer{T}, ::Type{Val{:Node_annotation}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 3)
            Capnp.validate_struct_pointer(p, Type_data_word_count, Type_pointer_count, "Type")
            p
        end
        function Node_annotation_getType(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Node_annotation_getType is deprecated, use get_type(ptr, Val{:Node_annotation}) instead", :Node_annotation_getType)
            get_type(ptr, Val{:Node_annotation})
        end
        function get_type(promise::Capnp.RPC.Promise, ::Type{Val{:Node_annotation}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(3))])
        end
        function init_type!(ptr, ::Type{Val{:Node_annotation}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_annotation_initType(ptr)
            Base.depwarn("Node_annotation_initType is deprecated, use init_type!(ptr, Val{:Node_annotation}) instead", :Node_annotation_initType)
            init_type!(ptr, Val{:Node_annotation})
        end
        function get_targets_file(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 112)
            value
        end
        function Node_annotation_getTargetsFile(ptr)
            Base.depwarn("Node_annotation_getTargetsFile is deprecated, use get_targets_file(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsFile)
            get_targets_file(ptr, Val{:Node_annotation})
        end
        function set_targets_file!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 112, value)
        end
        function Node_annotation_setTargetsFile(ptr, value)
            Base.depwarn("Node_annotation_setTargetsFile is deprecated, use set_targets_file!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsFile)
            set_targets_file!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_const(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 113)
            value
        end
        function Node_annotation_getTargetsConst(ptr)
            Base.depwarn("Node_annotation_getTargetsConst is deprecated, use get_targets_const(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsConst)
            get_targets_const(ptr, Val{:Node_annotation})
        end
        function set_targets_const!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 113, value)
        end
        function Node_annotation_setTargetsConst(ptr, value)
            Base.depwarn("Node_annotation_setTargetsConst is deprecated, use set_targets_const!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsConst)
            set_targets_const!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_enum(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 114)
            value
        end
        function Node_annotation_getTargetsEnum(ptr)
            Base.depwarn("Node_annotation_getTargetsEnum is deprecated, use get_targets_enum(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsEnum)
            get_targets_enum(ptr, Val{:Node_annotation})
        end
        function set_targets_enum!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 114, value)
        end
        function Node_annotation_setTargetsEnum(ptr, value)
            Base.depwarn("Node_annotation_setTargetsEnum is deprecated, use set_targets_enum!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsEnum)
            set_targets_enum!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_enumerant(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 115)
            value
        end
        function Node_annotation_getTargetsEnumerant(ptr)
            Base.depwarn("Node_annotation_getTargetsEnumerant is deprecated, use get_targets_enumerant(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsEnumerant)
            get_targets_enumerant(ptr, Val{:Node_annotation})
        end
        function set_targets_enumerant!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 115, value)
        end
        function Node_annotation_setTargetsEnumerant(ptr, value)
            Base.depwarn("Node_annotation_setTargetsEnumerant is deprecated, use set_targets_enumerant!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsEnumerant)
            set_targets_enumerant!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_struct(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 116)
            value
        end
        function Node_annotation_getTargetsStruct(ptr)
            Base.depwarn("Node_annotation_getTargetsStruct is deprecated, use get_targets_struct(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsStruct)
            get_targets_struct(ptr, Val{:Node_annotation})
        end
        function set_targets_struct!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 116, value)
        end
        function Node_annotation_setTargetsStruct(ptr, value)
            Base.depwarn("Node_annotation_setTargetsStruct is deprecated, use set_targets_struct!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsStruct)
            set_targets_struct!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_field(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 117)
            value
        end
        function Node_annotation_getTargetsField(ptr)
            Base.depwarn("Node_annotation_getTargetsField is deprecated, use get_targets_field(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsField)
            get_targets_field(ptr, Val{:Node_annotation})
        end
        function set_targets_field!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 117, value)
        end
        function Node_annotation_setTargetsField(ptr, value)
            Base.depwarn("Node_annotation_setTargetsField is deprecated, use set_targets_field!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsField)
            set_targets_field!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_union(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 118)
            value
        end
        function Node_annotation_getTargetsUnion(ptr)
            Base.depwarn("Node_annotation_getTargetsUnion is deprecated, use get_targets_union(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsUnion)
            get_targets_union(ptr, Val{:Node_annotation})
        end
        function set_targets_union!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 118, value)
        end
        function Node_annotation_setTargetsUnion(ptr, value)
            Base.depwarn("Node_annotation_setTargetsUnion is deprecated, use set_targets_union!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsUnion)
            set_targets_union!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_group(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 119)
            value
        end
        function Node_annotation_getTargetsGroup(ptr)
            Base.depwarn("Node_annotation_getTargetsGroup is deprecated, use get_targets_group(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsGroup)
            get_targets_group(ptr, Val{:Node_annotation})
        end
        function set_targets_group!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 119, value)
        end
        function Node_annotation_setTargetsGroup(ptr, value)
            Base.depwarn("Node_annotation_setTargetsGroup is deprecated, use set_targets_group!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsGroup)
            set_targets_group!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_interface(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 120)
            value
        end
        function Node_annotation_getTargetsInterface(ptr)
            Base.depwarn("Node_annotation_getTargetsInterface is deprecated, use get_targets_interface(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsInterface)
            get_targets_interface(ptr, Val{:Node_annotation})
        end
        function set_targets_interface!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 120, value)
        end
        function Node_annotation_setTargetsInterface(ptr, value)
            Base.depwarn("Node_annotation_setTargetsInterface is deprecated, use set_targets_interface!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsInterface)
            set_targets_interface!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_method(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 121)
            value
        end
        function Node_annotation_getTargetsMethod(ptr)
            Base.depwarn("Node_annotation_getTargetsMethod is deprecated, use get_targets_method(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsMethod)
            get_targets_method(ptr, Val{:Node_annotation})
        end
        function set_targets_method!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 121, value)
        end
        function Node_annotation_setTargetsMethod(ptr, value)
            Base.depwarn("Node_annotation_setTargetsMethod is deprecated, use set_targets_method!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsMethod)
            set_targets_method!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_param(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 122)
            value
        end
        function Node_annotation_getTargetsParam(ptr)
            Base.depwarn("Node_annotation_getTargetsParam is deprecated, use get_targets_param(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsParam)
            get_targets_param(ptr, Val{:Node_annotation})
        end
        function set_targets_param!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 122, value)
        end
        function Node_annotation_setTargetsParam(ptr, value)
            Base.depwarn("Node_annotation_setTargetsParam is deprecated, use set_targets_param!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsParam)
            set_targets_param!(ptr, value, Val{:Node_annotation})
        end
        function get_targets_annotation(ptr, ::Type{Val{:Node_annotation}})
            value = Capnp.read_bool(ptr, 123)
            value
        end
        function Node_annotation_getTargetsAnnotation(ptr)
            Base.depwarn("Node_annotation_getTargetsAnnotation is deprecated, use get_targets_annotation(ptr, Val{:Node_annotation}) instead", :Node_annotation_getTargetsAnnotation)
            get_targets_annotation(ptr, Val{:Node_annotation})
        end
        function set_targets_annotation!(ptr, value, ::Type{Val{:Node_annotation}})
            Capnp.write_bool(ptr, 123, value)
        end
        function Node_annotation_setTargetsAnnotation(ptr, value)
            Base.depwarn("Node_annotation_setTargetsAnnotation is deprecated, use set_targets_annotation!(ptr, value, Val{:Node_annotation}) instead", :Node_annotation_setTargetsAnnotation)
            set_targets_annotation!(ptr, value, Val{:Node_annotation})
        end
        function get_parameters(ptr::Nothing, ::Type{Val{:Node}})
            []
        end
        function Node_getParameters(ptr::Nothing)
            Base.depwarn("Node_getParameters is deprecated, use get_parameters(ptr, Val{:Node}) instead", :Node_getParameters)
            get_parameters(ptr, Val{:Node})
        end
        function get_parameters(ptr, ::Type{Val{:Node}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 5, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Node_Parameter_data_word_count, Node_Parameter_pointer_count, "Node_Parameter")
            p
        end
        function Node_getParameters(ptr)
            Base.depwarn("Node_getParameters is deprecated, use get_parameters(ptr, Val{:Node}) instead", :Node_getParameters)
            get_parameters(ptr, Val{:Node})
        end
        function init_parameters!(ptr, size, ::Type{Val{:Node}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 5)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (0 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(0), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Node_initParameters(ptr, size)
            Base.depwarn("Node_initParameters is deprecated, use init_parameters!(ptr, size, Val{:Node}) instead", :Node_initParameters)
            init_parameters!(ptr, size, Val{:Node})
        end
        function get_is_generic(ptr, ::Type{Val{:Node}})
            value = Capnp.read_bool(ptr, 288)
            value
        end
        function Node_getIsGeneric(ptr)
            Base.depwarn("Node_getIsGeneric is deprecated, use get_is_generic(ptr, Val{:Node}) instead", :Node_getIsGeneric)
            get_is_generic(ptr, Val{:Node})
        end
        function set_is_generic!(ptr, value, ::Type{Val{:Node}})
            Capnp.write_bool(ptr, 288, value)
        end
        function Node_setIsGeneric(ptr, value)
            Base.depwarn("Node_setIsGeneric is deprecated, use set_is_generic!(ptr, value, Val{:Node}) instead", :Node_setIsGeneric)
            set_is_generic!(ptr, value, Val{:Node})
        end
        const Field_noDiscriminant = 65535
        const Field_data_word_count = 3
        const Field_pointer_count = 4
        @enum Field_union::UInt16 Field_union_slot Field_union_group 
        function which(ptr::Capnp.StructPointer, ::Type{Val{:Field}})
            Field_union(Capnp.read_bits(ptr, 8, UInt16))
        end
        function Field_which(ptr::Capnp.StructPointer)
            Base.depwarn("Field_which is deprecated, use which(ptr, Val{:Field}) instead", :Field_which)
            which(ptr, Val{:Field})
        end
        function root(message, ::Type{Val{:Field}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Field_data_word_count, Field_pointer_count, "Field")
            p
        end
        function root_Field(message)
            Base.depwarn("root_Field is deprecated, use root(message, Val{:Field}) instead", :root_Field)
            root(message, Val{:Field})
        end
        function init_root!(builder, ::Type{Val{:Field}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*7)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Field(builder)
            Base.depwarn("initRoot_Field is deprecated, use init_root!(builder, Val{:Field}) instead", :initRoot_Field)
            init_root!(builder, Val{:Field})
        end
        function get_name(ptr, ::Type{Val{:Field}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function Field_getName(ptr)
            Base.depwarn("Field_getName is deprecated, use get_name(ptr, Val{:Field}) instead", :Field_getName)
            get_name(ptr, Val{:Field})
        end
        function set_name!(ptr, txt, ::Type{Val{:Field}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Field_setName(ptr, txt)
            Base.depwarn("Field_setName is deprecated, use set_name!(ptr, txt, Val{:Field}) instead", :Field_setName)
            set_name!(ptr, txt, Val{:Field})
        end
        function get_code_order(ptr, ::Type{Val{:Field}})
            value = Capnp.read_bits(ptr, 0, UInt16)
            value
        end
        function Field_getCodeOrder(ptr)
            Base.depwarn("Field_getCodeOrder is deprecated, use get_code_order(ptr, Val{:Field}) instead", :Field_getCodeOrder)
            get_code_order(ptr, Val{:Field})
        end
        function set_code_order!(ptr, value, ::Type{Val{:Field}})
            Capnp.write_bits(ptr, 0, UInt16, value)
        end
        function Field_setCodeOrder(ptr, value)
            Base.depwarn("Field_setCodeOrder is deprecated, use set_code_order!(ptr, value, Val{:Field}) instead", :Field_setCodeOrder)
            set_code_order!(ptr, value, Val{:Field})
        end
        function get_annotations(ptr::Nothing, ::Type{Val{:Field}})
            []
        end
        function Field_getAnnotations(ptr::Nothing)
            Base.depwarn("Field_getAnnotations is deprecated, use get_annotations(ptr, Val{:Field}) instead", :Field_getAnnotations)
            get_annotations(ptr, Val{:Field})
        end
        function get_annotations(ptr, ::Type{Val{:Field}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 1, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Annotation_data_word_count, Annotation_pointer_count, "Annotation")
            p
        end
        function Field_getAnnotations(ptr)
            Base.depwarn("Field_getAnnotations is deprecated, use get_annotations(ptr, Val{:Field}) instead", :Field_getAnnotations)
            get_annotations(ptr, Val{:Field})
        end
        function init_annotations!(ptr, size, ::Type{Val{:Field}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Field_initAnnotations(ptr, size)
            Base.depwarn("Field_initAnnotations is deprecated, use init_annotations!(ptr, size, Val{:Field}) instead", :Field_initAnnotations)
            init_annotations!(ptr, size, Val{:Field})
        end
        function get_discriminant_value(ptr, ::Type{Val{:Field}})
            value = Capnp.read_bits(ptr, 2, UInt16)
            value = xor(value, UInt16(65535))
            value
        end
        function Field_getDiscriminantValue(ptr)
            Base.depwarn("Field_getDiscriminantValue is deprecated, use get_discriminant_value(ptr, Val{:Field}) instead", :Field_getDiscriminantValue)
            get_discriminant_value(ptr, Val{:Field})
        end
        function set_discriminant_value!(ptr, value, ::Type{Val{:Field}})
            Capnp.write_bits(ptr, 2, UInt16, value)
        end
        function Field_setDiscriminantValue(ptr, value)
            Base.depwarn("Field_setDiscriminantValue is deprecated, use set_discriminant_value!(ptr, value, Val{:Field}) instead", :Field_setDiscriminantValue)
            set_discriminant_value!(ptr, value, Val{:Field})
        end
        function get_slot(ptr::Capnp.StructPointer, ::Type{Val{:Field}})
            ptr
        end
        function Field_getSlot(ptr::Capnp.StructPointer)
            Base.depwarn("Field_getSlot is deprecated, use get_slot(ptr, Val{:Field}) instead", :Field_getSlot)
            get_slot(ptr, Val{:Field})
        end
        function init_slot!(ptr, ::Type{Val{:Field}})
            Capnp.write_bits(ptr, 8, UInt16, 0) # union discriminant
            ptr
        end
        function Field_initSlot(ptr)
            Base.depwarn("Field_initSlot is deprecated, use init_slot!(ptr, Val{:Field}) instead", :Field_initSlot)
            init_slot!(ptr, Val{:Field})
        end
        function root(message, ::Type{Val{:Field_slot}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Field_slot_data_word_count, Field_slot_pointer_count, "Field_slot")
            p
        end
        function root_Field_slot(message)
            Base.depwarn("root_Field_slot is deprecated, use root(message, Val{:Field_slot}) instead", :root_Field_slot)
            root(message, Val{:Field_slot})
        end
        function init_root!(builder, ::Type{Val{:Field_slot}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*7)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Field_slot(builder)
            Base.depwarn("initRoot_Field_slot is deprecated, use init_root!(builder, Val{:Field_slot}) instead", :initRoot_Field_slot)
            init_root!(builder, Val{:Field_slot})
        end
        function get_offset(ptr, ::Type{Val{:Field_slot}})
            value = Capnp.read_bits(ptr, 4, UInt32)
            value
        end
        function Field_slot_getOffset(ptr)
            Base.depwarn("Field_slot_getOffset is deprecated, use get_offset(ptr, Val{:Field_slot}) instead", :Field_slot_getOffset)
            get_offset(ptr, Val{:Field_slot})
        end
        function set_offset!(ptr, value, ::Type{Val{:Field_slot}})
            Capnp.write_bits(ptr, 4, UInt32, value)
        end
        function Field_slot_setOffset(ptr, value)
            Base.depwarn("Field_slot_setOffset is deprecated, use set_offset!(ptr, value, Val{:Field_slot}) instead", :Field_slot_setOffset)
            set_offset!(ptr, value, Val{:Field_slot})
        end
        function get_type(ptr::Capnp.StructPointer{T}, ::Type{Val{:Field_slot}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 2)
            Capnp.validate_struct_pointer(p, Type_data_word_count, Type_pointer_count, "Type")
            p
        end
        function Field_slot_getType(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Field_slot_getType is deprecated, use get_type(ptr, Val{:Field_slot}) instead", :Field_slot_getType)
            get_type(ptr, Val{:Field_slot})
        end
        function get_type(promise::Capnp.RPC.Promise, ::Type{Val{:Field_slot}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(2))])
        end
        function init_type!(ptr, ::Type{Val{:Field_slot}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Field_slot_initType(ptr)
            Base.depwarn("Field_slot_initType is deprecated, use init_type!(ptr, Val{:Field_slot}) instead", :Field_slot_initType)
            init_type!(ptr, Val{:Field_slot})
        end
        function get_default_value(ptr::Capnp.StructPointer{T}, ::Type{Val{:Field_slot}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 3)
            Capnp.validate_struct_pointer(p, Value_data_word_count, Value_pointer_count, "Value")
            p
        end
        function Field_slot_getDefaultValue(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Field_slot_getDefaultValue is deprecated, use get_default_value(ptr, Val{:Field_slot}) instead", :Field_slot_getDefaultValue)
            get_default_value(ptr, Val{:Field_slot})
        end
        function get_default_value(promise::Capnp.RPC.Promise, ::Type{Val{:Field_slot}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(3))])
        end
        function init_default_value!(ptr, ::Type{Val{:Field_slot}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*3)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(2), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Field_slot_initDefaultValue(ptr)
            Base.depwarn("Field_slot_initDefaultValue is deprecated, use init_default_value!(ptr, Val{:Field_slot}) instead", :Field_slot_initDefaultValue)
            init_default_value!(ptr, Val{:Field_slot})
        end
        function get_had_explicit_default(ptr, ::Type{Val{:Field_slot}})
            value = Capnp.read_bool(ptr, 128)
            value
        end
        function Field_slot_getHadExplicitDefault(ptr)
            Base.depwarn("Field_slot_getHadExplicitDefault is deprecated, use get_had_explicit_default(ptr, Val{:Field_slot}) instead", :Field_slot_getHadExplicitDefault)
            get_had_explicit_default(ptr, Val{:Field_slot})
        end
        function set_had_explicit_default!(ptr, value, ::Type{Val{:Field_slot}})
            Capnp.write_bool(ptr, 128, value)
        end
        function Field_slot_setHadExplicitDefault(ptr, value)
            Base.depwarn("Field_slot_setHadExplicitDefault is deprecated, use set_had_explicit_default!(ptr, value, Val{:Field_slot}) instead", :Field_slot_setHadExplicitDefault)
            set_had_explicit_default!(ptr, value, Val{:Field_slot})
        end
        function get_group(ptr::Capnp.StructPointer, ::Type{Val{:Field}})
            ptr
        end
        function Field_getGroup(ptr::Capnp.StructPointer)
            Base.depwarn("Field_getGroup is deprecated, use get_group(ptr, Val{:Field}) instead", :Field_getGroup)
            get_group(ptr, Val{:Field})
        end
        function init_group!(ptr, ::Type{Val{:Field}})
            Capnp.write_bits(ptr, 8, UInt16, 1) # union discriminant
            ptr
        end
        function Field_initGroup(ptr)
            Base.depwarn("Field_initGroup is deprecated, use init_group!(ptr, Val{:Field}) instead", :Field_initGroup)
            init_group!(ptr, Val{:Field})
        end
        function root(message, ::Type{Val{:Field_group}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Field_group_data_word_count, Field_group_pointer_count, "Field_group")
            p
        end
        function root_Field_group(message)
            Base.depwarn("root_Field_group is deprecated, use root(message, Val{:Field_group}) instead", :root_Field_group)
            root(message, Val{:Field_group})
        end
        function init_root!(builder, ::Type{Val{:Field_group}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*7)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Field_group(builder)
            Base.depwarn("initRoot_Field_group is deprecated, use init_root!(builder, Val{:Field_group}) instead", :initRoot_Field_group)
            init_root!(builder, Val{:Field_group})
        end
        function get_type_id(ptr, ::Type{Val{:Field_group}})
            value = Capnp.read_bits(ptr, 16, UInt64)
            value
        end
        function Field_group_getTypeId(ptr)
            Base.depwarn("Field_group_getTypeId is deprecated, use get_type_id(ptr, Val{:Field_group}) instead", :Field_group_getTypeId)
            get_type_id(ptr, Val{:Field_group})
        end
        function set_type_id!(ptr, value, ::Type{Val{:Field_group}})
            Capnp.write_bits(ptr, 16, UInt64, value)
        end
        function Field_group_setTypeId(ptr, value)
            Base.depwarn("Field_group_setTypeId is deprecated, use set_type_id!(ptr, value, Val{:Field_group}) instead", :Field_group_setTypeId)
            set_type_id!(ptr, value, Val{:Field_group})
        end
        function get_ordinal(ptr::Capnp.StructPointer, ::Type{Val{:Field}})
            ptr
        end
        function Field_getOrdinal(ptr::Capnp.StructPointer)
            Base.depwarn("Field_getOrdinal is deprecated, use get_ordinal(ptr, Val{:Field}) instead", :Field_getOrdinal)
            get_ordinal(ptr, Val{:Field})
        end
        function init_ordinal!(ptr, ::Type{Val{:Field}})
            ptr
        end
        function Field_initOrdinal(ptr)
            Base.depwarn("Field_initOrdinal is deprecated, use init_ordinal!(ptr, Val{:Field}) instead", :Field_initOrdinal)
            init_ordinal!(ptr, Val{:Field})
        end
        @enum Field_ordinal_union::UInt16 Field_ordinal_union_implicit Field_ordinal_union_explicit 
        function which(ptr::Capnp.StructPointer, ::Type{Val{:Field_ordinal}})
            Field_ordinal_union(Capnp.read_bits(ptr, 10, UInt16))
        end
        function Field_ordinal_which(ptr::Capnp.StructPointer)
            Base.depwarn("Field_ordinal_which is deprecated, use which(ptr, Val{:Field_ordinal}) instead", :Field_ordinal_which)
            which(ptr, Val{:Field_ordinal})
        end
        function root(message, ::Type{Val{:Field_ordinal}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Field_ordinal_data_word_count, Field_ordinal_pointer_count, "Field_ordinal")
            p
        end
        function root_Field_ordinal(message)
            Base.depwarn("root_Field_ordinal is deprecated, use root(message, Val{:Field_ordinal}) instead", :root_Field_ordinal)
            root(message, Val{:Field_ordinal})
        end
        function init_root!(builder, ::Type{Val{:Field_ordinal}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*7)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(4))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Field_ordinal(builder)
            Base.depwarn("initRoot_Field_ordinal is deprecated, use init_root!(builder, Val{:Field_ordinal}) instead", :initRoot_Field_ordinal)
            init_root!(builder, Val{:Field_ordinal})
        end
        function set_implicit!(ptr, ::Type{Val{:Field_ordinal}})
            Capnp.write_bits(ptr, 10, UInt16, 0) # union discriminant
        end
        function Field_ordinal_setImplicit(ptr)
            Base.depwarn("Field_ordinal_setImplicit is deprecated, use set_implicit!(ptr, Val{:Field_ordinal}) instead", :Field_ordinal_setImplicit)
            set_implicit!(ptr, Val{:Field_ordinal})
        end
        function get_explicit(ptr, ::Type{Val{:Field_ordinal}})
            value = Capnp.read_bits(ptr, 12, UInt16)
            value
        end
        function Field_ordinal_getExplicit(ptr)
            Base.depwarn("Field_ordinal_getExplicit is deprecated, use get_explicit(ptr, Val{:Field_ordinal}) instead", :Field_ordinal_getExplicit)
            get_explicit(ptr, Val{:Field_ordinal})
        end
        function set_explicit!(ptr, value, ::Type{Val{:Field_ordinal}})
            Capnp.write_bits(ptr, 12, UInt16, value)
            Capnp.write_bits(ptr, 10, UInt16, 1) # union discriminant
        end
        function Field_ordinal_setExplicit(ptr, value)
            Base.depwarn("Field_ordinal_setExplicit is deprecated, use set_explicit!(ptr, value, Val{:Field_ordinal}) instead", :Field_ordinal_setExplicit)
            set_explicit!(ptr, value, Val{:Field_ordinal})
        end
        const Enumerant_data_word_count = 1
        const Enumerant_pointer_count = 2
        function root(message, ::Type{Val{:Enumerant}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Enumerant_data_word_count, Enumerant_pointer_count, "Enumerant")
            p
        end
        function root_Enumerant(message)
            Base.depwarn("root_Enumerant is deprecated, use root(message, Val{:Enumerant}) instead", :root_Enumerant)
            root(message, Val{:Enumerant})
        end
        function init_root!(builder, ::Type{Val{:Enumerant}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Enumerant(builder)
            Base.depwarn("initRoot_Enumerant is deprecated, use init_root!(builder, Val{:Enumerant}) instead", :initRoot_Enumerant)
            init_root!(builder, Val{:Enumerant})
        end
        function get_name(ptr, ::Type{Val{:Enumerant}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function Enumerant_getName(ptr)
            Base.depwarn("Enumerant_getName is deprecated, use get_name(ptr, Val{:Enumerant}) instead", :Enumerant_getName)
            get_name(ptr, Val{:Enumerant})
        end
        function set_name!(ptr, txt, ::Type{Val{:Enumerant}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Enumerant_setName(ptr, txt)
            Base.depwarn("Enumerant_setName is deprecated, use set_name!(ptr, txt, Val{:Enumerant}) instead", :Enumerant_setName)
            set_name!(ptr, txt, Val{:Enumerant})
        end
        function get_code_order(ptr, ::Type{Val{:Enumerant}})
            value = Capnp.read_bits(ptr, 0, UInt16)
            value
        end
        function Enumerant_getCodeOrder(ptr)
            Base.depwarn("Enumerant_getCodeOrder is deprecated, use get_code_order(ptr, Val{:Enumerant}) instead", :Enumerant_getCodeOrder)
            get_code_order(ptr, Val{:Enumerant})
        end
        function set_code_order!(ptr, value, ::Type{Val{:Enumerant}})
            Capnp.write_bits(ptr, 0, UInt16, value)
        end
        function Enumerant_setCodeOrder(ptr, value)
            Base.depwarn("Enumerant_setCodeOrder is deprecated, use set_code_order!(ptr, value, Val{:Enumerant}) instead", :Enumerant_setCodeOrder)
            set_code_order!(ptr, value, Val{:Enumerant})
        end
        function get_annotations(ptr::Nothing, ::Type{Val{:Enumerant}})
            []
        end
        function Enumerant_getAnnotations(ptr::Nothing)
            Base.depwarn("Enumerant_getAnnotations is deprecated, use get_annotations(ptr, Val{:Enumerant}) instead", :Enumerant_getAnnotations)
            get_annotations(ptr, Val{:Enumerant})
        end
        function get_annotations(ptr, ::Type{Val{:Enumerant}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 1, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Annotation_data_word_count, Annotation_pointer_count, "Annotation")
            p
        end
        function Enumerant_getAnnotations(ptr)
            Base.depwarn("Enumerant_getAnnotations is deprecated, use get_annotations(ptr, Val{:Enumerant}) instead", :Enumerant_getAnnotations)
            get_annotations(ptr, Val{:Enumerant})
        end
        function init_annotations!(ptr, size, ::Type{Val{:Enumerant}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Enumerant_initAnnotations(ptr, size)
            Base.depwarn("Enumerant_initAnnotations is deprecated, use init_annotations!(ptr, size, Val{:Enumerant}) instead", :Enumerant_initAnnotations)
            init_annotations!(ptr, size, Val{:Enumerant})
        end
        const Superclass_data_word_count = 1
        const Superclass_pointer_count = 1
        function root(message, ::Type{Val{:Superclass}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Superclass_data_word_count, Superclass_pointer_count, "Superclass")
            p
        end
        function root_Superclass(message)
            Base.depwarn("root_Superclass is deprecated, use root(message, Val{:Superclass}) instead", :root_Superclass)
            root(message, Val{:Superclass})
        end
        function init_root!(builder, ::Type{Val{:Superclass}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*2)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Superclass(builder)
            Base.depwarn("initRoot_Superclass is deprecated, use init_root!(builder, Val{:Superclass}) instead", :initRoot_Superclass)
            init_root!(builder, Val{:Superclass})
        end
        function get_id(ptr, ::Type{Val{:Superclass}})
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Superclass_getId(ptr)
            Base.depwarn("Superclass_getId is deprecated, use get_id(ptr, Val{:Superclass}) instead", :Superclass_getId)
            get_id(ptr, Val{:Superclass})
        end
        function set_id!(ptr, value, ::Type{Val{:Superclass}})
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Superclass_setId(ptr, value)
            Base.depwarn("Superclass_setId is deprecated, use set_id!(ptr, value, Val{:Superclass}) instead", :Superclass_setId)
            set_id!(ptr, value, Val{:Superclass})
        end
        function get_brand(ptr::Capnp.StructPointer{T}, ::Type{Val{:Superclass}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 0)
            Capnp.validate_struct_pointer(p, Brand_data_word_count, Brand_pointer_count, "Brand")
            p
        end
        function Superclass_getBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Superclass_getBrand is deprecated, use get_brand(ptr, Val{:Superclass}) instead", :Superclass_getBrand)
            get_brand(ptr, Val{:Superclass})
        end
        function get_brand(promise::Capnp.RPC.Promise, ::Type{Val{:Superclass}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(0))])
        end
        function init_brand!(ptr, ::Type{Val{:Superclass}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Superclass_initBrand(ptr)
            Base.depwarn("Superclass_initBrand is deprecated, use init_brand!(ptr, Val{:Superclass}) instead", :Superclass_initBrand)
            init_brand!(ptr, Val{:Superclass})
        end
        const Method_data_word_count = 3
        const Method_pointer_count = 5
        function root(message, ::Type{Val{:Method}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Method_data_word_count, Method_pointer_count, "Method")
            p
        end
        function root_Method(message)
            Base.depwarn("root_Method is deprecated, use root(message, Val{:Method}) instead", :root_Method)
            root(message, Val{:Method})
        end
        function init_root!(builder, ::Type{Val{:Method}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*8)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(5))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Method(builder)
            Base.depwarn("initRoot_Method is deprecated, use init_root!(builder, Val{:Method}) instead", :initRoot_Method)
            init_root!(builder, Val{:Method})
        end
        function get_name(ptr, ::Type{Val{:Method}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function Method_getName(ptr)
            Base.depwarn("Method_getName is deprecated, use get_name(ptr, Val{:Method}) instead", :Method_getName)
            get_name(ptr, Val{:Method})
        end
        function set_name!(ptr, txt, ::Type{Val{:Method}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function Method_setName(ptr, txt)
            Base.depwarn("Method_setName is deprecated, use set_name!(ptr, txt, Val{:Method}) instead", :Method_setName)
            set_name!(ptr, txt, Val{:Method})
        end
        function get_code_order(ptr, ::Type{Val{:Method}})
            value = Capnp.read_bits(ptr, 0, UInt16)
            value
        end
        function Method_getCodeOrder(ptr)
            Base.depwarn("Method_getCodeOrder is deprecated, use get_code_order(ptr, Val{:Method}) instead", :Method_getCodeOrder)
            get_code_order(ptr, Val{:Method})
        end
        function set_code_order!(ptr, value, ::Type{Val{:Method}})
            Capnp.write_bits(ptr, 0, UInt16, value)
        end
        function Method_setCodeOrder(ptr, value)
            Base.depwarn("Method_setCodeOrder is deprecated, use set_code_order!(ptr, value, Val{:Method}) instead", :Method_setCodeOrder)
            set_code_order!(ptr, value, Val{:Method})
        end
        function get_param_struct_type(ptr, ::Type{Val{:Method}})
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Method_getParamStructType(ptr)
            Base.depwarn("Method_getParamStructType is deprecated, use get_param_struct_type(ptr, Val{:Method}) instead", :Method_getParamStructType)
            get_param_struct_type(ptr, Val{:Method})
        end
        function set_param_struct_type!(ptr, value, ::Type{Val{:Method}})
            Capnp.write_bits(ptr, 8, UInt64, value)
        end
        function Method_setParamStructType(ptr, value)
            Base.depwarn("Method_setParamStructType is deprecated, use set_param_struct_type!(ptr, value, Val{:Method}) instead", :Method_setParamStructType)
            set_param_struct_type!(ptr, value, Val{:Method})
        end
        function get_result_struct_type(ptr, ::Type{Val{:Method}})
            value = Capnp.read_bits(ptr, 16, UInt64)
            value
        end
        function Method_getResultStructType(ptr)
            Base.depwarn("Method_getResultStructType is deprecated, use get_result_struct_type(ptr, Val{:Method}) instead", :Method_getResultStructType)
            get_result_struct_type(ptr, Val{:Method})
        end
        function set_result_struct_type!(ptr, value, ::Type{Val{:Method}})
            Capnp.write_bits(ptr, 16, UInt64, value)
        end
        function Method_setResultStructType(ptr, value)
            Base.depwarn("Method_setResultStructType is deprecated, use set_result_struct_type!(ptr, value, Val{:Method}) instead", :Method_setResultStructType)
            set_result_struct_type!(ptr, value, Val{:Method})
        end
        function get_annotations(ptr::Nothing, ::Type{Val{:Method}})
            []
        end
        function Method_getAnnotations(ptr::Nothing)
            Base.depwarn("Method_getAnnotations is deprecated, use get_annotations(ptr, Val{:Method}) instead", :Method_getAnnotations)
            get_annotations(ptr, Val{:Method})
        end
        function get_annotations(ptr, ::Type{Val{:Method}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 1, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Annotation_data_word_count, Annotation_pointer_count, "Annotation")
            p
        end
        function Method_getAnnotations(ptr)
            Base.depwarn("Method_getAnnotations is deprecated, use get_annotations(ptr, Val{:Method}) instead", :Method_getAnnotations)
            get_annotations(ptr, Val{:Method})
        end
        function init_annotations!(ptr, size, ::Type{Val{:Method}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_initAnnotations(ptr, size)
            Base.depwarn("Method_initAnnotations is deprecated, use init_annotations!(ptr, size, Val{:Method}) instead", :Method_initAnnotations)
            init_annotations!(ptr, size, Val{:Method})
        end
        function get_param_brand(ptr::Capnp.StructPointer{T}, ::Type{Val{:Method}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 2)
            Capnp.validate_struct_pointer(p, Brand_data_word_count, Brand_pointer_count, "Brand")
            p
        end
        function Method_getParamBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Method_getParamBrand is deprecated, use get_param_brand(ptr, Val{:Method}) instead", :Method_getParamBrand)
            get_param_brand(ptr, Val{:Method})
        end
        function get_param_brand(promise::Capnp.RPC.Promise, ::Type{Val{:Method}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(2))])
        end
        function init_param_brand!(ptr, ::Type{Val{:Method}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_initParamBrand(ptr)
            Base.depwarn("Method_initParamBrand is deprecated, use init_param_brand!(ptr, Val{:Method}) instead", :Method_initParamBrand)
            init_param_brand!(ptr, Val{:Method})
        end
        function get_result_brand(ptr::Capnp.StructPointer{T}, ::Type{Val{:Method}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 3)
            Capnp.validate_struct_pointer(p, Brand_data_word_count, Brand_pointer_count, "Brand")
            p
        end
        function Method_getResultBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Method_getResultBrand is deprecated, use get_result_brand(ptr, Val{:Method}) instead", :Method_getResultBrand)
            get_result_brand(ptr, Val{:Method})
        end
        function get_result_brand(promise::Capnp.RPC.Promise, ::Type{Val{:Method}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(3))])
        end
        function init_result_brand!(ptr, ::Type{Val{:Method}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_initResultBrand(ptr)
            Base.depwarn("Method_initResultBrand is deprecated, use init_result_brand!(ptr, Val{:Method}) instead", :Method_initResultBrand)
            init_result_brand!(ptr, Val{:Method})
        end
        function get_implicit_parameters(ptr::Nothing, ::Type{Val{:Method}})
            []
        end
        function Method_getImplicitParameters(ptr::Nothing)
            Base.depwarn("Method_getImplicitParameters is deprecated, use get_implicit_parameters(ptr, Val{:Method}) instead", :Method_getImplicitParameters)
            get_implicit_parameters(ptr, Val{:Method})
        end
        function get_implicit_parameters(ptr, ::Type{Val{:Method}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 4, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Node_Parameter_data_word_count, Node_Parameter_pointer_count, "Node_Parameter")
            p
        end
        function Method_getImplicitParameters(ptr)
            Base.depwarn("Method_getImplicitParameters is deprecated, use get_implicit_parameters(ptr, Val{:Method}) instead", :Method_getImplicitParameters)
            get_implicit_parameters(ptr, Val{:Method})
        end
        function init_implicit_parameters!(ptr, size, ::Type{Val{:Method}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 4)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (0 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(0), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Method_initImplicitParameters(ptr, size)
            Base.depwarn("Method_initImplicitParameters is deprecated, use init_implicit_parameters!(ptr, size, Val{:Method}) instead", :Method_initImplicitParameters)
            init_implicit_parameters!(ptr, size, Val{:Method})
        end
        const Type_data_word_count = 3
        const Type_pointer_count = 1
        @enum Type_union::UInt16 Type_union_void Type_union_bool Type_union_int8 Type_union_int16 Type_union_int32 Type_union_int64 Type_union_uint8 Type_union_uint16 Type_union_uint32 Type_union_uint64 Type_union_float32 Type_union_float64 Type_union_text Type_union_data Type_union_list Type_union_enum Type_union_struct Type_union_interface Type_union_anyPointer 
        function which(ptr::Capnp.StructPointer, ::Type{Val{:Type}})
            Type_union(Capnp.read_bits(ptr, 0, UInt16))
        end
        function Type_which(ptr::Capnp.StructPointer)
            Base.depwarn("Type_which is deprecated, use which(ptr, Val{:Type}) instead", :Type_which)
            which(ptr, Val{:Type})
        end
        function root(message, ::Type{Val{:Type}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Type_data_word_count, Type_pointer_count, "Type")
            p
        end
        function root_Type(message)
            Base.depwarn("root_Type is deprecated, use root(message, Val{:Type}) instead", :root_Type)
            root(message, Val{:Type})
        end
        function init_root!(builder, ::Type{Val{:Type}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Type(builder)
            Base.depwarn("initRoot_Type is deprecated, use init_root!(builder, Val{:Type}) instead", :initRoot_Type)
            init_root!(builder, Val{:Type})
        end
        function set_void!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 0) # union discriminant
        end
        function Type_setVoid(ptr)
            Base.depwarn("Type_setVoid is deprecated, use set_void!(ptr, Val{:Type}) instead", :Type_setVoid)
            set_void!(ptr, Val{:Type})
        end
        function set_bool!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 1) # union discriminant
        end
        function Type_setBool(ptr)
            Base.depwarn("Type_setBool is deprecated, use set_bool!(ptr, Val{:Type}) instead", :Type_setBool)
            set_bool!(ptr, Val{:Type})
        end
        function set_int8!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 2) # union discriminant
        end
        function Type_setInt8(ptr)
            Base.depwarn("Type_setInt8 is deprecated, use set_int8!(ptr, Val{:Type}) instead", :Type_setInt8)
            set_int8!(ptr, Val{:Type})
        end
        function set_int16!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 3) # union discriminant
        end
        function Type_setInt16(ptr)
            Base.depwarn("Type_setInt16 is deprecated, use set_int16!(ptr, Val{:Type}) instead", :Type_setInt16)
            set_int16!(ptr, Val{:Type})
        end
        function set_int32!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 4) # union discriminant
        end
        function Type_setInt32(ptr)
            Base.depwarn("Type_setInt32 is deprecated, use set_int32!(ptr, Val{:Type}) instead", :Type_setInt32)
            set_int32!(ptr, Val{:Type})
        end
        function set_int64!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 5) # union discriminant
        end
        function Type_setInt64(ptr)
            Base.depwarn("Type_setInt64 is deprecated, use set_int64!(ptr, Val{:Type}) instead", :Type_setInt64)
            set_int64!(ptr, Val{:Type})
        end
        function set_uint8!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 6) # union discriminant
        end
        function Type_setUint8(ptr)
            Base.depwarn("Type_setUint8 is deprecated, use set_uint8!(ptr, Val{:Type}) instead", :Type_setUint8)
            set_uint8!(ptr, Val{:Type})
        end
        function set_uint16!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 7) # union discriminant
        end
        function Type_setUint16(ptr)
            Base.depwarn("Type_setUint16 is deprecated, use set_uint16!(ptr, Val{:Type}) instead", :Type_setUint16)
            set_uint16!(ptr, Val{:Type})
        end
        function set_uint32!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 8) # union discriminant
        end
        function Type_setUint32(ptr)
            Base.depwarn("Type_setUint32 is deprecated, use set_uint32!(ptr, Val{:Type}) instead", :Type_setUint32)
            set_uint32!(ptr, Val{:Type})
        end
        function set_uint64!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 9) # union discriminant
        end
        function Type_setUint64(ptr)
            Base.depwarn("Type_setUint64 is deprecated, use set_uint64!(ptr, Val{:Type}) instead", :Type_setUint64)
            set_uint64!(ptr, Val{:Type})
        end
        function set_float32!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 10) # union discriminant
        end
        function Type_setFloat32(ptr)
            Base.depwarn("Type_setFloat32 is deprecated, use set_float32!(ptr, Val{:Type}) instead", :Type_setFloat32)
            set_float32!(ptr, Val{:Type})
        end
        function set_float64!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 11) # union discriminant
        end
        function Type_setFloat64(ptr)
            Base.depwarn("Type_setFloat64 is deprecated, use set_float64!(ptr, Val{:Type}) instead", :Type_setFloat64)
            set_float64!(ptr, Val{:Type})
        end
        function set_text!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 12) # union discriminant
        end
        function Type_setText(ptr)
            Base.depwarn("Type_setText is deprecated, use set_text!(ptr, Val{:Type}) instead", :Type_setText)
            set_text!(ptr, Val{:Type})
        end
        function set_data!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 13) # union discriminant
        end
        function Type_setData(ptr)
            Base.depwarn("Type_setData is deprecated, use set_data!(ptr, Val{:Type}) instead", :Type_setData)
            set_data!(ptr, Val{:Type})
        end
        function get_list(ptr::Capnp.StructPointer, ::Type{Val{:Type}})
            ptr
        end
        function Type_getList(ptr::Capnp.StructPointer)
            Base.depwarn("Type_getList is deprecated, use get_list(ptr, Val{:Type}) instead", :Type_getList)
            get_list(ptr, Val{:Type})
        end
        function init_list!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 14) # union discriminant
            ptr
        end
        function Type_initList(ptr)
            Base.depwarn("Type_initList is deprecated, use init_list!(ptr, Val{:Type}) instead", :Type_initList)
            init_list!(ptr, Val{:Type})
        end
        function root(message, ::Type{Val{:Type_list}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Type_list_data_word_count, Type_list_pointer_count, "Type_list")
            p
        end
        function root_Type_list(message)
            Base.depwarn("root_Type_list is deprecated, use root(message, Val{:Type_list}) instead", :root_Type_list)
            root(message, Val{:Type_list})
        end
        function init_root!(builder, ::Type{Val{:Type_list}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Type_list(builder)
            Base.depwarn("initRoot_Type_list is deprecated, use init_root!(builder, Val{:Type_list}) instead", :initRoot_Type_list)
            init_root!(builder, Val{:Type_list})
        end
        function get_element_type(ptr::Capnp.StructPointer{T}, ::Type{Val{:Type_list}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 0)
            Capnp.validate_struct_pointer(p, Type_data_word_count, Type_pointer_count, "Type")
            p
        end
        function Type_list_getElementType(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Type_list_getElementType is deprecated, use get_element_type(ptr, Val{:Type_list}) instead", :Type_list_getElementType)
            get_element_type(ptr, Val{:Type_list})
        end
        function get_element_type(promise::Capnp.RPC.Promise, ::Type{Val{:Type_list}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(0))])
        end
        function init_element_type!(ptr, ::Type{Val{:Type_list}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_list_initElementType(ptr)
            Base.depwarn("Type_list_initElementType is deprecated, use init_element_type!(ptr, Val{:Type_list}) instead", :Type_list_initElementType)
            init_element_type!(ptr, Val{:Type_list})
        end
        function get_enum(ptr::Capnp.StructPointer, ::Type{Val{:Type}})
            ptr
        end
        function Type_getEnum(ptr::Capnp.StructPointer)
            Base.depwarn("Type_getEnum is deprecated, use get_enum(ptr, Val{:Type}) instead", :Type_getEnum)
            get_enum(ptr, Val{:Type})
        end
        function init_enum!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 15) # union discriminant
            ptr
        end
        function Type_initEnum(ptr)
            Base.depwarn("Type_initEnum is deprecated, use init_enum!(ptr, Val{:Type}) instead", :Type_initEnum)
            init_enum!(ptr, Val{:Type})
        end
        function root(message, ::Type{Val{:Type_enum}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Type_enum_data_word_count, Type_enum_pointer_count, "Type_enum")
            p
        end
        function root_Type_enum(message)
            Base.depwarn("root_Type_enum is deprecated, use root(message, Val{:Type_enum}) instead", :root_Type_enum)
            root(message, Val{:Type_enum})
        end
        function init_root!(builder, ::Type{Val{:Type_enum}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Type_enum(builder)
            Base.depwarn("initRoot_Type_enum is deprecated, use init_root!(builder, Val{:Type_enum}) instead", :initRoot_Type_enum)
            init_root!(builder, Val{:Type_enum})
        end
        function get_type_id(ptr, ::Type{Val{:Type_enum}})
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Type_enum_getTypeId(ptr)
            Base.depwarn("Type_enum_getTypeId is deprecated, use get_type_id(ptr, Val{:Type_enum}) instead", :Type_enum_getTypeId)
            get_type_id(ptr, Val{:Type_enum})
        end
        function set_type_id!(ptr, value, ::Type{Val{:Type_enum}})
            Capnp.write_bits(ptr, 8, UInt64, value)
        end
        function Type_enum_setTypeId(ptr, value)
            Base.depwarn("Type_enum_setTypeId is deprecated, use set_type_id!(ptr, value, Val{:Type_enum}) instead", :Type_enum_setTypeId)
            set_type_id!(ptr, value, Val{:Type_enum})
        end
        function get_brand(ptr::Capnp.StructPointer{T}, ::Type{Val{:Type_enum}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 0)
            Capnp.validate_struct_pointer(p, Brand_data_word_count, Brand_pointer_count, "Brand")
            p
        end
        function Type_enum_getBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Type_enum_getBrand is deprecated, use get_brand(ptr, Val{:Type_enum}) instead", :Type_enum_getBrand)
            get_brand(ptr, Val{:Type_enum})
        end
        function get_brand(promise::Capnp.RPC.Promise, ::Type{Val{:Type_enum}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(0))])
        end
        function init_brand!(ptr, ::Type{Val{:Type_enum}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_enum_initBrand(ptr)
            Base.depwarn("Type_enum_initBrand is deprecated, use init_brand!(ptr, Val{:Type_enum}) instead", :Type_enum_initBrand)
            init_brand!(ptr, Val{:Type_enum})
        end
        function get_struct(ptr::Capnp.StructPointer, ::Type{Val{:Type}})
            ptr
        end
        function Type_getStruct(ptr::Capnp.StructPointer)
            Base.depwarn("Type_getStruct is deprecated, use get_struct(ptr, Val{:Type}) instead", :Type_getStruct)
            get_struct(ptr, Val{:Type})
        end
        function init_struct!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 16) # union discriminant
            ptr
        end
        function Type_initStruct(ptr)
            Base.depwarn("Type_initStruct is deprecated, use init_struct!(ptr, Val{:Type}) instead", :Type_initStruct)
            init_struct!(ptr, Val{:Type})
        end
        function root(message, ::Type{Val{:Type_struct}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Type_struct_data_word_count, Type_struct_pointer_count, "Type_struct")
            p
        end
        function root_Type_struct(message)
            Base.depwarn("root_Type_struct is deprecated, use root(message, Val{:Type_struct}) instead", :root_Type_struct)
            root(message, Val{:Type_struct})
        end
        function init_root!(builder, ::Type{Val{:Type_struct}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Type_struct(builder)
            Base.depwarn("initRoot_Type_struct is deprecated, use init_root!(builder, Val{:Type_struct}) instead", :initRoot_Type_struct)
            init_root!(builder, Val{:Type_struct})
        end
        function get_type_id(ptr, ::Type{Val{:Type_struct}})
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Type_struct_getTypeId(ptr)
            Base.depwarn("Type_struct_getTypeId is deprecated, use get_type_id(ptr, Val{:Type_struct}) instead", :Type_struct_getTypeId)
            get_type_id(ptr, Val{:Type_struct})
        end
        function set_type_id!(ptr, value, ::Type{Val{:Type_struct}})
            Capnp.write_bits(ptr, 8, UInt64, value)
        end
        function Type_struct_setTypeId(ptr, value)
            Base.depwarn("Type_struct_setTypeId is deprecated, use set_type_id!(ptr, value, Val{:Type_struct}) instead", :Type_struct_setTypeId)
            set_type_id!(ptr, value, Val{:Type_struct})
        end
        function get_brand(ptr::Capnp.StructPointer{T}, ::Type{Val{:Type_struct}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 0)
            Capnp.validate_struct_pointer(p, Brand_data_word_count, Brand_pointer_count, "Brand")
            p
        end
        function Type_struct_getBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Type_struct_getBrand is deprecated, use get_brand(ptr, Val{:Type_struct}) instead", :Type_struct_getBrand)
            get_brand(ptr, Val{:Type_struct})
        end
        function get_brand(promise::Capnp.RPC.Promise, ::Type{Val{:Type_struct}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(0))])
        end
        function init_brand!(ptr, ::Type{Val{:Type_struct}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_struct_initBrand(ptr)
            Base.depwarn("Type_struct_initBrand is deprecated, use init_brand!(ptr, Val{:Type_struct}) instead", :Type_struct_initBrand)
            init_brand!(ptr, Val{:Type_struct})
        end
        function get_interface(ptr::Capnp.StructPointer, ::Type{Val{:Type}})
            ptr
        end
        function Type_getInterface(ptr::Capnp.StructPointer)
            Base.depwarn("Type_getInterface is deprecated, use get_interface(ptr, Val{:Type}) instead", :Type_getInterface)
            get_interface(ptr, Val{:Type})
        end
        function init_interface!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 17) # union discriminant
            ptr
        end
        function Type_initInterface(ptr)
            Base.depwarn("Type_initInterface is deprecated, use init_interface!(ptr, Val{:Type}) instead", :Type_initInterface)
            init_interface!(ptr, Val{:Type})
        end
        function root(message, ::Type{Val{:Type_interface}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Type_interface_data_word_count, Type_interface_pointer_count, "Type_interface")
            p
        end
        function root_Type_interface(message)
            Base.depwarn("root_Type_interface is deprecated, use root(message, Val{:Type_interface}) instead", :root_Type_interface)
            root(message, Val{:Type_interface})
        end
        function init_root!(builder, ::Type{Val{:Type_interface}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Type_interface(builder)
            Base.depwarn("initRoot_Type_interface is deprecated, use init_root!(builder, Val{:Type_interface}) instead", :initRoot_Type_interface)
            init_root!(builder, Val{:Type_interface})
        end
        function get_type_id(ptr, ::Type{Val{:Type_interface}})
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Type_interface_getTypeId(ptr)
            Base.depwarn("Type_interface_getTypeId is deprecated, use get_type_id(ptr, Val{:Type_interface}) instead", :Type_interface_getTypeId)
            get_type_id(ptr, Val{:Type_interface})
        end
        function set_type_id!(ptr, value, ::Type{Val{:Type_interface}})
            Capnp.write_bits(ptr, 8, UInt64, value)
        end
        function Type_interface_setTypeId(ptr, value)
            Base.depwarn("Type_interface_setTypeId is deprecated, use set_type_id!(ptr, value, Val{:Type_interface}) instead", :Type_interface_setTypeId)
            set_type_id!(ptr, value, Val{:Type_interface})
        end
        function get_brand(ptr::Capnp.StructPointer{T}, ::Type{Val{:Type_interface}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 0)
            Capnp.validate_struct_pointer(p, Brand_data_word_count, Brand_pointer_count, "Brand")
            p
        end
        function Type_interface_getBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Type_interface_getBrand is deprecated, use get_brand(ptr, Val{:Type_interface}) instead", :Type_interface_getBrand)
            get_brand(ptr, Val{:Type_interface})
        end
        function get_brand(promise::Capnp.RPC.Promise, ::Type{Val{:Type_interface}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(0))])
        end
        function init_brand!(ptr, ::Type{Val{:Type_interface}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Type_interface_initBrand(ptr)
            Base.depwarn("Type_interface_initBrand is deprecated, use init_brand!(ptr, Val{:Type_interface}) instead", :Type_interface_initBrand)
            init_brand!(ptr, Val{:Type_interface})
        end
        function get_any_pointer(ptr::Capnp.StructPointer, ::Type{Val{:Type}})
            ptr
        end
        function Type_getAnyPointer(ptr::Capnp.StructPointer)
            Base.depwarn("Type_getAnyPointer is deprecated, use get_any_pointer(ptr, Val{:Type}) instead", :Type_getAnyPointer)
            get_any_pointer(ptr, Val{:Type})
        end
        function init_any_pointer!(ptr, ::Type{Val{:Type}})
            Capnp.write_bits(ptr, 0, UInt16, 18) # union discriminant
            ptr
        end
        function Type_initAnyPointer(ptr)
            Base.depwarn("Type_initAnyPointer is deprecated, use init_any_pointer!(ptr, Val{:Type}) instead", :Type_initAnyPointer)
            init_any_pointer!(ptr, Val{:Type})
        end
        @enum Type_anyPointer_union::UInt16 Type_anyPointer_union_unconstrained Type_anyPointer_union_parameter Type_anyPointer_union_implicitMethodParameter 
        function which(ptr::Capnp.StructPointer, ::Type{Val{:Type_anyPointer}})
            Type_anyPointer_union(Capnp.read_bits(ptr, 8, UInt16))
        end
        function Type_anyPointer_which(ptr::Capnp.StructPointer)
            Base.depwarn("Type_anyPointer_which is deprecated, use which(ptr, Val{:Type_anyPointer}) instead", :Type_anyPointer_which)
            which(ptr, Val{:Type_anyPointer})
        end
        function root(message, ::Type{Val{:Type_anyPointer}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Type_anyPointer_data_word_count, Type_anyPointer_pointer_count, "Type_anyPointer")
            p
        end
        function root_Type_anyPointer(message)
            Base.depwarn("root_Type_anyPointer is deprecated, use root(message, Val{:Type_anyPointer}) instead", :root_Type_anyPointer)
            root(message, Val{:Type_anyPointer})
        end
        function init_root!(builder, ::Type{Val{:Type_anyPointer}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Type_anyPointer(builder)
            Base.depwarn("initRoot_Type_anyPointer is deprecated, use init_root!(builder, Val{:Type_anyPointer}) instead", :initRoot_Type_anyPointer)
            init_root!(builder, Val{:Type_anyPointer})
        end
        function get_unconstrained(ptr::Capnp.StructPointer, ::Type{Val{:Type_anyPointer}})
            ptr
        end
        function Type_anyPointer_getUnconstrained(ptr::Capnp.StructPointer)
            Base.depwarn("Type_anyPointer_getUnconstrained is deprecated, use get_unconstrained(ptr, Val{:Type_anyPointer}) instead", :Type_anyPointer_getUnconstrained)
            get_unconstrained(ptr, Val{:Type_anyPointer})
        end
        function init_unconstrained!(ptr, ::Type{Val{:Type_anyPointer}})
            Capnp.write_bits(ptr, 8, UInt16, 0) # union discriminant
            ptr
        end
        function Type_anyPointer_initUnconstrained(ptr)
            Base.depwarn("Type_anyPointer_initUnconstrained is deprecated, use init_unconstrained!(ptr, Val{:Type_anyPointer}) instead", :Type_anyPointer_initUnconstrained)
            init_unconstrained!(ptr, Val{:Type_anyPointer})
        end
        @enum Type_anyPointer_unconstrained_union::UInt16 Type_anyPointer_unconstrained_union_anyKind Type_anyPointer_unconstrained_union_struct Type_anyPointer_unconstrained_union_list Type_anyPointer_unconstrained_union_capability 
        function which(ptr::Capnp.StructPointer, ::Type{Val{:Type_anyPointer_unconstrained}})
            Type_anyPointer_unconstrained_union(Capnp.read_bits(ptr, 10, UInt16))
        end
        function Type_anyPointer_unconstrained_which(ptr::Capnp.StructPointer)
            Base.depwarn("Type_anyPointer_unconstrained_which is deprecated, use which(ptr, Val{:Type_anyPointer_unconstrained}) instead", :Type_anyPointer_unconstrained_which)
            which(ptr, Val{:Type_anyPointer_unconstrained})
        end
        function root(message, ::Type{Val{:Type_anyPointer_unconstrained}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Type_anyPointer_unconstrained_data_word_count, Type_anyPointer_unconstrained_pointer_count, "Type_anyPointer_unconstrained")
            p
        end
        function root_Type_anyPointer_unconstrained(message)
            Base.depwarn("root_Type_anyPointer_unconstrained is deprecated, use root(message, Val{:Type_anyPointer_unconstrained}) instead", :root_Type_anyPointer_unconstrained)
            root(message, Val{:Type_anyPointer_unconstrained})
        end
        function init_root!(builder, ::Type{Val{:Type_anyPointer_unconstrained}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Type_anyPointer_unconstrained(builder)
            Base.depwarn("initRoot_Type_anyPointer_unconstrained is deprecated, use init_root!(builder, Val{:Type_anyPointer_unconstrained}) instead", :initRoot_Type_anyPointer_unconstrained)
            init_root!(builder, Val{:Type_anyPointer_unconstrained})
        end
        function set_any_kind!(ptr, ::Type{Val{:Type_anyPointer_unconstrained}})
            Capnp.write_bits(ptr, 10, UInt16, 0) # union discriminant
        end
        function Type_anyPointer_unconstrained_setAnyKind(ptr)
            Base.depwarn("Type_anyPointer_unconstrained_setAnyKind is deprecated, use set_any_kind!(ptr, Val{:Type_anyPointer_unconstrained}) instead", :Type_anyPointer_unconstrained_setAnyKind)
            set_any_kind!(ptr, Val{:Type_anyPointer_unconstrained})
        end
        function set_struct!(ptr, ::Type{Val{:Type_anyPointer_unconstrained}})
            Capnp.write_bits(ptr, 10, UInt16, 1) # union discriminant
        end
        function Type_anyPointer_unconstrained_setStruct(ptr)
            Base.depwarn("Type_anyPointer_unconstrained_setStruct is deprecated, use set_struct!(ptr, Val{:Type_anyPointer_unconstrained}) instead", :Type_anyPointer_unconstrained_setStruct)
            set_struct!(ptr, Val{:Type_anyPointer_unconstrained})
        end
        function set_list!(ptr, ::Type{Val{:Type_anyPointer_unconstrained}})
            Capnp.write_bits(ptr, 10, UInt16, 2) # union discriminant
        end
        function Type_anyPointer_unconstrained_setList(ptr)
            Base.depwarn("Type_anyPointer_unconstrained_setList is deprecated, use set_list!(ptr, Val{:Type_anyPointer_unconstrained}) instead", :Type_anyPointer_unconstrained_setList)
            set_list!(ptr, Val{:Type_anyPointer_unconstrained})
        end
        function set_capability!(ptr, ::Type{Val{:Type_anyPointer_unconstrained}})
            Capnp.write_bits(ptr, 10, UInt16, 3) # union discriminant
        end
        function Type_anyPointer_unconstrained_setCapability(ptr)
            Base.depwarn("Type_anyPointer_unconstrained_setCapability is deprecated, use set_capability!(ptr, Val{:Type_anyPointer_unconstrained}) instead", :Type_anyPointer_unconstrained_setCapability)
            set_capability!(ptr, Val{:Type_anyPointer_unconstrained})
        end
        function get_parameter(ptr::Capnp.StructPointer, ::Type{Val{:Type_anyPointer}})
            ptr
        end
        function Type_anyPointer_getParameter(ptr::Capnp.StructPointer)
            Base.depwarn("Type_anyPointer_getParameter is deprecated, use get_parameter(ptr, Val{:Type_anyPointer}) instead", :Type_anyPointer_getParameter)
            get_parameter(ptr, Val{:Type_anyPointer})
        end
        function init_parameter!(ptr, ::Type{Val{:Type_anyPointer}})
            Capnp.write_bits(ptr, 8, UInt16, 1) # union discriminant
            ptr
        end
        function Type_anyPointer_initParameter(ptr)
            Base.depwarn("Type_anyPointer_initParameter is deprecated, use init_parameter!(ptr, Val{:Type_anyPointer}) instead", :Type_anyPointer_initParameter)
            init_parameter!(ptr, Val{:Type_anyPointer})
        end
        function root(message, ::Type{Val{:Type_anyPointer_parameter}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Type_anyPointer_parameter_data_word_count, Type_anyPointer_parameter_pointer_count, "Type_anyPointer_parameter")
            p
        end
        function root_Type_anyPointer_parameter(message)
            Base.depwarn("root_Type_anyPointer_parameter is deprecated, use root(message, Val{:Type_anyPointer_parameter}) instead", :root_Type_anyPointer_parameter)
            root(message, Val{:Type_anyPointer_parameter})
        end
        function init_root!(builder, ::Type{Val{:Type_anyPointer_parameter}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Type_anyPointer_parameter(builder)
            Base.depwarn("initRoot_Type_anyPointer_parameter is deprecated, use init_root!(builder, Val{:Type_anyPointer_parameter}) instead", :initRoot_Type_anyPointer_parameter)
            init_root!(builder, Val{:Type_anyPointer_parameter})
        end
        function get_scope_id(ptr, ::Type{Val{:Type_anyPointer_parameter}})
            value = Capnp.read_bits(ptr, 16, UInt64)
            value
        end
        function Type_anyPointer_parameter_getScopeId(ptr)
            Base.depwarn("Type_anyPointer_parameter_getScopeId is deprecated, use get_scope_id(ptr, Val{:Type_anyPointer_parameter}) instead", :Type_anyPointer_parameter_getScopeId)
            get_scope_id(ptr, Val{:Type_anyPointer_parameter})
        end
        function set_scope_id!(ptr, value, ::Type{Val{:Type_anyPointer_parameter}})
            Capnp.write_bits(ptr, 16, UInt64, value)
        end
        function Type_anyPointer_parameter_setScopeId(ptr, value)
            Base.depwarn("Type_anyPointer_parameter_setScopeId is deprecated, use set_scope_id!(ptr, value, Val{:Type_anyPointer_parameter}) instead", :Type_anyPointer_parameter_setScopeId)
            set_scope_id!(ptr, value, Val{:Type_anyPointer_parameter})
        end
        function get_parameter_index(ptr, ::Type{Val{:Type_anyPointer_parameter}})
            value = Capnp.read_bits(ptr, 10, UInt16)
            value
        end
        function Type_anyPointer_parameter_getParameterIndex(ptr)
            Base.depwarn("Type_anyPointer_parameter_getParameterIndex is deprecated, use get_parameter_index(ptr, Val{:Type_anyPointer_parameter}) instead", :Type_anyPointer_parameter_getParameterIndex)
            get_parameter_index(ptr, Val{:Type_anyPointer_parameter})
        end
        function set_parameter_index!(ptr, value, ::Type{Val{:Type_anyPointer_parameter}})
            Capnp.write_bits(ptr, 10, UInt16, value)
        end
        function Type_anyPointer_parameter_setParameterIndex(ptr, value)
            Base.depwarn("Type_anyPointer_parameter_setParameterIndex is deprecated, use set_parameter_index!(ptr, value, Val{:Type_anyPointer_parameter}) instead", :Type_anyPointer_parameter_setParameterIndex)
            set_parameter_index!(ptr, value, Val{:Type_anyPointer_parameter})
        end
        function get_implicit_method_parameter(ptr::Capnp.StructPointer, ::Type{Val{:Type_anyPointer}})
            ptr
        end
        function Type_anyPointer_getImplicitMethodParameter(ptr::Capnp.StructPointer)
            Base.depwarn("Type_anyPointer_getImplicitMethodParameter is deprecated, use get_implicit_method_parameter(ptr, Val{:Type_anyPointer}) instead", :Type_anyPointer_getImplicitMethodParameter)
            get_implicit_method_parameter(ptr, Val{:Type_anyPointer})
        end
        function init_implicit_method_parameter!(ptr, ::Type{Val{:Type_anyPointer}})
            Capnp.write_bits(ptr, 8, UInt16, 2) # union discriminant
            ptr
        end
        function Type_anyPointer_initImplicitMethodParameter(ptr)
            Base.depwarn("Type_anyPointer_initImplicitMethodParameter is deprecated, use init_implicit_method_parameter!(ptr, Val{:Type_anyPointer}) instead", :Type_anyPointer_initImplicitMethodParameter)
            init_implicit_method_parameter!(ptr, Val{:Type_anyPointer})
        end
        function root(message, ::Type{Val{:Type_anyPointer_implicitMethodParameter}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Type_anyPointer_implicitMethodParameter_data_word_count, Type_anyPointer_implicitMethodParameter_pointer_count, "Type_anyPointer_implicitMethodParameter")
            p
        end
        function root_Type_anyPointer_implicitMethodParameter(message)
            Base.depwarn("root_Type_anyPointer_implicitMethodParameter is deprecated, use root(message, Val{:Type_anyPointer_implicitMethodParameter}) instead", :root_Type_anyPointer_implicitMethodParameter)
            root(message, Val{:Type_anyPointer_implicitMethodParameter})
        end
        function init_root!(builder, ::Type{Val{:Type_anyPointer_implicitMethodParameter}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Type_anyPointer_implicitMethodParameter(builder)
            Base.depwarn("initRoot_Type_anyPointer_implicitMethodParameter is deprecated, use init_root!(builder, Val{:Type_anyPointer_implicitMethodParameter}) instead", :initRoot_Type_anyPointer_implicitMethodParameter)
            init_root!(builder, Val{:Type_anyPointer_implicitMethodParameter})
        end
        function get_parameter_index(ptr, ::Type{Val{:Type_anyPointer_implicitMethodParameter}})
            value = Capnp.read_bits(ptr, 10, UInt16)
            value
        end
        function Type_anyPointer_implicitMethodParameter_getParameterIndex(ptr)
            Base.depwarn("Type_anyPointer_implicitMethodParameter_getParameterIndex is deprecated, use get_parameter_index(ptr, Val{:Type_anyPointer_implicitMethodParameter}) instead", :Type_anyPointer_implicitMethodParameter_getParameterIndex)
            get_parameter_index(ptr, Val{:Type_anyPointer_implicitMethodParameter})
        end
        function set_parameter_index!(ptr, value, ::Type{Val{:Type_anyPointer_implicitMethodParameter}})
            Capnp.write_bits(ptr, 10, UInt16, value)
        end
        function Type_anyPointer_implicitMethodParameter_setParameterIndex(ptr, value)
            Base.depwarn("Type_anyPointer_implicitMethodParameter_setParameterIndex is deprecated, use set_parameter_index!(ptr, value, Val{:Type_anyPointer_implicitMethodParameter}) instead", :Type_anyPointer_implicitMethodParameter_setParameterIndex)
            set_parameter_index!(ptr, value, Val{:Type_anyPointer_implicitMethodParameter})
        end
        const Brand_Scope_data_word_count = 2
        const Brand_Scope_pointer_count = 1
        @enum Brand_Scope_union::UInt16 Brand_Scope_union_bind Brand_Scope_union_inherit 
        function which(ptr::Capnp.StructPointer, ::Type{Val{:Brand_Scope}})
            Brand_Scope_union(Capnp.read_bits(ptr, 8, UInt16))
        end
        function Brand_Scope_which(ptr::Capnp.StructPointer)
            Base.depwarn("Brand_Scope_which is deprecated, use which(ptr, Val{:Brand_Scope}) instead", :Brand_Scope_which)
            which(ptr, Val{:Brand_Scope})
        end
        function root(message, ::Type{Val{:Brand_Scope}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Brand_Scope_data_word_count, Brand_Scope_pointer_count, "Brand_Scope")
            p
        end
        function root_Brand_Scope(message)
            Base.depwarn("root_Brand_Scope is deprecated, use root(message, Val{:Brand_Scope}) instead", :root_Brand_Scope)
            root(message, Val{:Brand_Scope})
        end
        function init_root!(builder, ::Type{Val{:Brand_Scope}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(2), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Brand_Scope(builder)
            Base.depwarn("initRoot_Brand_Scope is deprecated, use init_root!(builder, Val{:Brand_Scope}) instead", :initRoot_Brand_Scope)
            init_root!(builder, Val{:Brand_Scope})
        end
        function get_scope_id(ptr, ::Type{Val{:Brand_Scope}})
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Brand_Scope_getScopeId(ptr)
            Base.depwarn("Brand_Scope_getScopeId is deprecated, use get_scope_id(ptr, Val{:Brand_Scope}) instead", :Brand_Scope_getScopeId)
            get_scope_id(ptr, Val{:Brand_Scope})
        end
        function set_scope_id!(ptr, value, ::Type{Val{:Brand_Scope}})
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Brand_Scope_setScopeId(ptr, value)
            Base.depwarn("Brand_Scope_setScopeId is deprecated, use set_scope_id!(ptr, value, Val{:Brand_Scope}) instead", :Brand_Scope_setScopeId)
            set_scope_id!(ptr, value, Val{:Brand_Scope})
        end
        function get_bind(ptr::Nothing, ::Type{Val{:Brand_Scope}})
            []
        end
        function Brand_Scope_getBind(ptr::Nothing)
            Base.depwarn("Brand_Scope_getBind is deprecated, use get_bind(ptr, Val{:Brand_Scope}) instead", :Brand_Scope_getBind)
            get_bind(ptr, Val{:Brand_Scope})
        end
        function get_bind(ptr, ::Type{Val{:Brand_Scope}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Brand_Binding_data_word_count, Brand_Binding_pointer_count, "Brand_Binding")
            p
        end
        function Brand_Scope_getBind(ptr)
            Base.depwarn("Brand_Scope_getBind is deprecated, use get_bind(ptr, Val{:Brand_Scope}) instead", :Brand_Scope_getBind)
            get_bind(ptr, Val{:Brand_Scope})
        end
        function init_bind!(ptr, size, ::Type{Val{:Brand_Scope}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_bits(ptr, 8, UInt16, 0) # union discriminant
            child_ptr
        end
        function Brand_Scope_initBind(ptr, size)
            Base.depwarn("Brand_Scope_initBind is deprecated, use init_bind!(ptr, size, Val{:Brand_Scope}) instead", :Brand_Scope_initBind)
            init_bind!(ptr, size, Val{:Brand_Scope})
        end
        function set_inherit!(ptr, ::Type{Val{:Brand_Scope}})
            Capnp.write_bits(ptr, 8, UInt16, 1) # union discriminant
        end
        function Brand_Scope_setInherit(ptr)
            Base.depwarn("Brand_Scope_setInherit is deprecated, use set_inherit!(ptr, Val{:Brand_Scope}) instead", :Brand_Scope_setInherit)
            set_inherit!(ptr, Val{:Brand_Scope})
        end
        const Brand_Binding_data_word_count = 1
        const Brand_Binding_pointer_count = 1
        @enum Brand_Binding_union::UInt16 Brand_Binding_union_unbound Brand_Binding_union_type 
        function which(ptr::Capnp.StructPointer, ::Type{Val{:Brand_Binding}})
            Brand_Binding_union(Capnp.read_bits(ptr, 0, UInt16))
        end
        function Brand_Binding_which(ptr::Capnp.StructPointer)
            Base.depwarn("Brand_Binding_which is deprecated, use which(ptr, Val{:Brand_Binding}) instead", :Brand_Binding_which)
            which(ptr, Val{:Brand_Binding})
        end
        function root(message, ::Type{Val{:Brand_Binding}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Brand_Binding_data_word_count, Brand_Binding_pointer_count, "Brand_Binding")
            p
        end
        function root_Brand_Binding(message)
            Base.depwarn("root_Brand_Binding is deprecated, use root(message, Val{:Brand_Binding}) instead", :root_Brand_Binding)
            root(message, Val{:Brand_Binding})
        end
        function init_root!(builder, ::Type{Val{:Brand_Binding}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*2)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Brand_Binding(builder)
            Base.depwarn("initRoot_Brand_Binding is deprecated, use init_root!(builder, Val{:Brand_Binding}) instead", :initRoot_Brand_Binding)
            init_root!(builder, Val{:Brand_Binding})
        end
        function set_unbound!(ptr, ::Type{Val{:Brand_Binding}})
            Capnp.write_bits(ptr, 0, UInt16, 0) # union discriminant
        end
        function Brand_Binding_setUnbound(ptr)
            Base.depwarn("Brand_Binding_setUnbound is deprecated, use set_unbound!(ptr, Val{:Brand_Binding}) instead", :Brand_Binding_setUnbound)
            set_unbound!(ptr, Val{:Brand_Binding})
        end
        function get_type(ptr::Capnp.StructPointer{T}, ::Type{Val{:Brand_Binding}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 0)
            Capnp.validate_struct_pointer(p, Type_data_word_count, Type_pointer_count, "Type")
            p
        end
        function Brand_Binding_getType(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Brand_Binding_getType is deprecated, use get_type(ptr, Val{:Brand_Binding}) instead", :Brand_Binding_getType)
            get_type(ptr, Val{:Brand_Binding})
        end
        function get_type(promise::Capnp.RPC.Promise, ::Type{Val{:Brand_Binding}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(0))])
        end
        function init_type!(ptr, ::Type{Val{:Brand_Binding}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*4)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(3), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            Capnp.write_bits(ptr, 0, UInt16, 1) # union discriminant
            child_ptr
        end
        function Brand_Binding_initType(ptr)
            Base.depwarn("Brand_Binding_initType is deprecated, use init_type!(ptr, Val{:Brand_Binding}) instead", :Brand_Binding_initType)
            init_type!(ptr, Val{:Brand_Binding})
        end
        const Brand_data_word_count = 0
        const Brand_pointer_count = 1
        function root(message, ::Type{Val{:Brand}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Brand_data_word_count, Brand_pointer_count, "Brand")
            p
        end
        function root_Brand(message)
            Base.depwarn("root_Brand is deprecated, use root(message, Val{:Brand}) instead", :root_Brand)
            root(message, Val{:Brand})
        end
        function init_root!(builder, ::Type{Val{:Brand}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*1)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Brand(builder)
            Base.depwarn("initRoot_Brand is deprecated, use init_root!(builder, Val{:Brand}) instead", :initRoot_Brand)
            init_root!(builder, Val{:Brand})
        end
        function get_scopes(ptr::Nothing, ::Type{Val{:Brand}})
            []
        end
        function Brand_getScopes(ptr::Nothing)
            Base.depwarn("Brand_getScopes is deprecated, use get_scopes(ptr, Val{:Brand}) instead", :Brand_getScopes)
            get_scopes(ptr, Val{:Brand})
        end
        function get_scopes(ptr, ::Type{Val{:Brand}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Brand_Scope_data_word_count, Brand_Scope_pointer_count, "Brand_Scope")
            p
        end
        function Brand_getScopes(ptr)
            Base.depwarn("Brand_getScopes is deprecated, use get_scopes(ptr, Val{:Brand}) instead", :Brand_getScopes)
            get_scopes(ptr, Val{:Brand})
        end
        function init_scopes!(ptr, size, ::Type{Val{:Brand}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (2 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(2), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Brand_initScopes(ptr, size)
            Base.depwarn("Brand_initScopes is deprecated, use init_scopes!(ptr, size, Val{:Brand}) instead", :Brand_initScopes)
            init_scopes!(ptr, size, Val{:Brand})
        end
        const Value_data_word_count = 2
        const Value_pointer_count = 1
        @enum Value_union::UInt16 Value_union_void Value_union_bool Value_union_int8 Value_union_int16 Value_union_int32 Value_union_int64 Value_union_uint8 Value_union_uint16 Value_union_uint32 Value_union_uint64 Value_union_float32 Value_union_float64 Value_union_text Value_union_data Value_union_list Value_union_enum Value_union_struct Value_union_interface Value_union_anyPointer 
        function which(ptr::Capnp.StructPointer, ::Type{Val{:Value}})
            Value_union(Capnp.read_bits(ptr, 0, UInt16))
        end
        function Value_which(ptr::Capnp.StructPointer)
            Base.depwarn("Value_which is deprecated, use which(ptr, Val{:Value}) instead", :Value_which)
            which(ptr, Val{:Value})
        end
        function root(message, ::Type{Val{:Value}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Value_data_word_count, Value_pointer_count, "Value")
            p
        end
        function root_Value(message)
            Base.depwarn("root_Value is deprecated, use root(message, Val{:Value}) instead", :root_Value)
            root(message, Val{:Value})
        end
        function init_root!(builder, ::Type{Val{:Value}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(2), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Value(builder)
            Base.depwarn("initRoot_Value is deprecated, use init_root!(builder, Val{:Value}) instead", :initRoot_Value)
            init_root!(builder, Val{:Value})
        end
        function set_void!(ptr, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 0, UInt16, 0) # union discriminant
        end
        function Value_setVoid(ptr)
            Base.depwarn("Value_setVoid is deprecated, use set_void!(ptr, Val{:Value}) instead", :Value_setVoid)
            set_void!(ptr, Val{:Value})
        end
        function get_bool(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bool(ptr, 16)
            value
        end
        function Value_getBool(ptr)
            Base.depwarn("Value_getBool is deprecated, use get_bool(ptr, Val{:Value}) instead", :Value_getBool)
            get_bool(ptr, Val{:Value})
        end
        function set_bool!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bool(ptr, 16, value)
            Capnp.write_bits(ptr, 0, UInt16, 1) # union discriminant
        end
        function Value_setBool(ptr, value)
            Base.depwarn("Value_setBool is deprecated, use set_bool!(ptr, value, Val{:Value}) instead", :Value_setBool)
            set_bool!(ptr, value, Val{:Value})
        end
        function get_int8(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 2, Int8)
            value
        end
        function Value_getInt8(ptr)
            Base.depwarn("Value_getInt8 is deprecated, use get_int8(ptr, Val{:Value}) instead", :Value_getInt8)
            get_int8(ptr, Val{:Value})
        end
        function set_int8!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 2, Int8, value)
            Capnp.write_bits(ptr, 0, UInt16, 2) # union discriminant
        end
        function Value_setInt8(ptr, value)
            Base.depwarn("Value_setInt8 is deprecated, use set_int8!(ptr, value, Val{:Value}) instead", :Value_setInt8)
            set_int8!(ptr, value, Val{:Value})
        end
        function get_int16(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 2, Int16)
            value
        end
        function Value_getInt16(ptr)
            Base.depwarn("Value_getInt16 is deprecated, use get_int16(ptr, Val{:Value}) instead", :Value_getInt16)
            get_int16(ptr, Val{:Value})
        end
        function set_int16!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 2, Int16, value)
            Capnp.write_bits(ptr, 0, UInt16, 3) # union discriminant
        end
        function Value_setInt16(ptr, value)
            Base.depwarn("Value_setInt16 is deprecated, use set_int16!(ptr, value, Val{:Value}) instead", :Value_setInt16)
            set_int16!(ptr, value, Val{:Value})
        end
        function get_int32(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 4, Int32)
            value
        end
        function Value_getInt32(ptr)
            Base.depwarn("Value_getInt32 is deprecated, use get_int32(ptr, Val{:Value}) instead", :Value_getInt32)
            get_int32(ptr, Val{:Value})
        end
        function set_int32!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 4, Int32, value)
            Capnp.write_bits(ptr, 0, UInt16, 4) # union discriminant
        end
        function Value_setInt32(ptr, value)
            Base.depwarn("Value_setInt32 is deprecated, use set_int32!(ptr, value, Val{:Value}) instead", :Value_setInt32)
            set_int32!(ptr, value, Val{:Value})
        end
        function get_int64(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 8, Int64)
            value
        end
        function Value_getInt64(ptr)
            Base.depwarn("Value_getInt64 is deprecated, use get_int64(ptr, Val{:Value}) instead", :Value_getInt64)
            get_int64(ptr, Val{:Value})
        end
        function set_int64!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 8, Int64, value)
            Capnp.write_bits(ptr, 0, UInt16, 5) # union discriminant
        end
        function Value_setInt64(ptr, value)
            Base.depwarn("Value_setInt64 is deprecated, use set_int64!(ptr, value, Val{:Value}) instead", :Value_setInt64)
            set_int64!(ptr, value, Val{:Value})
        end
        function get_uint8(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 2, UInt8)
            value
        end
        function Value_getUint8(ptr)
            Base.depwarn("Value_getUint8 is deprecated, use get_uint8(ptr, Val{:Value}) instead", :Value_getUint8)
            get_uint8(ptr, Val{:Value})
        end
        function set_uint8!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 2, UInt8, value)
            Capnp.write_bits(ptr, 0, UInt16, 6) # union discriminant
        end
        function Value_setUint8(ptr, value)
            Base.depwarn("Value_setUint8 is deprecated, use set_uint8!(ptr, value, Val{:Value}) instead", :Value_setUint8)
            set_uint8!(ptr, value, Val{:Value})
        end
        function get_uint16(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 2, UInt16)
            value
        end
        function Value_getUint16(ptr)
            Base.depwarn("Value_getUint16 is deprecated, use get_uint16(ptr, Val{:Value}) instead", :Value_getUint16)
            get_uint16(ptr, Val{:Value})
        end
        function set_uint16!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 2, UInt16, value)
            Capnp.write_bits(ptr, 0, UInt16, 7) # union discriminant
        end
        function Value_setUint16(ptr, value)
            Base.depwarn("Value_setUint16 is deprecated, use set_uint16!(ptr, value, Val{:Value}) instead", :Value_setUint16)
            set_uint16!(ptr, value, Val{:Value})
        end
        function get_uint32(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 4, UInt32)
            value
        end
        function Value_getUint32(ptr)
            Base.depwarn("Value_getUint32 is deprecated, use get_uint32(ptr, Val{:Value}) instead", :Value_getUint32)
            get_uint32(ptr, Val{:Value})
        end
        function set_uint32!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 4, UInt32, value)
            Capnp.write_bits(ptr, 0, UInt16, 8) # union discriminant
        end
        function Value_setUint32(ptr, value)
            Base.depwarn("Value_setUint32 is deprecated, use set_uint32!(ptr, value, Val{:Value}) instead", :Value_setUint32)
            set_uint32!(ptr, value, Val{:Value})
        end
        function get_uint64(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 8, UInt64)
            value
        end
        function Value_getUint64(ptr)
            Base.depwarn("Value_getUint64 is deprecated, use get_uint64(ptr, Val{:Value}) instead", :Value_getUint64)
            get_uint64(ptr, Val{:Value})
        end
        function set_uint64!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 8, UInt64, value)
            Capnp.write_bits(ptr, 0, UInt16, 9) # union discriminant
        end
        function Value_setUint64(ptr, value)
            Base.depwarn("Value_setUint64 is deprecated, use set_uint64!(ptr, value, Val{:Value}) instead", :Value_setUint64)
            set_uint64!(ptr, value, Val{:Value})
        end
        function get_float32(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 4, Float32)
            value
        end
        function Value_getFloat32(ptr)
            Base.depwarn("Value_getFloat32 is deprecated, use get_float32(ptr, Val{:Value}) instead", :Value_getFloat32)
            get_float32(ptr, Val{:Value})
        end
        function set_float32!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 4, Float32, value)
            Capnp.write_bits(ptr, 0, UInt16, 10) # union discriminant
        end
        function Value_setFloat32(ptr, value)
            Base.depwarn("Value_setFloat32 is deprecated, use set_float32!(ptr, value, Val{:Value}) instead", :Value_setFloat32)
            set_float32!(ptr, value, Val{:Value})
        end
        function get_float64(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 8, Float64)
            value
        end
        function Value_getFloat64(ptr)
            Base.depwarn("Value_getFloat64 is deprecated, use get_float64(ptr, Val{:Value}) instead", :Value_getFloat64)
            get_float64(ptr, Val{:Value})
        end
        function set_float64!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 8, Float64, value)
            Capnp.write_bits(ptr, 0, UInt16, 11) # union discriminant
        end
        function Value_setFloat64(ptr, value)
            Base.depwarn("Value_setFloat64 is deprecated, use set_float64!(ptr, value, Val{:Value}) instead", :Value_setFloat64)
            set_float64!(ptr, value, Val{:Value})
        end
        function get_text(ptr, ::Type{Val{:Value}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function Value_getText(ptr)
            Base.depwarn("Value_getText is deprecated, use get_text(ptr, Val{:Value}) instead", :Value_getText)
            get_text(ptr, Val{:Value})
        end
        function set_text!(ptr, txt, ::Type{Val{:Value}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_bits(ptr, 0, UInt16, 12) # union discriminant
            Capnp.write_text(child_ptr, txt)
        end
        function Value_setText(ptr, txt)
            Base.depwarn("Value_setText is deprecated, use set_text!(ptr, txt, Val{:Value}) instead", :Value_setText)
            set_text!(ptr, txt, Val{:Value})
        end
        function get_data(ptr, ::Type{Val{:Value}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_data(p)
        end
        function Value_getData(ptr)
            Base.depwarn("Value_getData is deprecated, use get_data(ptr, Val{:Value}) instead", :Value_getData)
            get_data(ptr, Val{:Value})
        end
        function set_data!(ptr, data::AbstractVector{UInt8}, ::Type{Val{:Value}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(data))
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(data)))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_bits(ptr, 0, UInt16, 13) # union discriminant
            Capnp.write_data(child_ptr, data)
        end
        function Value_setData(ptr, data::AbstractVector{UInt8})
            Base.depwarn("Value_setData is deprecated, use set_data!(ptr, data, Val{:Value}) instead", :Value_setData)
            set_data!(ptr, data, Val{:Value})
        end
        function get_list(ptr, ::Type{Val{:Value}})
            Capnp.read_any_pointer(ptr, ptr.data_word_count, 0)
        end
        function Value_getList(ptr)
            Base.depwarn("Value_getList is deprecated, use get_list(ptr, Val{:Value}) instead", :Value_getList)
            get_list(ptr, Val{:Value})
        end
        function get_enum(ptr, ::Type{Val{:Value}})
            value = Capnp.read_bits(ptr, 2, UInt16)
            value
        end
        function Value_getEnum(ptr)
            Base.depwarn("Value_getEnum is deprecated, use get_enum(ptr, Val{:Value}) instead", :Value_getEnum)
            get_enum(ptr, Val{:Value})
        end
        function set_enum!(ptr, value, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 2, UInt16, value)
            Capnp.write_bits(ptr, 0, UInt16, 15) # union discriminant
        end
        function Value_setEnum(ptr, value)
            Base.depwarn("Value_setEnum is deprecated, use set_enum!(ptr, value, Val{:Value}) instead", :Value_setEnum)
            set_enum!(ptr, value, Val{:Value})
        end
        function get_struct(ptr, ::Type{Val{:Value}})
            Capnp.read_any_pointer(ptr, ptr.data_word_count, 0)
        end
        function Value_getStruct(ptr)
            Base.depwarn("Value_getStruct is deprecated, use get_struct(ptr, Val{:Value}) instead", :Value_getStruct)
            get_struct(ptr, Val{:Value})
        end
        function set_interface!(ptr, ::Type{Val{:Value}})
            Capnp.write_bits(ptr, 0, UInt16, 17) # union discriminant
        end
        function Value_setInterface(ptr)
            Base.depwarn("Value_setInterface is deprecated, use set_interface!(ptr, Val{:Value}) instead", :Value_setInterface)
            set_interface!(ptr, Val{:Value})
        end
        function get_any_pointer(ptr, ::Type{Val{:Value}})
            Capnp.read_any_pointer(ptr, ptr.data_word_count, 0)
        end
        function Value_getAnyPointer(ptr)
            Base.depwarn("Value_getAnyPointer is deprecated, use get_any_pointer(ptr, Val{:Value}) instead", :Value_getAnyPointer)
            get_any_pointer(ptr, Val{:Value})
        end
        const Annotation_data_word_count = 1
        const Annotation_pointer_count = 2
        function root(message, ::Type{Val{:Annotation}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, Annotation_data_word_count, Annotation_pointer_count, "Annotation")
            p
        end
        function root_Annotation(message)
            Base.depwarn("root_Annotation is deprecated, use root(message, Val{:Annotation}) instead", :root_Annotation)
            root(message, Val{:Annotation})
        end
        function init_root!(builder, ::Type{Val{:Annotation}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_Annotation(builder)
            Base.depwarn("initRoot_Annotation is deprecated, use init_root!(builder, Val{:Annotation}) instead", :initRoot_Annotation)
            init_root!(builder, Val{:Annotation})
        end
        function get_id(ptr, ::Type{Val{:Annotation}})
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function Annotation_getId(ptr)
            Base.depwarn("Annotation_getId is deprecated, use get_id(ptr, Val{:Annotation}) instead", :Annotation_getId)
            get_id(ptr, Val{:Annotation})
        end
        function set_id!(ptr, value, ::Type{Val{:Annotation}})
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function Annotation_setId(ptr, value)
            Base.depwarn("Annotation_setId is deprecated, use set_id!(ptr, value, Val{:Annotation}) instead", :Annotation_setId)
            set_id!(ptr, value, Val{:Annotation})
        end
        function get_value(ptr::Capnp.StructPointer{T}, ::Type{Val{:Annotation}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 0)
            Capnp.validate_struct_pointer(p, Value_data_word_count, Value_pointer_count, "Value")
            p
        end
        function Annotation_getValue(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Annotation_getValue is deprecated, use get_value(ptr, Val{:Annotation}) instead", :Annotation_getValue)
            get_value(ptr, Val{:Annotation})
        end
        function get_value(promise::Capnp.RPC.Promise, ::Type{Val{:Annotation}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(0))])
        end
        function init_value!(ptr, ::Type{Val{:Annotation}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*3)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(2), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Annotation_initValue(ptr)
            Base.depwarn("Annotation_initValue is deprecated, use init_value!(ptr, Val{:Annotation}) instead", :Annotation_initValue)
            init_value!(ptr, Val{:Annotation})
        end
        function get_brand(ptr::Capnp.StructPointer{T}, ::Type{Val{:Annotation}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 1)
            Capnp.validate_struct_pointer(p, Brand_data_word_count, Brand_pointer_count, "Brand")
            p
        end
        function Annotation_getBrand(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("Annotation_getBrand is deprecated, use get_brand(ptr, Val{:Annotation}) instead", :Annotation_getBrand)
            get_brand(ptr, Val{:Annotation})
        end
        function get_brand(promise::Capnp.RPC.Promise, ::Type{Val{:Annotation}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(1))])
        end
        function init_brand!(ptr, ::Type{Val{:Annotation}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(0), UInt16(1))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function Annotation_initBrand(ptr)
            Base.depwarn("Annotation_initBrand is deprecated, use init_brand!(ptr, Val{:Annotation}) instead", :Annotation_initBrand)
            init_brand!(ptr, Val{:Annotation})
        end
        @enum ElementSize::UInt16 ElementSize_empty ElementSize_bit ElementSize_byte ElementSize_twoBytes ElementSize_fourBytes ElementSize_eightBytes ElementSize_pointer ElementSize_inlineComposite 
        const CapnpVersion_data_word_count = 1
        const CapnpVersion_pointer_count = 0
        function root(message, ::Type{Val{:CapnpVersion}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, CapnpVersion_data_word_count, CapnpVersion_pointer_count, "CapnpVersion")
            p
        end
        function root_CapnpVersion(message)
            Base.depwarn("root_CapnpVersion is deprecated, use root(message, Val{:CapnpVersion}) instead", :root_CapnpVersion)
            root(message, Val{:CapnpVersion})
        end
        function init_root!(builder, ::Type{Val{:CapnpVersion}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*1)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(0))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_CapnpVersion(builder)
            Base.depwarn("initRoot_CapnpVersion is deprecated, use init_root!(builder, Val{:CapnpVersion}) instead", :initRoot_CapnpVersion)
            init_root!(builder, Val{:CapnpVersion})
        end
        function get_major(ptr, ::Type{Val{:CapnpVersion}})
            value = Capnp.read_bits(ptr, 0, UInt16)
            value
        end
        function CapnpVersion_getMajor(ptr)
            Base.depwarn("CapnpVersion_getMajor is deprecated, use get_major(ptr, Val{:CapnpVersion}) instead", :CapnpVersion_getMajor)
            get_major(ptr, Val{:CapnpVersion})
        end
        function set_major!(ptr, value, ::Type{Val{:CapnpVersion}})
            Capnp.write_bits(ptr, 0, UInt16, value)
        end
        function CapnpVersion_setMajor(ptr, value)
            Base.depwarn("CapnpVersion_setMajor is deprecated, use set_major!(ptr, value, Val{:CapnpVersion}) instead", :CapnpVersion_setMajor)
            set_major!(ptr, value, Val{:CapnpVersion})
        end
        function get_minor(ptr, ::Type{Val{:CapnpVersion}})
            value = Capnp.read_bits(ptr, 2, UInt8)
            value
        end
        function CapnpVersion_getMinor(ptr)
            Base.depwarn("CapnpVersion_getMinor is deprecated, use get_minor(ptr, Val{:CapnpVersion}) instead", :CapnpVersion_getMinor)
            get_minor(ptr, Val{:CapnpVersion})
        end
        function set_minor!(ptr, value, ::Type{Val{:CapnpVersion}})
            Capnp.write_bits(ptr, 2, UInt8, value)
        end
        function CapnpVersion_setMinor(ptr, value)
            Base.depwarn("CapnpVersion_setMinor is deprecated, use set_minor!(ptr, value, Val{:CapnpVersion}) instead", :CapnpVersion_setMinor)
            set_minor!(ptr, value, Val{:CapnpVersion})
        end
        function get_micro(ptr, ::Type{Val{:CapnpVersion}})
            value = Capnp.read_bits(ptr, 3, UInt8)
            value
        end
        function CapnpVersion_getMicro(ptr)
            Base.depwarn("CapnpVersion_getMicro is deprecated, use get_micro(ptr, Val{:CapnpVersion}) instead", :CapnpVersion_getMicro)
            get_micro(ptr, Val{:CapnpVersion})
        end
        function set_micro!(ptr, value, ::Type{Val{:CapnpVersion}})
            Capnp.write_bits(ptr, 3, UInt8, value)
        end
        function CapnpVersion_setMicro(ptr, value)
            Base.depwarn("CapnpVersion_setMicro is deprecated, use set_micro!(ptr, value, Val{:CapnpVersion}) instead", :CapnpVersion_setMicro)
            set_micro!(ptr, value, Val{:CapnpVersion})
        end
        const CodeGeneratorRequest_RequestedFile_Import_data_word_count = 1
        const CodeGeneratorRequest_RequestedFile_Import_pointer_count = 1
        function root(message, ::Type{Val{:CodeGeneratorRequest_RequestedFile_Import}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, CodeGeneratorRequest_RequestedFile_Import_data_word_count, CodeGeneratorRequest_RequestedFile_Import_pointer_count, "CodeGeneratorRequest_RequestedFile_Import")
            p
        end
        function root_CodeGeneratorRequest_RequestedFile_Import(message)
            Base.depwarn("root_CodeGeneratorRequest_RequestedFile_Import is deprecated, use root(message, Val{:CodeGeneratorRequest_RequestedFile_Import}) instead", :root_CodeGeneratorRequest_RequestedFile_Import)
            root(message, Val{:CodeGeneratorRequest_RequestedFile_Import})
        end
        function init_root!(builder, ::Type{Val{:CodeGeneratorRequest_RequestedFile_Import}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*2)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(1))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_CodeGeneratorRequest_RequestedFile_Import(builder)
            Base.depwarn("initRoot_CodeGeneratorRequest_RequestedFile_Import is deprecated, use init_root!(builder, Val{:CodeGeneratorRequest_RequestedFile_Import}) instead", :initRoot_CodeGeneratorRequest_RequestedFile_Import)
            init_root!(builder, Val{:CodeGeneratorRequest_RequestedFile_Import})
        end
        function get_id(ptr, ::Type{Val{:CodeGeneratorRequest_RequestedFile_Import}})
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function CodeGeneratorRequest_RequestedFile_Import_getId(ptr)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_Import_getId is deprecated, use get_id(ptr, Val{:CodeGeneratorRequest_RequestedFile_Import}) instead", :CodeGeneratorRequest_RequestedFile_Import_getId)
            get_id(ptr, Val{:CodeGeneratorRequest_RequestedFile_Import})
        end
        function set_id!(ptr, value, ::Type{Val{:CodeGeneratorRequest_RequestedFile_Import}})
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function CodeGeneratorRequest_RequestedFile_Import_setId(ptr, value)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_Import_setId is deprecated, use set_id!(ptr, value, Val{:CodeGeneratorRequest_RequestedFile_Import}) instead", :CodeGeneratorRequest_RequestedFile_Import_setId)
            set_id!(ptr, value, Val{:CodeGeneratorRequest_RequestedFile_Import})
        end
        function get_name(ptr, ::Type{Val{:CodeGeneratorRequest_RequestedFile_Import}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function CodeGeneratorRequest_RequestedFile_Import_getName(ptr)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_Import_getName is deprecated, use get_name(ptr, Val{:CodeGeneratorRequest_RequestedFile_Import}) instead", :CodeGeneratorRequest_RequestedFile_Import_getName)
            get_name(ptr, Val{:CodeGeneratorRequest_RequestedFile_Import})
        end
        function set_name!(ptr, txt, ::Type{Val{:CodeGeneratorRequest_RequestedFile_Import}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function CodeGeneratorRequest_RequestedFile_Import_setName(ptr, txt)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_Import_setName is deprecated, use set_name!(ptr, txt, Val{:CodeGeneratorRequest_RequestedFile_Import}) instead", :CodeGeneratorRequest_RequestedFile_Import_setName)
            set_name!(ptr, txt, Val{:CodeGeneratorRequest_RequestedFile_Import})
        end
        const CodeGeneratorRequest_RequestedFile_data_word_count = 1
        const CodeGeneratorRequest_RequestedFile_pointer_count = 2
        function root(message, ::Type{Val{:CodeGeneratorRequest_RequestedFile}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, CodeGeneratorRequest_RequestedFile_data_word_count, CodeGeneratorRequest_RequestedFile_pointer_count, "CodeGeneratorRequest_RequestedFile")
            p
        end
        function root_CodeGeneratorRequest_RequestedFile(message)
            Base.depwarn("root_CodeGeneratorRequest_RequestedFile is deprecated, use root(message, Val{:CodeGeneratorRequest_RequestedFile}) instead", :root_CodeGeneratorRequest_RequestedFile)
            root(message, Val{:CodeGeneratorRequest_RequestedFile})
        end
        function init_root!(builder, ::Type{Val{:CodeGeneratorRequest_RequestedFile}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*3)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(1), UInt16(2))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_CodeGeneratorRequest_RequestedFile(builder)
            Base.depwarn("initRoot_CodeGeneratorRequest_RequestedFile is deprecated, use init_root!(builder, Val{:CodeGeneratorRequest_RequestedFile}) instead", :initRoot_CodeGeneratorRequest_RequestedFile)
            init_root!(builder, Val{:CodeGeneratorRequest_RequestedFile})
        end
        function get_id(ptr, ::Type{Val{:CodeGeneratorRequest_RequestedFile}})
            value = Capnp.read_bits(ptr, 0, UInt64)
            value
        end
        function CodeGeneratorRequest_RequestedFile_getId(ptr)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_getId is deprecated, use get_id(ptr, Val{:CodeGeneratorRequest_RequestedFile}) instead", :CodeGeneratorRequest_RequestedFile_getId)
            get_id(ptr, Val{:CodeGeneratorRequest_RequestedFile})
        end
        function set_id!(ptr, value, ::Type{Val{:CodeGeneratorRequest_RequestedFile}})
            Capnp.write_bits(ptr, 0, UInt64, value)
        end
        function CodeGeneratorRequest_RequestedFile_setId(ptr, value)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_setId is deprecated, use set_id!(ptr, value, Val{:CodeGeneratorRequest_RequestedFile}) instead", :CodeGeneratorRequest_RequestedFile_setId)
            set_id!(ptr, value, Val{:CodeGeneratorRequest_RequestedFile})
        end
        function get_filename(ptr, ::Type{Val{:CodeGeneratorRequest_RequestedFile}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0)
            Capnp.read_text(p)
        end
        function CodeGeneratorRequest_RequestedFile_getFilename(ptr)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_getFilename is deprecated, use get_filename(ptr, Val{:CodeGeneratorRequest_RequestedFile}) instead", :CodeGeneratorRequest_RequestedFile_getFilename)
            get_filename(ptr, Val{:CodeGeneratorRequest_RequestedFile})
        end
        function set_filename!(ptr, txt, ::Type{Val{:CodeGeneratorRequest_RequestedFile}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)
            child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            Capnp.write_text(child_ptr, txt)
        end
        function CodeGeneratorRequest_RequestedFile_setFilename(ptr, txt)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_setFilename is deprecated, use set_filename!(ptr, txt, Val{:CodeGeneratorRequest_RequestedFile}) instead", :CodeGeneratorRequest_RequestedFile_setFilename)
            set_filename!(ptr, txt, Val{:CodeGeneratorRequest_RequestedFile})
        end
        function get_imports(ptr::Nothing, ::Type{Val{:CodeGeneratorRequest_RequestedFile}})
            []
        end
        function CodeGeneratorRequest_RequestedFile_getImports(ptr::Nothing)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_getImports is deprecated, use get_imports(ptr, Val{:CodeGeneratorRequest_RequestedFile}) instead", :CodeGeneratorRequest_RequestedFile_getImports)
            get_imports(ptr, Val{:CodeGeneratorRequest_RequestedFile})
        end
        function get_imports(ptr, ::Type{Val{:CodeGeneratorRequest_RequestedFile}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 1, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, CodeGeneratorRequest_RequestedFile_Import_data_word_count, CodeGeneratorRequest_RequestedFile_Import_pointer_count, "CodeGeneratorRequest_RequestedFile_Import")
            p
        end
        function CodeGeneratorRequest_RequestedFile_getImports(ptr)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_getImports is deprecated, use get_imports(ptr, Val{:CodeGeneratorRequest_RequestedFile}) instead", :CodeGeneratorRequest_RequestedFile_getImports)
            get_imports(ptr, Val{:CodeGeneratorRequest_RequestedFile})
        end
        function init_imports!(ptr, size, ::Type{Val{:CodeGeneratorRequest_RequestedFile}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 1)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(1))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_RequestedFile_initImports(ptr, size)
            Base.depwarn("CodeGeneratorRequest_RequestedFile_initImports is deprecated, use init_imports!(ptr, size, Val{:CodeGeneratorRequest_RequestedFile}) instead", :CodeGeneratorRequest_RequestedFile_initImports)
            init_imports!(ptr, size, Val{:CodeGeneratorRequest_RequestedFile})
        end
        const CodeGeneratorRequest_data_word_count = 0
        const CodeGeneratorRequest_pointer_count = 4
        function root(message, ::Type{Val{:CodeGeneratorRequest}})
            ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
            p = Capnp.read_struct_pointer(ptr, 0, 0)
            Capnp.validate_struct_pointer(p, CodeGeneratorRequest_data_word_count, CodeGeneratorRequest_pointer_count, "CodeGeneratorRequest")
            p
        end
        function root_CodeGeneratorRequest(message)
            Base.depwarn("root_CodeGeneratorRequest is deprecated, use root(message, Val{:CodeGeneratorRequest}) instead", :root_CodeGeneratorRequest)
            root(message, Val{:CodeGeneratorRequest})
        end
        function init_root!(builder, ::Type{Val{:CodeGeneratorRequest}})
            pointer_location = Capnp.WirePointer(1, 0)
            Capnp.alloc(builder, pointer_location, 8)
            pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*4)
            ptr = Capnp.StructPointer(builder, segment, offset, UInt16(0), UInt16(4))
            Capnp.write_root_struct_pointer(ptr)
            ptr
        end
        function initRoot_CodeGeneratorRequest(builder)
            Base.depwarn("initRoot_CodeGeneratorRequest is deprecated, use init_root!(builder, Val{:CodeGeneratorRequest}) instead", :initRoot_CodeGeneratorRequest)
            init_root!(builder, Val{:CodeGeneratorRequest})
        end
        function get_nodes(ptr::Nothing, ::Type{Val{:CodeGeneratorRequest}})
            []
        end
        function CodeGeneratorRequest_getNodes(ptr::Nothing)
            Base.depwarn("CodeGeneratorRequest_getNodes is deprecated, use get_nodes(ptr, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_getNodes)
            get_nodes(ptr, Val{:CodeGeneratorRequest})
        end
        function get_nodes(ptr, ::Type{Val{:CodeGeneratorRequest}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 0, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Node_data_word_count, Node_pointer_count, "Node")
            p
        end
        function CodeGeneratorRequest_getNodes(ptr)
            Base.depwarn("CodeGeneratorRequest_getNodes is deprecated, use get_nodes(ptr, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_getNodes)
            get_nodes(ptr, Val{:CodeGeneratorRequest})
        end
        function init_nodes!(ptr, size, ::Type{Val{:CodeGeneratorRequest}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 0)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (5 + 6)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(5), UInt16(6))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_initNodes(ptr, size)
            Base.depwarn("CodeGeneratorRequest_initNodes is deprecated, use init_nodes!(ptr, size, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_initNodes)
            init_nodes!(ptr, size, Val{:CodeGeneratorRequest})
        end
        function get_requested_files(ptr::Nothing, ::Type{Val{:CodeGeneratorRequest}})
            []
        end
        function CodeGeneratorRequest_getRequestedFiles(ptr::Nothing)
            Base.depwarn("CodeGeneratorRequest_getRequestedFiles is deprecated, use get_requested_files(ptr, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_getRequestedFiles)
            get_requested_files(ptr, Val{:CodeGeneratorRequest})
        end
        function get_requested_files(ptr, ::Type{Val{:CodeGeneratorRequest}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 1, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, CodeGeneratorRequest_RequestedFile_data_word_count, CodeGeneratorRequest_RequestedFile_pointer_count, "CodeGeneratorRequest_RequestedFile")
            p
        end
        function CodeGeneratorRequest_getRequestedFiles(ptr)
            Base.depwarn("CodeGeneratorRequest_getRequestedFiles is deprecated, use get_requested_files(ptr, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_getRequestedFiles)
            get_requested_files(ptr, Val{:CodeGeneratorRequest})
        end
        function init_requested_files!(ptr, size, ::Type{Val{:CodeGeneratorRequest}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 1)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_initRequestedFiles(ptr, size)
            Base.depwarn("CodeGeneratorRequest_initRequestedFiles is deprecated, use init_requested_files!(ptr, size, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_initRequestedFiles)
            init_requested_files!(ptr, size, Val{:CodeGeneratorRequest})
        end
        function get_capnp_version(ptr::Capnp.StructPointer{T}, ::Type{Val{:CodeGeneratorRequest}}) where T <: Reader
            p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, 2)
            Capnp.validate_struct_pointer(p, CapnpVersion_data_word_count, CapnpVersion_pointer_count, "CapnpVersion")
            p
        end
        function CodeGeneratorRequest_getCapnpVersion(ptr::Capnp.StructPointer{T}) where T <: Reader
            Base.depwarn("CodeGeneratorRequest_getCapnpVersion is deprecated, use get_capnp_version(ptr, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_getCapnpVersion)
            get_capnp_version(ptr, Val{:CodeGeneratorRequest})
        end
        function get_capnp_version(promise::Capnp.RPC.Promise, ::Type{Val{:CodeGeneratorRequest}})
            Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16(2))])
        end
        function init_capnp_version!(ptr, ::Type{Val{:CodeGeneratorRequest}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 2)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*1)
            child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16(1), UInt16(0))
            Capnp.write_struct_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_initCapnpVersion(ptr)
            Base.depwarn("CodeGeneratorRequest_initCapnpVersion is deprecated, use init_capnp_version!(ptr, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_initCapnpVersion)
            init_capnp_version!(ptr, Val{:CodeGeneratorRequest})
        end
        function get_source_info(ptr::Nothing, ::Type{Val{:CodeGeneratorRequest}})
            []
        end
        function CodeGeneratorRequest_getSourceInfo(ptr::Nothing)
            Base.depwarn("CodeGeneratorRequest_getSourceInfo is deprecated, use get_source_info(ptr, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_getSourceInfo)
            get_source_info(ptr, Val{:CodeGeneratorRequest})
        end
        function get_source_info(ptr, ::Type{Val{:CodeGeneratorRequest}})
            p = Capnp.read_list_pointer(ptr, ptr.data_word_count, 3, Capnp.CapnpStruct)
            Capnp.validate_struct_list_pointer(p, Node_SourceInfo_data_word_count, Node_SourceInfo_pointer_count, "Node_SourceInfo")
            p
        end
        function CodeGeneratorRequest_getSourceInfo(ptr)
            Base.depwarn("CodeGeneratorRequest_getSourceInfo is deprecated, use get_source_info(ptr, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_getSourceInfo)
            get_source_info(ptr, Val{:CodeGeneratorRequest})
        end
        function init_source_info!(ptr, size, ::Type{Val{:CodeGeneratorRequest}})
            pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + 3)
            pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * (1 + 2)))
            child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16(1), UInt16(2))
            Capnp.write_list_pointer(pointer_location, child_ptr)
            child_ptr
        end
        function CodeGeneratorRequest_initSourceInfo(ptr, size)
            Base.depwarn("CodeGeneratorRequest_initSourceInfo is deprecated, use init_source_info!(ptr, size, Val{:CodeGeneratorRequest}) instead", :CodeGeneratorRequest_initSourceInfo)
            init_source_info!(ptr, size, Val{:CodeGeneratorRequest})
        end
    end # module schema
end # module capnp

