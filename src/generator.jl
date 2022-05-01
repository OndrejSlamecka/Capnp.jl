# Takes an AST with CodeGeneratorRequest in its root and generates files with Julia code for manipulating data with the
# given schema.

mutable struct Environment
    buffer::IOBuffer # one per file
    nodes::Dict{UInt64,Node}
    indent::UInt8

    Environment(buffer, nodes) = new(buffer, nodes, 0)
end

function cprintln(env, what)
    print(env.buffer, "    "^env.indent)
    println(env.buffer, what)
end

function generate(request::CodeGeneratorRequest)
    @assert request.capnpVersion[1] == 0 && request.capnpVersion[2] >= 6

    nodes = Dict(node.id => node for node in request.nodes)

    for file in request.requestedFiles
        file_node = nodes[file.id]
        env = Environment(IOBuffer(), nodes)

        # Traverse the subtree induced by Nodes to deduce names of all types ahead of generator phase.
        assign_node_names(env, String[], file_node)

        # Generate recursively with file node at the root of the tree
        generateNode(env, file_node)

        open(file.filename * ".jl", "w") do io
            println(io, String(take!(env.buffer)))
        end
    end
end

# Finds $Cxx.namespace("capnp::schema"); and returns ["capnp", "schema"]
function namespace_annotation(env::Environment, node::Node{FileNodeProps})::Vector{String}
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

schema_to_runtime_type(::SchemaVoid   ) = Capnp.CapnpVoid
schema_to_runtime_type(::SchemaBool   ) = Capnp.CapnpBool
schema_to_runtime_type(::SchemaInt8   ) = Capnp.CapnpInt8
schema_to_runtime_type(::SchemaInt16  ) = Capnp.CapnpInt16
schema_to_runtime_type(::SchemaInt32  ) = Capnp.CapnpInt32
schema_to_runtime_type(::SchemaInt64  ) = Capnp.CapnpInt64
schema_to_runtime_type(::SchemaUInt8  ) = Capnp.CapnpUInt8
schema_to_runtime_type(::SchemaUInt16 ) = Capnp.CapnpUInt16
schema_to_runtime_type(::SchemaUInt32 ) = Capnp.CapnpUInt32
schema_to_runtime_type(::SchemaUInt64 ) = Capnp.CapnpUInt64
schema_to_runtime_type(::SchemaFloat32) = Capnp.CapnpFloat32
schema_to_runtime_type(::SchemaFloat64) = Capnp.CapnpFloat64
schema_to_runtime_type(::SchemaStruct ) = Capnp.CapnpStruct

# Phase 1: Determine nested names of types to know all of them before the generation phase.
function assign_node_names(env::Environment, node::Node{FileNodeProps})
    assign_node_names(env, String[], node)
end

function assign_node_names(env::Environment, path::Vector{String}, node::Node{FileNodeProps})
    for nested_node in node.nestedNodes
        push!(path, nested_node.name)
        assign_node_names(env, path, env.nodes[nested_node.id])
        pop!(path)
    end
end

function assign_node_names(env::Environment, path::Vector{String}, node::Node{StructNodeProps})
    node.jlName = join(path, '_')

    for nested_node in node.nestedNodes
        push!(path, nested_node.name)
        assign_node_names(env, path, env.nodes[nested_node.id])
        pop!(path)
    end

    for field in node.nodeProperties.fields
        assign_node_names(env, path, field)
    end
end

function assign_node_names(env::Environment, path::Vector{String}, node::Node)
    node.jlName = join(path, '_')

    for nested_node in node.nestedNodes
        push!(path, nested_node.name)
        assign_node_names(env, path, env.nodes[nested_node.id])
        pop!(path)
    end
end

function assign_node_names(env::Environment, path::Vector{String}, field::Field{GroupFieldProps})
    node = env.nodes[field.fieldProperties.typeId]
    push!(path, field.name)
    assign_node_names(env, path, node)
    pop!(path)
end

function assign_node_names(env::Environment, path::Vector{String}, field::Field) end

# Phase 2: Generation.
function generateNode(env::Environment, node::Node{FileNodeProps})
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
    cprintln(env, "using Capnp")

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

function generateNode(env::Environment, node::Node{StructNodeProps})
    # nested nodes
    for nested_node in node.nestedNodes
        generateNode(env, env.nodes[nested_node.id])
    end

    # size (does not apply to groups and unions)
    if !node.nodeProperties.isGroup
        cprintln(env, "const $(node.jlName)_data_word_count = $(node.nodeProperties.dataWordCount)")
        cprintln(env, "const $(node.jlName)_pointer_count = $(node.nodeProperties.pointerCount)")
    end

    # union
    unionFields = filter(f -> f.discriminantValue != noDiscriminant, node.nodeProperties.fields)
    if !isempty(unionFields) # or props.discriminantCount > 0 ?
        cprintln(env, "@enum $(node.jlName)_union::UInt16 $([ "$(node.jlName)_union_$(f.name) " for f in unionFields ]...)")
        cprintln(env, "function $(node.jlName)_which(ptr::Capnp.StructPointer)")
        cprintln(env, "    $(node.jlName)_union(Capnp.read_bits(ptr, $(sizeof(UInt16) * node.nodeProperties.discriminantOffset), UInt16))")
        cprintln(env, "end")
    end

    # root
    #  reader
    cprintln(env, "function root_$(node.jlName)(message)")
    cprintln(env, "    ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))")
    cprintln(env, "    p = Capnp.read_struct_pointer(ptr, 0, 0)")
    generate_struct_pointer_assert(env, node.jlName, "p")
    cprintln(env, "    p")
    cprintln(env, "end")

    #  writer
    cprintln(env, "function initRoot_$(node.jlName)(builder)")
    cprintln(env, "    pointer_location = Capnp.WirePointer(1, 0)")
    cprintln(env, "    Capnp.alloc(builder, pointer_location, 8)") # a word for the root pointer
    cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*$(node.nodeProperties.dataWordCount + node.nodeProperties.pointerCount))") # root struct
    # cprintln(env, "    @assert pointer_location.segment == 1 && pointer_location.offset == 0")
    cprintln(env, "    ptr = Capnp.StructPointer(builder, segment, offset, UInt16($(node.nodeProperties.dataWordCount)), UInt16($(node.nodeProperties.pointerCount)))")
    cprintln(env, "    Capnp.write_root_struct_pointer(ptr)")
    cprintln(env, "    ptr")
    cprintln(env, "end")

    # `Field`s
    for field in node.nodeProperties.fields
        generateField(env, node, field)
    end

end
function generateNode(env::Environment, node::Node{ConstNodeProps})
    cprintln(env, "const $(node.jlName) = $(node.nodeProperties.value)")
end
function generateNode(env::Environment, node::Node{EnumNodeProps})
    # TODO: Use enumerant.codeOrder
    cprintln(env, "@enum $(node.jlName)::UInt16 $([ "$(node.jlName)_$(enumerant.name) " for enumerant in node.nodeProperties.enumerants ]...)")
end
function generateNode(env::Environment, r::Node) end

function generateDiscriminantSetter(env::Environment, structPtrName, strct, field)
    if field.discriminantValue != noDiscriminant
        cprintln(env, "    Capnp.write_bits($(structPtrName), $(sizeof(UInt16) * strct.discriminantOffset), UInt16, $(field.discriminantValue)) # union discriminant")
    end
end

function generateField(env::Environment, node::Node{StructNodeProps}, field::Field{GroupFieldProps})
    group_struct = env.nodes[field.fieldProperties.typeId] # struct node
    @assert group_struct.nodeProperties.isGroup

    # TODO: Note this returns `ptr` which works because groups live in the scope of their parent, however,
    # ideally, we'd generate proper types and then emit `ptr` with a type tag of this group, providing checks for user code.

    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr::Capnp.StructPointer)")
    cprintln(env, "    ptr")
    cprintln(env, "end")

    cprintln(env, "function $(node.jlName)_init$(uppercasefirst(field.name))(ptr)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    ptr")
    cprintln(env, "end")

    generateNode(env, group_struct)
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaEnum)
    enum = env.nodes[type.typeId]
    position = field.fieldProperties.offset * sizeof(UInt16) # "Enums are encoded the same as UInt16."

    # reader
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    value = Capnp.read_bits(ptr, $(position), $(enum.jlName))")
    # if field.fieldProperties.defaultValue != 0 # TODO
    #     cprintln(env, "    value = xor(value, $(field.fieldProperties.defaultValue))")
    # end
    cprintln(env, "    value")
    cprintln(env, "end")

    # writer
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr, value)")
    cprintln(env, "    value = Capnp.write_bits(ptr, $(position), $(enum.jlName), value)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaUnconstrainedPointer)
    position = node.nodeProperties.dataWordCount + field.fieldProperties.offset

    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    value = Capnp.read_bits(ptr, $(position), Int64)")
    cprintln(env, "    if value == 0")
    cprintln(env, "        Nothing")
    cprintln(env, "    else")
    cprintln(env, "        throw(\"TODO\")")
    cprintln(env, "    end")
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaList)
    elementType = field.fieldProperties.type.elementType
    runtimeElementType = schema_to_runtime_type(field.fieldProperties.type.elementType)

    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr::Nothing)")
    cprintln(env, "    []") # TODO: return Capnp.SimpleListPointer with length 0
    cprintln(env, "end")

    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    p = Capnp.read_list_pointer(ptr, $(node.nodeProperties.dataWordCount), $(Int(field.fieldProperties.offset)), $(runtimeElementType))")
    if elementType isa SchemaStruct
        strct = env.nodes[elementType.typeId]
        # TODO: when checking for Capnp.SimpleListPointer we should also check that sum(sizeof(strct.fields...)) == p.element_size
        # because "a list of any element size (except C = 1, i.e. 1-bit) may be decoded as a struct list"
        cprintln(env, "    @assert isempty(p) || p isa Capnp.SimpleListPointer ||")
        cprintln(env, "       (p isa Capnp.CompositeListPointer && p.data_word_count == $(strct.jlName)_data_word_count) && p.pointer_count == $(strct.jlName)_pointer_count")
    end
    cprintln(env, "    p")
    cprintln(env, "end")

    if field.fieldProperties.type.elementType isa SchemaBool
        throw("Lists of bools not supported yet.")
    elseif is_capnp_bits(field.fieldProperties.type.elementType)
        cprintln(env, "function $(node.jlName)_init$(uppercasefirst(field.name))(ptr, size)")
        cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + $(node.nodeProperties.dataWordCount + field.fieldProperties.offset))")
        cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, $(capnp_sizeof(field.fieldProperties.type.elementType)) * size)")
        cprintln(env, "    child_ptr = Capnp.SimpleListPointer{$(runtimeElementType), typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.$(elementsize(field.fieldProperties.type.elementType)), convert(UInt32, size))")
        cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
        generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
        cprintln(env, "    child_ptr")
        cprintln(env, "end")
    elseif field.fieldProperties.type.elementType isa SchemaStruct
        # TODO: maybe assert?
        slotStructProps = env.nodes[field.fieldProperties.type.elementType.typeId].nodeProperties
        cprintln(env, "function $(node.jlName)_init$(uppercasefirst(field.name))(ptr, size)")
        cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + $(node.nodeProperties.dataWordCount + field.fieldProperties.offset))")
        cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * ($(slotStructProps.dataWordCount) + $(slotStructProps.pointerCount))))")
        cprintln(env, "    child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16($(slotStructProps.dataWordCount)), UInt16($(slotStructProps.pointerCount)))")
        cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
        generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
        cprintln(env, "    child_ptr")
        cprintln(env, "end")
    else
        # throw("Non-simple or non-struct lists not implemented yet")
    end
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaStruct)
    typeNode = env.nodes[field.fieldProperties.type.typeId]
    slotStructProps = typeNode.nodeProperties

    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr::Capnp.StructPointer{T}) where T <: Reader")
    cprintln(env, "    p = Capnp.read_struct_pointer(ptr, $(node.nodeProperties.dataWordCount), $(field.fieldProperties.offset))")
    generate_struct_pointer_assert(env, typeNode.jlName, "p")
    cprintln(env, "    p")
    cprintln(env, "end")

    # cprintln(env, "function $(path_name)_set$(uppercasefirst(r.name))(ptr::Capnp.StructPointer{T}) where T <: Writer")
    # cprintln(env, "    Capnp.write_struct_pointer(ptr, $(structProps.dataWordCount * 8), $(slot.offset))")
    # cprintln(env, "end")

    cprintln(env, "function $(node.jlName)_init$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + $(node.nodeProperties.dataWordCount + field.fieldProperties.offset))")
    cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*$(slotStructProps.dataWordCount + slotStructProps.pointerCount))")
    cprintln(env, "    child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16($(slotStructProps.dataWordCount)), UInt16($(slotStructProps.pointerCount)))")
    cprintln(env, "    Capnp.write_struct_pointer(pointer_location, child_ptr)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    child_ptr")
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaText)
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    p = Capnp.read_list_pointer(ptr, $(node.nodeProperties.dataWordCount), $(Int(field.fieldProperties.offset)))")
    cprintln(env, "    Capnp.read_text(p)")
    cprintln(env, "end")

    # length +1 for terminating \0
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr, txt)")
    cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + $(node.nodeProperties.dataWordCount + field.fieldProperties.offset))")
    cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)")
    cprintln(env, "    child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))")
    cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    Capnp.write_text(child_ptr, txt)")
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaVoid)
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type)
    cprintln(env, "# $(node.jlName)'s $(field.name) has type $(type) which is not supported by Capnp.jl yet")
end

# Separate generator for bools than other "plain values" because capnp fits 8 bools into 1 byte.
function generateBoolSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps})
    @assert field.fieldProperties.type isa SchemaBool

    # reader
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    value = Capnp.read_bool(ptr, $(field.fieldProperties.offset))")
    if field.fieldProperties.defaultValue != zero(Bool)
        cprintln(env, "    value = xor(value, Bool($(field.fieldProperties.defaultValue)))")
    end
    cprintln(env, "    value")
    cprintln(env, "end")

    # writer
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr, value)")
    cprintln(env, "    Capnp.write_bool(ptr, $(field.fieldProperties.offset), value)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    # TODO: default value
    cprintln(env, "end")
end

function generateBitsSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps})
    @assert !(field.fieldProperties.type isa SchemaBool)

    position = field.fieldProperties.offset * capnp_sizeof(field.fieldProperties.type)
    juliaBitsType = capnp_type_to_bits_type(field.fieldProperties.type)

    # reader
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    value = Capnp.read_bits(ptr, $(position), $(juliaBitsType))")
    if field.fieldProperties.defaultValue != zero(juliaBitsType)
        cprintln(env, "    value = xor(value, $(juliaBitsType)($(field.fieldProperties.defaultValue)))")
    end
    cprintln(env, "    value")
    cprintln(env, "end")

    # writer
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr, value)")
    cprintln(env, "    Capnp.write_bits(ptr, $(position), $(juliaBitsType), value)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    # TODO: default value
    cprintln(env, "end")
end

function generateField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps})
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
