# Takes an AST with CodeGeneratorRequest in its root and generates files with Julia code for manipulating data with the
# given schema.

struct NestedData
    parentid::UInt64
    name::String
end

mutable struct Environment
    buffer::IOBuffer # one per file
    nodes::Dict{UInt64,Node}
    nested::Dict{UInt64,NestedData}
    indent::UInt8

    Environment(buffer, nodes, hierarchy) = new(buffer, nodes,hierarchy, 0)
end

function cprintln(env, what)
    print(env.buffer, "    "^env.indent)
    println(env.buffer, what)
end

function build_nested_dependencies(request::CodeGeneratorRequest)
    nested = Dict{UInt64,NestedData}()
    for node in request.nodes
        for nestednode in node.nestedNodes
            nested[nestednode.id] = NestedData(node.id, nestednode.name)
        end
        if node isa StructNode
            for field in node.nodeProperties.fields
                if field isa Field{GroupFieldProps}
                    nested[field.fieldProperties.typeId] = NestedData(node.id, field.name)
                end
            end
        end
    end
    nested
end

function generate(request::CodeGeneratorRequest)
    @assert request.capnpVersion[1] == 0 && request.capnpVersion[2] >= 6

    nodes = Dict(node.id => node for node in request.nodes)
    nested = build_nested_dependencies(request)

    for file in request.requestedFiles
        file_node = nodes[file.id]
        env = Environment(IOBuffer(), nodes, nested)

        # Generate recursively with file node at the root of the tree
        generateNode(env, file_node)

        open(file.filename * ".jl", "w") do io
            println(io, String(take!(env.buffer)))
        end
    end
end

# Finds $Cxx.namespace("capnp::schema"); and returns ["capnp", "schema"]
function namespace_annotation(env::Environment, node::FileNode)::Vector{String}
    namespace_annotations = Iterators.filter(node.annotations) do annotation
        annotation_node = env.nodes[annotation.id]
        # Capnp specification advises against parsing displayName, TODO
        annotation_node.displayName[annotation_node.displayNamePrefixLength+1:end] == "namespace"
    end

    if isempty(namespace_annotations)
        []
    else
        # If you get an exception here it means multiple `namespace` annotations were found
        annotation = Iterators.only(namespace_annotations)
        split(annotation.value, "::")
    end
end

schema_to_runtime_type(::SchemaVoid) = Capnp.CapnpVoid
schema_to_runtime_type(::SchemaBool) = Capnp.CapnpBool
schema_to_runtime_type(::SchemaInt8) = Capnp.CapnpInt8
schema_to_runtime_type(::SchemaInt16) = Capnp.CapnpInt16
schema_to_runtime_type(::SchemaInt32) = Capnp.CapnpInt32
schema_to_runtime_type(::SchemaInt64) = Capnp.CapnpInt64
schema_to_runtime_type(::SchemaUInt8) = Capnp.CapnpUInt8
schema_to_runtime_type(::SchemaUInt16) = Capnp.CapnpUInt16
schema_to_runtime_type(::SchemaUInt32) = Capnp.CapnpUInt32
schema_to_runtime_type(::SchemaUInt64) = Capnp.CapnpUInt64
schema_to_runtime_type(::SchemaFloat32) = Capnp.CapnpFloat32
schema_to_runtime_type(::SchemaFloat64) = Capnp.CapnpFloat64
schema_to_runtime_type(::SchemaStruct) = Capnp.CapnpStruct

function getjuliatype(env::Environment, node::Node)
    nesteddata = get(env.nested, node.id, nothing)
    if isnothing(nesteddata)
        if node isa FileNode
            ""
        else
            @info node typeof(node)
            @assert node isa FileNode
        end
    else
        parent = env.nodes[nesteddata.parentid]
        prefix = getjuliatype(env, parent)
        suffix = nesteddata.name
        if isempty(prefix)
            suffix
        else
            join((prefix, suffix), '_')
        end
    end
end

function getjuliatype(::Environment, type::Capnp.CapnpType)
    runtimetype = schema_to_runtime_type(type)
    @assert is_capnp_bits(runtimetype)
    capnp_type_to_bits_type(runtimetype)
end

function getjuliatype(env::Environment, type::SchemaVoid)
    "Void"
end

function getjuliatype(env::Environment, type::SchemaEnum)
    enum_node = env.nodes[type.typeId] # struct node
    getjuliatype(env, enum_node)
end

function getjuliatype(env::Environment, type::SchemaList, iswriter)
    elementschema = type.elementType
    elementtype = if elementschema isa SchemaList
        getjuliatype(env, elementschema, iswriter)
    else
        getjuliatype(env, elementschema)
    end

    if iswriter
        "ListBuilder{$elementtype}"
    else
        "List{$elementtype}"
    end
end

function getjuliatype(env::Environment, type::SchemaStruct)
    typeNode = env.nodes[type.typeId]
    getjuliatype(env, typeNode)
end

# Phase 2: Generation.
function generateNode(env::Environment, node::FileNode)
    cprintln(env, "using Capnp")
    cprintln(env, "using Capnp: @wrapptr, ReaderPointer, WriterPointer, getptr, List, ListBuilder, Void")

    cprintln(env, "begin")

    # Namespaces come from "namespace" annotation and are translated into Julia modules
    nested_namespaces = namespace_annotation(env, node)
    for namespace in nested_namespaces
        # Code is added into a module which might be created if it wasn't before.
        # N.B. just "module $namespace ..." would overwrite a module if it existed.
        cprintln(env, "if !@isdefined($namespace); eval(:(module $namespace end)); end")
        cprintln(env, "@eval $namespace begin")
        env.indent += 1
    end

    # Generate contents
    cprintln(env, "# Generated from $(node.displayName)")

    for nested_node in node.nestedNodes
        generateNode(env, env.nodes[nested_node.id])
    end

    # Close namespaces/modules
    for _ = 1:length(nested_namespaces)
        env.indent -= 1
        cprintln(env, "end")
    end

    cprintln(env, "end")
end

function generateNode(env::Environment, node::StructNode)
    # nested nodes
    for nested_node in node.nestedNodes
        generateNode(env, env.nodes[nested_node.id])
    end

    nodetype = getjuliatype(env, node)

    # size (does not apply to groups and unions)
    if !node.nodeProperties.isGroup
        cprintln(env, "const $(nodetype)_data_word_count = $(node.nodeProperties.dataWordCount)")
        cprintln(env, "const $(nodetype)_pointer_count = $(node.nodeProperties.pointerCount)")
    end

    # union
    unionFields = filter(f -> f.discriminantValue != noDiscriminant, node.nodeProperties.fields)
    if !isempty(unionFields) # or props.discriminantCount > 0 ?
        cprintln(env, "@enum $(nodetype)_union::UInt16 $([ "$(nodetype)_$(f.name) " for f in unionFields ]...)")
        cprintln(env, "function Base.which(x::$(nodetype))")
        cprintln(env, "    ptr = getptr(x)")
        cprintln(env, "    $(nodetype)_union(Capnp.read_bits(ptr, $(sizeof(UInt16) * node.nodeProperties.discriminantOffset), UInt16))")
        cprintln(env, "end")
    end

    # root
    cprintln(env, "@wrapptr $(nodetype)")

    #  reader
    cprintln(env, "function $(nodetype)(traverser::Reader)")
    cprintln(env, "    ptr = Capnp.StructPointer(traverser, UInt32(1), UInt32(0), UInt16(0), UInt16(1))")
    cprintln(env, "    p = Capnp.read_struct_pointer(ptr, 0, 0)")
    generate_struct_pointer_assert(env, nodetype, "p")
    cprintln(env, "    $(nodetype)(p)")
    cprintln(env, "end")

    #  writer
    cprintln(env, "function $(nodetype)(traverser::Writer)")
    cprintln(env, "    pointer_location = Capnp.WirePointer(1, 0)")
    cprintln(env, "    Capnp.alloc(traverser, pointer_location, 8)") # a word for the root pointer
    cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(traverser, pointer_location, 8*$(node.nodeProperties.dataWordCount + node.nodeProperties.pointerCount))") # root struct
    # cprintln(env, "    @assert pointer_location.segment == 1 && pointer_location.offset == 0")
    cprintln(env, "    ptr = Capnp.StructPointer(traverser, segment, offset, UInt16($(node.nodeProperties.dataWordCount)), UInt16($(node.nodeProperties.pointerCount)))")
    cprintln(env, "    Capnp.write_root_struct_pointer(ptr)")
    cprintln(env, "    $(nodetype)(ptr)")
    cprintln(env, "end")

    # `Field`s
    for field in node.nodeProperties.fields
        generateField(env, node, field)
    end

end
function generateNode(env::Environment, node::ConstNode)
    nodetype = getjuliatype(env, node)
    cprintln(env, "const $(nodetype) = $(node.nodeProperties.value)")
end
function generateNode(env::Environment, node::EnumNode)
    # TODO: Use enumerant.codeOrder
    nodetype = getjuliatype(env, node)
    cprintln(env, "@enum $(nodetype)::UInt16 $([ "$(nodetype)_$(enumerant.name) " for enumerant in node.nodeProperties.enumerants ]...)")
end
function generateNode(::Environment, r::Node)
    @warn "missing generation for node" node=r
end

function generateDiscriminantSetter(env::Environment, structPtrName, strct, field)
    if field.discriminantValue != noDiscriminant
        cprintln(env, "    Capnp.write_bits($(structPtrName), $(sizeof(UInt16) * strct.discriminantOffset), UInt16, $(field.discriminantValue)) # union discriminant")
    end
end


function generateField(env::Environment, node::StructNode, field::Field{GroupFieldProps})
    group_struct = env.nodes[field.fieldProperties.typeId] # struct node
    @assert group_struct.nodeProperties.isGroup

    nodetype = getjuliatype(env, node)
    grouptype = getjuliatype(env, group_struct)

    cprintln(env, "@wrapptr $(grouptype)")

    cprintln(env, "function Base.getindex(x::T, v::Val{:$(field.name)}) where {S<:ReaderPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    $(grouptype)(ptr)")
    cprintln(env, "end")

    cprintln(env, "function Base.getindex(x::T, v::Val{:$(field.name)}) where {S<:WriterPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    $(grouptype)(ptr)")
    cprintln(env, "end")

    generateNode(env, group_struct)
end

function generateSlotField(env, node::StructNode, field::Field{SlotFieldProps}, type::SchemaEnum)
    nodetype = getjuliatype(env, node)
    fieldtype_ = getjuliatype(env, type)
    position = field.fieldProperties.offset * sizeof(UInt16) # "Enums are encoded the same as UInt16."
     
    # reader
    cprintln(env, "function Base.getindex(x::T, ::Val{:$(field.name)}) where {T<:$(nodetype)}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    value = Capnp.read_bits(ptr, $(position), $(fieldtype_))")
    # if field.fieldProperties.defaultValue != 0 # TODO
    #     cprintln(env, "    value = xor(value, $(field.fieldProperties.defaultValue))")
    # end
    cprintln(env, "    value")
    cprintln(env, "end")

    # writer
    cprintln(env, "function Base.setindex!(x::T, value, ::Val{:$(field.name)},) where {T<:$(nodetype)}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    value = Capnp.write_bits(ptr, $(position), $(fieldtype_), value)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "end")
end

function generateSlotField(env, node::StructNode, field::Field{SlotFieldProps}, type::SchemaUnconstrainedPointer)
    nodetype = getjuliatype(env, node)
    position = node.nodeProperties.dataWordCount + field.fieldProperties.offset

    cprintln(env, "function Base.getindex(x::T, ::Val{:$(field.name)}) where {T<:$(nodetype)}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    value = Capnp.read_bits(ptr, $(position), Int64)")
    cprintln(env, "    if value == 0")
    cprintln(env, "        nothing")
    cprintln(env, "    else")
    cprintln(env, "        throw(\"TODO\")")
    cprintln(env, "    end")
    cprintln(env, "end")
end

function generateSlotField(env, node::StructNode, field::Field{SlotFieldProps}, type::SchemaList)
    nodetype = getjuliatype(env, node)
    fieldtype_writer = getjuliatype(env, type, true)
    fieldtype_reader = getjuliatype(env, type, false)
    elementType = type.elementType
    capnptype = schema_to_runtime_type(elementType)
    juliatype = getjuliatype(env, elementType)

    if !(elementType isa SchemaList)
        cprintln(env, "@wrapptr $(juliatype)")
    end

    cprintln(env, "function Base.getindex(x::T,::Val{:$(field.name)}) where {S<:ReaderPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    isnothing(ptr) && return []")
    cprintln(env, "    p = Capnp.read_list_pointer(ptr, $(node.nodeProperties.dataWordCount), $(Int(field.fieldProperties.offset)), $(juliatype))")
    if elementType isa SchemaStruct
        # TODO: when checking for Capnp.SimpleListPointer we should also check that sum(sizeof(strct.fields...)) == p.element_size
        # because "a list of any element size (except C = 1, i.e. 1-bit) may be decoded as a struct list"
        cprintln(env, "    @assert isempty(p) || p isa Capnp.SimpleListPointer ||")
        cprintln(env, "       (p isa Capnp.CompositeListPointer && p.data_word_count == $(juliatype)_data_word_count) && p.pointer_count == $(juliatype)_pointer_count")
    end
    cprintln(env, "    $(fieldtype_reader)(p)")
    cprintln(env, "end")

    cprintln(env, "function Base.getindex(x::T,::Val{:$(field.name)}) where {S<:WriterPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    $(fieldtype_writer)(ptr)")
    cprintln(env, "end")

    if elementType isa SchemaBool
        throw("Lists of bools not supported yet.")
    elseif is_capnp_bits(elementType)
        cprintln(env, "function (list::$(fieldtype_writer))(size)")
        cprintln(env, "    ptr = getptr(list)")
        cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + $(node.nodeProperties.dataWordCount + field.fieldProperties.offset))")
        cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, $(capnp_sizeof(field.fieldProperties.type.elementType)) * size)")
        cprintln(env, "    child_ptr = Capnp.SimpleListPointer{$(capnptype), typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.$(elementsize(field.fieldProperties.type.elementType)), convert(UInt32, size))")
        cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
        generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
        cprintln(env, "    $(fieldtype_reader)(child_ptr)")
        cprintln(env, "end")
    elseif elementType isa SchemaStruct
        # TODO: maybe assert?
        slotStructProps = env.nodes[elementType.typeId].nodeProperties
        cprintln(env, "function (list::$(fieldtype_writer))(size)")
        cprintln(env, "    ptr = getptr(list)")
        cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + $(node.nodeProperties.dataWordCount + field.fieldProperties.offset))")
        cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * ($(slotStructProps.dataWordCount) + $(slotStructProps.pointerCount))))")
        cprintln(env, "    child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16($(slotStructProps.dataWordCount)), UInt16($(slotStructProps.pointerCount)))")
        cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
        generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
        cprintln(env, "    $(fieldtype_reader)(child_ptr)")
        cprintln(env, "end")
    else
        throw("Non-simple or non-struct lists not implemented yet")
    end
end

function generateSlotField(env, node::StructNode, field::Field{SlotFieldProps}, type::SchemaStruct)
    nodetype = getjuliatype(env, node)
    fieldtype_ = getjuliatype(env, type)
    typeNode = env.nodes[type.typeId]
    slotStructProps = typeNode.nodeProperties

    cprintln(env, "@wrapptr $(fieldtype_)")

    cprintln(env, "function Base.getindex(x::T,::Val{:$(field.name)}) where {S<:ReaderPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    p = Capnp.read_struct_pointer(ptr, $(node.nodeProperties.dataWordCount), $(field.fieldProperties.offset))")
    generate_struct_pointer_assert(env, nodetype, "p")
    cprintln(env, "    $(fieldtype_)(p)")
    cprintln(env, "end")

    cprintln(env, "function Base.getindex(x::T,::Val{:$(field.name)}) where {S<:WriterPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + $(node.nodeProperties.dataWordCount + field.fieldProperties.offset))")
    cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*$(slotStructProps.dataWordCount + slotStructProps.pointerCount))")
    cprintln(env, "    child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16($(slotStructProps.dataWordCount)), UInt16($(slotStructProps.pointerCount)))")
    cprintln(env, "    Capnp.write_struct_pointer(pointer_location, child_ptr)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    $(fieldtype_)(child_ptr)")
    cprintln(env, "end")
end

function generateSlotField(env, node::StructNode, field::Field{SlotFieldProps}, type::SchemaText)
    nodetype = getjuliatype(env, node)
    cprintln(env, "function Base.getindex(x::T,::Val{:$(field.name)}) where {S<:ReaderPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    p = Capnp.read_list_pointer(ptr, $(node.nodeProperties.dataWordCount), $(Int(field.fieldProperties.offset)))")
    cprintln(env, "    Capnp.read_text(p)")
    cprintln(env, "end")

    # length +1 for terminating \0
    cprintln(env, "function Base.setindex!(x::T, txt, ::Val{:$(field.name)}) where {S<:WriterPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + $(node.nodeProperties.dataWordCount + field.fieldProperties.offset))")
    cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)")
    cprintln(env, "    child_ptr = Capnp.SimpleListPointer{Capnp.CapnpUInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))")
    cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    Capnp.write_text(child_ptr, txt)")
    cprintln(env, "end")
end

function generateSlotField(env, node::StructNode, field::Field{SlotFieldProps}, type::SchemaVoid)
    nodetype = getjuliatype(env, node)
    fieldtype_ = getjuliatype(env, type)
    cprintln(env, "function Base.getindex(x::T,::Val{:$(field.name)}) where {S<:WriterPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    $(fieldtype_)(ptr)")
    cprintln(env, "end")
end

function generateSlotField(env, node::StructNode, field::Field{SlotFieldProps}, type)
    nodetype = getjuliatype(env, node)
    cprintln(env, "# $(nodetype)'s $(field.name) has type $(type) which is not supported by Capnp.jl yet")
end

# Separate generator for bools than other "plain values" because capnp fits 8 bools into 1 byte.
function generateBoolSlotField(env, node::StructNode, field::Field{SlotFieldProps})
    @assert field.fieldProperties.type isa SchemaBool
    nodetype = getjuliatype(env, node)
    #
    # reader
    cprintln(env, "function Base.getindex(x::T,::Val{:$(field.name)}) where {S<:WriterPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    value = Capnp.read_bool(ptr, $(field.fieldProperties.offset))")
    if field.fieldProperties.defaultValue != zero(Bool)
        cprintln(env, "    value = xor(value, Bool($(field.fieldProperties.defaultValue)))")
    end
    cprintln(env, "    value")
    cprintln(env, "end")

    # writer
    cprintln(env, "function Base.setindex!(x::T, value, ::Val{:$(field.name)}) where {S<:WriterPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    Capnp.write_bool(ptr, $(field.fieldProperties.offset), value)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    # TODO: default value
    cprintln(env, "end")
end

function generateBitsSlotField(env, node::StructNode, field::Field{SlotFieldProps})
    @assert !(field.fieldProperties.type isa SchemaBool)
    nodetype = getjuliatype(env, node)

    position = field.fieldProperties.offset * capnp_sizeof(field.fieldProperties.type)
    juliaBitsType = capnp_type_to_bits_type(field.fieldProperties.type)

    # reader
    cprintln(env, "function Base.getindex(x::T, ::Val{:$(field.name)}) where {S<:ReaderPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    value = Capnp.read_bits(ptr, $(position), $(juliaBitsType))")
    if field.fieldProperties.defaultValue != zero(juliaBitsType)
        cprintln(env, "    value = xor(value, $(juliaBitsType)($(field.fieldProperties.defaultValue)))")
    end
    cprintln(env, "    value")
    cprintln(env, "end")

    # writer
    cprintln(env, "function Base.setindex!(x::T, value, ::Val{:$(field.name)}) where {S<:WriterPointer,T<:$(nodetype){S}}")
    cprintln(env, "    ptr = getptr(x)")
    cprintln(env, "    Capnp.write_bits(ptr, $(position), $(juliaBitsType), value)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    # TODO: default value
    cprintln(env, "end")
end

function generateField(env, node::StructNode, field::Field{SlotFieldProps})
    if field.fieldProperties.type isa SchemaBool
        generateBoolSlotField(env, node, field)
    elseif is_capnp_bits(field.fieldProperties.type)
        generateBitsSlotField(env, node, field)
    else
        generateSlotField(env, node, field, field.fieldProperties.type)
    end
end

function generate_struct_pointer_assert(env, jlName, varname)
    cprintln(env, "    @assert isnothing($varname) || ($varname.data_word_count == $(jlName)_data_word_count) && $varname.pointer_count == $(jlName)_pointer_count")
end
