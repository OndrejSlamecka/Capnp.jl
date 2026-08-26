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
    @assert request.capnpVersion[1] == 1 || (request.capnpVersion[1] == 0 && request.capnpVersion[2] >= 6)

    nodes = Dict(node.id => node for node in request.nodes)

    for file in request.requestedFiles
        file_node = nodes[file.id]
        env = Environment(IOBuffer(), nodes)

        # Traverse the subtree induced by Nodes to deduce names of all types ahead of generator phase.
        assign_node_names(env, String[], file_node)

        # Generate recursively with file node at the root of the tree
        generateNode(env, file_node)

        mkpath(dirname(file.filename * ".jl")); open(file.filename * ".jl", "w") do io
            println(io, String(take!(env.buffer)))
        end
    end
end

# Persistent interface ID (from persistent.capnp)
const PERSISTENT_INTERFACE_ID_GEN = UInt64(0xc8cb212fcd9f5691)

"""
    has_persistent_annotation(env::Environment, node::Node{InterfaceNodeProps}) -> Bool

Check if an interface has the \$persistent annotation.
This indicates the interface supports persistent capabilities.
"""
function has_persistent_annotation(env::Environment, node::Node{InterfaceNodeProps})
    for annotation in node.annotations
        annotation_node = get(env.nodes, annotation.id, nothing)
        if annotation_node !== nothing
            # Check for $persistent annotation by name
            display_name = annotation_node.displayName[(annotation_node.displayNamePrefixLength+1):end]
            if display_name == "persistent" || display_name == "Persistent"
                return true
            end
        end
    end
    return false
end

# Fallback for non-interface nodes
function has_persistent_annotation(env::Environment, node::Node)
    return false
end

"""
    extends_persistent(env::Environment, node::Node{InterfaceNodeProps}) -> Bool

Check if an interface extends the Persistent interface.
"""
function extends_persistent(env::Environment, node::Node{InterfaceNodeProps})
    for superclass in node.nodeProperties.superclasses
        if superclass.id == PERSISTENT_INTERFACE_ID_GEN
            return true
        end
        # Check transitively
        super_node = get(env.nodes, superclass.id, nothing)
        if super_node !== nothing && super_node isa Node{InterfaceNodeProps}
            if extends_persistent(env, super_node)
                return true
            end
        end
    end
    return false
end

# Fallback for non-interface nodes
function extends_persistent(env::Environment, node::Node)
    return false
end

"""
    is_persistent_interface(env::Environment, node::Node{InterfaceNodeProps}) -> Bool

Check if an interface is persistent (either via annotation or by extending Persistent).
"""
function is_persistent_interface(env::Environment, node::Node{InterfaceNodeProps})
    return has_persistent_annotation(env, node) || extends_persistent(env, node)
end

# Fallback for non-interface nodes
function is_persistent_interface(env::Environment, node::Node)
    return false
end

# Finds $Cxx.namespace("capnp::schema"); and returns ["capnp", "schema"]
function namespace_annotation(env::Environment, node::Node{FileNodeProps})::Vector{String}
    namespace_annotations = Iterators.filter(node.annotations) do annotation
        annotation.id == 0xb9c6f99ebf805f2c
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
schema_to_runtime_type(::SchemaData) = Capnp.CapnpData
schema_to_runtime_type(::SchemaText) = Capnp.CapnpText
schema_to_runtime_type(::SchemaStruct) = Capnp.CapnpStruct
schema_to_runtime_type(s::SchemaList) = :(Capnp.CapnpList{$(schema_to_runtime_type(s.elementType))})
schema_to_runtime_type(::SchemaAnyPointer) = Capnp.CapnpAnyPointer
schema_to_runtime_type(::SchemaInterface) = Capnp.CapnpInterface

# Helper to convert CamelCase field name to snake_case
function to_snake_case(name::AbstractString)
    # Insert underscore before uppercase letters and lowercase them
    result = replace(name, r"([A-Z])" => s"_\1")
    # Remove leading underscore if present and lowercase
    result = lowercase(lstrip(result, '_'))
    return result
end

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
    # Namespaces come from "namespace" annotation and are translated into Julia modules
    nested_namespaces = namespace_annotation(env, node)

    # Use direct module definitions to avoid world age issues in Julia 1.12+
    # Note: This means each schema file creates its own modules. If you need to merge
    # multiple schema files into a shared namespace, include them in a wrapper module.
    for namespace in nested_namespaces
        cprintln(env, "module $namespace")
        env.indent += 1
    end

    # Generate contents
    cprintln(env, "# Generated from $(node.displayName)")
    cprintln(env, "using Capnp")

    for nested_node in node.nestedNodes
        generateNode(env, env.nodes[nested_node.id])
    end

    # Close namespaces/modules
    for i = length(nested_namespaces):-1:1
        env.indent -= 1
        cprintln(env, "end # module $(nested_namespaces[i])")
    end
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
        # New API: which(ptr) function
        cprintln(env, "function which(ptr::Capnp.StructPointer, ::Type{Val{:$(node.jlName)}})")
        cprintln(env, "    $(node.jlName)_union(Capnp.read_bits(ptr, $(sizeof(UInt16) * node.nodeProperties.discriminantOffset), UInt16))")
        cprintln(env, "end")
        # Legacy API with deprecation
        cprintln(env, "function $(node.jlName)_which(ptr::Capnp.StructPointer)")
        cprintln(env, "    Base.depwarn(\"$(node.jlName)_which is deprecated, use which(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_which)")
        cprintln(env, "    which(ptr, Val{:$(node.jlName)})")
        cprintln(env, "end")
    end

    # root
    #  reader - New API: root(message, Type)
    cprintln(env, "function root(message, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    ptr = Capnp.StructPointer(message, UInt32(1), UInt32(0), UInt16(0), UInt16(1))")
    cprintln(env, "    p = Capnp.read_struct_pointer(ptr, 0, 0)")
    generate_struct_pointer_assert(env, node.jlName, "p")
    cprintln(env, "    p")
    cprintln(env, "end")
    # Legacy API with deprecation
    cprintln(env, "function root_$(node.jlName)(message)")
    cprintln(env, "    Base.depwarn(\"root_$(node.jlName) is deprecated, use root(message, Val{:$(node.jlName)}) instead\", :root_$(node.jlName))")
    cprintln(env, "    root(message, Val{:$(node.jlName)})")
    cprintln(env, "end")

    #  writer - New API: init_root!(builder, Type)
    cprintln(env, "function init_root!(builder, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    pointer_location = Capnp.WirePointer(1, 0)")
    cprintln(env, "    Capnp.alloc(builder, pointer_location, 8)") # a word for the root pointer
    cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(builder, pointer_location, 8*$(node.nodeProperties.dataWordCount + node.nodeProperties.pointerCount))") # root struct
    cprintln(env, "    ptr = Capnp.StructPointer(builder, segment, offset, UInt16($(node.nodeProperties.dataWordCount)), UInt16($(node.nodeProperties.pointerCount)))")
    cprintln(env, "    Capnp.write_root_struct_pointer(ptr)")
    cprintln(env, "    ptr")
    cprintln(env, "end")
    # Legacy API with deprecation
    cprintln(env, "function initRoot_$(node.jlName)(builder)")
    cprintln(env, "    Base.depwarn(\"initRoot_$(node.jlName) is deprecated, use init_root!(builder, Val{:$(node.jlName)}) instead\", :initRoot_$(node.jlName))")
    cprintln(env, "    init_root!(builder, Val{:$(node.jlName)})")
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
    sorted_enumerants = sort(node.nodeProperties.enumerants, by = e -> e.codeOrder)
    enumerants_str = join(["$(node.jlName)_$(e.name)=$(findfirst(x -> x.name == e.name, node.nodeProperties.enumerants) - 1)" for e in sorted_enumerants], " ")
    cprintln(env, "@enum $(node.jlName)::UInt16 $enumerants_str")
end

# Generate code for interface nodes (RPC interfaces)
function generateNode(env::Environment, node::Node{InterfaceNodeProps})
    # nested nodes
    for nested_node in node.nestedNodes
        generateNode(env, env.nodes[nested_node.id])
    end

    # Interface ID constant (explicitly typed as UInt64 for large IDs)
    cprintln(env, "const $(node.jlName)_interface_id = UInt64(0x$(string(node.id, base=16)))")

    # Check if this is a persistent interface
    is_persistent = is_persistent_interface(env, node)

    if is_persistent
        # Abstract server type extends PersistentCapability for persistent interfaces
        cprintln(env, "# This interface supports persistent capabilities")
        cprintln(env, "abstract type $(node.jlName)_Server <: Capnp.RPC.PersistentCapability end")
    else
        # Abstract server type for implementing the interface
        cprintln(env, "abstract type $(node.jlName)_Server end")
    end

    # Client struct for calling the interface
    cprintln(env, "struct $(node.jlName)_Client")
    cprintln(env, "    cap::Any  # RemoteCapability")
    cprintln(env, "end")

    # Generate method stubs for each method
    for (idx, method) in enumerate(node.nodeProperties.methods)
        generateMethod(env, node, method, UInt16(idx - 1))
    end

    # Generate persistent capability methods if applicable (T072)
    if is_persistent
        generatePersistentMethods(env, node)
    end

    # Generate method dispatch function for server-side RPC
    cprintln(env, "\"\"\"")
    cprintln(env, "    $(node.jlName)_dispatch(impl, method_id::UInt16, context, params)")
    cprintln(env, "")
    cprintln(env, "Dispatch a method call to the appropriate handler based on method_id.")
    cprintln(env, "\"\"\"")
    cprintln(env, "function $(node.jlName)_dispatch(impl, method_id::UInt16, context, params)")
    for (idx, method) in enumerate(node.nodeProperties.methods)
        method_id_val = idx - 1
        if idx == 1
            cprintln(env, "    if method_id == $(method_id_val)")
        else
            cprintln(env, "    elseif method_id == $(method_id_val)")
        end
        cprintln(env, "        $(node.jlName)_$(method.name)(impl, context, params)")
    end
    if !isempty(node.nodeProperties.methods)
        cprintln(env, "    else")
        cprintln(env, "        error(\"Unknown method ID: \" * string(method_id))")
        cprintln(env, "    end")
    else
        cprintln(env, "    error(\"Interface has no methods\")")
    end
    cprintln(env, "end")

    # Generate dispatch_interface helper for interface dispatch
    cprintln(env, "\"\"\"")
    cprintln(env, "    $(node.jlName)_interface_dispatch(impl, interface_id::UInt64, method_id::UInt16, context, params)")
    cprintln(env, "")
    cprintln(env, "Dispatch a method call if interface_id matches, otherwise return false.")
    cprintln(env, "\"\"\"")
    cprintln(env, "function $(node.jlName)_interface_dispatch(impl, interface_id::UInt64, method_id::UInt16, context, params)")
    cprintln(env, "    if interface_id == $(node.jlName)_interface_id")
    cprintln(env, "        $(node.jlName)_dispatch(impl, method_id, context, params)")
    cprintln(env, "        return true")
    cprintln(env, "    end")
    cprintln(env, "    return false")
    cprintln(env, "end")

    cprintln(env, "")
    cprintln(env, "function Capnp.RPC.dispatch_method!(impl::$(node.jlName)_Server, interface_id::UInt64, method_id::UInt16, context::Capnp.RPC.CallContext, params)")
    cprintln(env, "    if $(node.jlName)_interface_dispatch(impl, interface_id, method_id, context, params)")
    cprintln(env, "        return")
    cprintln(env, "    end")
    for sc in node.nodeProperties.superclasses
        sc_node = env.nodes[sc.id]
        cprintln(env, "    if $(sc_node.jlName)_interface_dispatch(impl, interface_id, method_id, context, params)")
        cprintln(env, "        return")
        cprintln(env, "    end")
    end
    cprintln(env, "    Capnp.RPC.set_exception!(context, \"Method not found: interface=\$interface_id method=\$method_id\", Capnp.RPC.ExceptionType.UNIMPLEMENTED)")
    cprintln(env, "end")
end

"""
Generate save() client method and server trait for persistent interfaces (T072-T073).
"""
function generatePersistentMethods(env::Environment, node::Node{InterfaceNodeProps})
    # Client save() method - sync version
    cprintln(env, "\"\"\"")
    cprintln(env, "    $(node.jlName)_save(client::$(node.jlName)_Client) -> DefaultSturdyRef")
    cprintln(env, "")
    cprintln(env, "Save the capability and get a SturdyRef for later restoration (blocking).")
    cprintln(env, "This interface supports persistent capabilities.")
    cprintln(env, "\"\"\"")
    cprintln(env, "function $(node.jlName)_save(client::$(node.jlName)_Client)")
    cprintln(env, "    # Call Persistent.save() on the capability")
    cprintln(env, "    conn = client.cap.connection")
    cprintln(env, "    import_id = client.cap.import_id")
    cprintln(env, "    Capnp.RPC.call_save_sync(conn, import_id)")
    cprintln(env, "end")

    # Client save() method - async version
    cprintln(env, "\"\"\"")
    cprintln(env, "    $(node.jlName)_saveAsync(client::$(node.jlName)_Client) -> Promise{DefaultSturdyRef}")
    cprintln(env, "")
    cprintln(env, "Save the capability asynchronously (returns Promise).")
    cprintln(env, "\"\"\"")
    cprintln(env, "function $(node.jlName)_saveAsync(client::$(node.jlName)_Client)")
    cprintln(env, "    conn = client.cap.connection")
    cprintln(env, "    import_id = client.cap.import_id")
    cprintln(env, "    Capnp.RPC.call_save(conn, import_id)")
    cprintln(env, "end")

    # Server trait: can_save override point
    cprintln(env, "\"\"\"")
    cprintln(env, "    $(node.jlName)_can_save(impl::$(node.jlName)_Server, owner) -> Bool")
    cprintln(env, "")
    cprintln(env, "Override this method to implement access control for save operations.")
    cprintln(env, "Default implementation returns true (all owners can save).")
    cprintln(env, "\"\"\"")
    cprintln(env, "function $(node.jlName)_can_save(impl::$(node.jlName)_Server, owner)")
    cprintln(env, "    # Default: allow save for any owner")
    cprintln(env, "    return true")
    cprintln(env, "end")

    # Override Capnp.RPC.can_save for this server type
    cprintln(env, "# Hook into RPC persistence system")
    cprintln(env, "function Capnp.RPC.can_save(impl::$(node.jlName)_Server, owner)")
    cprintln(env, "    $(node.jlName)_can_save(impl, owner)")
    cprintln(env, "end")

    # Server trait: generate_object_id override point
    cprintln(env, "\"\"\"")
    cprintln(env, "    $(node.jlName)_object_id(impl::$(node.jlName)_Server) -> Vector{UInt8}")
    cprintln(env, "")
    cprintln(env, "Override this method to provide a custom object ID for persistence.")
    cprintln(env, "Default implementation uses Julia's objectid().")
    cprintln(env, "\"\"\"")
    cprintln(env, "function $(node.jlName)_object_id(impl::$(node.jlName)_Server)")
    cprintln(env, "    Vector{UInt8}(string(objectid(impl)))")
    cprintln(env, "end")
end

# Generate code for interface methods
function generateMethod(env::Environment, node::Node{InterfaceNodeProps}, method::Method, method_id::UInt16)
    method_snake = to_snake_case(method.name)

    # Get parameter and result types
    param_node = get(env.nodes, method.paramStructType, nothing)
    result_node = get(env.nodes, method.resultStructType, nothing)

    param_type = param_node !== nothing ? param_node.jlName : "Any"
    result_type = result_node !== nothing ? result_node.jlName : "Any"

    # Sync method (blocking) for client
    cprintln(env, "\"\"\"")
    cprintln(env, "    $(node.jlName)_$(method.name)(client::$(node.jlName)_Client, params) -> result")
    cprintln(env, "")
    cprintln(env, "Call $(method.name) on the remote capability (blocking).")
    cprintln(env, "\"\"\"")
    cprintln(env, "function $(node.jlName)_$(method.name)(client::$(node.jlName)_Client, params=nothing)")
    cprintln(env, "    # Sync method call - blocks until result available")
    cprintln(env, "    promise = $(node.jlName)_$(method.name)Async(client, params)")
    cprintln(env, "    fetch(promise)")
    cprintln(env, "end")

    # Async method (returns Promise) for client
    cprintln(env, "\"\"\"")
    cprintln(env, "    $(node.jlName)_$(method.name)Async(client::$(node.jlName)_Client, params_builder=nothing) -> Promise")
    cprintln(env, "")
    cprintln(env, "Call $(method.name) on the remote capability (async, returns Promise).")
    cprintln(env, "\"\"\"")
    cprintln(env, "function $(node.jlName)_$(method.name)Async(client::$(node.jlName)_Client, params_builder=nothing)")
    cprintln(env, "    Capnp.RPC.call(client.cap, 0x$(string(node.id, base=16)), UInt16($(method_id));")
    if param_node !== nothing
        cprintln(env, "                   data_word_count=UInt16($(param_node.nodeProperties.dataWordCount)),")
        cprintln(env, "                   pointer_count=UInt16($(param_node.nodeProperties.pointerCount)),")
    else
        cprintln(env, "                   data_word_count=UInt16(0), pointer_count=UInt16(0),")
    end
    cprintln(env, "                   params_builder=params_builder !== nothing ? params_builder : (p,l)->nothing)")
    cprintln(env, "end")

    # Pipelined method call (on Promise)
    cprintln(env, "function $(node.jlName)_$(method.name)(client_promise::Promise, params_builder=nothing)")
    cprintln(env, "    Capnp.RPC.call(client_promise, 0x$(string(node.id, base=16)), UInt16($(method_id));")
    if param_node !== nothing
        cprintln(env, "                   data_word_count=UInt16($(param_node.nodeProperties.dataWordCount)),")
        cprintln(env, "                   pointer_count=UInt16($(param_node.nodeProperties.pointerCount)),")
    else
        cprintln(env, "                   data_word_count=UInt16(0), pointer_count=UInt16(0),")
    end
    cprintln(env, "                   params_builder=params_builder !== nothing ? params_builder : (p,l)->nothing)")
    cprintln(env, "end")

    # Server method signature (to be implemented)
    cprintln(env, "\"\"\"")
    cprintln(env, "    $(node.jlName)_$(method.name)(impl::$(node.jlName)_Server, context, params)")
    cprintln(env, "")
    cprintln(env, "Server-side implementation of $(method.name). Override this method in your implementation type.")
    cprintln(env, "\"\"\"")
    cprintln(env, "function $(node.jlName)_$(method.name)(impl::$(node.jlName)_Server, context, params)")
    cprintln(env, "    error(\"Method $(method.name) not implemented for \" * string(typeof(impl)))")
    cprintln(env, "end")
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

    field_snake = to_snake_case(field.name)

    # New API: get_fieldname(ptr) for groups
    cprintln(env, "function get_$(field_snake)(ptr::Capnp.StructPointer, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    ptr")
    cprintln(env, "end")
    # Legacy API with deprecation
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr::Capnp.StructPointer)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    # New API: init_fieldname!(ptr) for groups
    cprintln(env, "function init_$(field_snake)!(ptr, ::Type{Val{:$(node.jlName)}})")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    ptr")
    cprintln(env, "end")
    # Legacy API with deprecation
    cprintln(env, "function $(node.jlName)_init$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_init$(uppercasefirst(field.name)) is deprecated, use init_$(field_snake)!(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_init$(uppercasefirst(field.name)))")
    cprintln(env, "    init_$(field_snake)!(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    generateNode(env, group_struct)
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaEnum)
    enum = env.nodes[type.typeId]
    position = field.fieldProperties.offset * sizeof(UInt16) # "Enums are encoded the same as UInt16."
    field_snake = to_snake_case(field.name)

    # New API: reader
    cprintln(env, "function get_$(field_snake)(ptr, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    value = Capnp.read_bits(ptr, $(position), $(enum.jlName))")
    cprintln(env, "    value")
    cprintln(env, "end")
    # Legacy API with deprecation
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    # New API: writer
    cprintln(env, "function set_$(field_snake)!(ptr, value, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    Capnp.write_bits(ptr, $(position), $(enum.jlName), value)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "end")
    # Legacy API with deprecation
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr, value)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_set$(uppercasefirst(field.name)) is deprecated, use set_$(field_snake)!(ptr, value, Val{:$(node.jlName)}) instead\", :$(node.jlName)_set$(uppercasefirst(field.name)))")
    cprintln(env, "    set_$(field_snake)!(ptr, value, Val{:$(node.jlName)})")
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaUnconstrainedPointer)
    field_snake = to_snake_case(field.name)

    # New API
    cprintln(env, "function get_$(field_snake)(ptr, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    Capnp.read_any_pointer(ptr, ptr.data_word_count, $(Int(field.fieldProperties.offset)))")
    cprintln(env, "end")
    # Legacy API with deprecation
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaList)
    elementType = field.fieldProperties.type.elementType
    runtimeElementType = schema_to_runtime_type(field.fieldProperties.type.elementType)
    field_snake = to_snake_case(field.name)

    # New API: getter for Nothing
    cprintln(env, "function get_$(field_snake)(ptr::Nothing, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    []")
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr::Nothing)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    # New API: getter
    cprintln(env, "function get_$(field_snake)(ptr, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    p = Capnp.read_list_pointer(ptr, ptr.data_word_count, $(Int(field.fieldProperties.offset)), $(runtimeElementType))")
    if elementType isa SchemaStruct
        strct = env.nodes[elementType.typeId]
        # Use >= for schema evolution compatibility (newer schemas may add fields)
        cprintln(env, "    Capnp.validate_struct_list_pointer(p, $(strct.jlName)_data_word_count, $(strct.jlName)_pointer_count, \"$(strct.jlName)\")")
    end
    cprintln(env, "    p")
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    if field.fieldProperties.type.elementType isa SchemaBool
        throw("Lists of bools not supported yet.")
    elseif is_capnp_bits(field.fieldProperties.type.elementType)
        # New API: init
        cprintln(env, "function init_$(field_snake)!(ptr, size, ::Type{Val{:$(node.jlName)}})")
        cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + $(field.fieldProperties.offset))")
        cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, $(capnp_sizeof(field.fieldProperties.type.elementType)) * size)")
        cprintln(env, "    child_ptr = Capnp.SimpleListPointer{$(runtimeElementType), typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.$(elementsize(field.fieldProperties.type.elementType)), convert(UInt32, size))")
        cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
        generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
        cprintln(env, "    child_ptr")
        cprintln(env, "end")
        # Legacy API
        cprintln(env, "function $(node.jlName)_init$(uppercasefirst(field.name))(ptr, size)")
        cprintln(env, "    Base.depwarn(\"$(node.jlName)_init$(uppercasefirst(field.name)) is deprecated, use init_$(field_snake)!(ptr, size, Val{:$(node.jlName)}) instead\", :$(node.jlName)_init$(uppercasefirst(field.name)))")
        cprintln(env, "    init_$(field_snake)!(ptr, size, Val{:$(node.jlName)})")
        cprintln(env, "end")
    elseif field.fieldProperties.type.elementType isa SchemaStruct
        slotStructProps = env.nodes[field.fieldProperties.type.elementType.typeId].nodeProperties
        # New API: init
        cprintln(env, "function init_$(field_snake)!(ptr, size, ::Type{Val{:$(node.jlName)}})")
        cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + $(field.fieldProperties.offset))")
        cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*(1 + size * ($(slotStructProps.dataWordCount) + $(slotStructProps.pointerCount))))")
        cprintln(env, "    child_ptr = Capnp.CompositeListPointer(ptr.traverser, segment, offset, convert(UInt32, size), UInt16($(slotStructProps.dataWordCount)), UInt16($(slotStructProps.pointerCount)))")
        cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
        generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
        cprintln(env, "    child_ptr")
        cprintln(env, "end")
        # Legacy API
        cprintln(env, "function $(node.jlName)_init$(uppercasefirst(field.name))(ptr, size)")
        cprintln(env, "    Base.depwarn(\"$(node.jlName)_init$(uppercasefirst(field.name)) is deprecated, use init_$(field_snake)!(ptr, size, Val{:$(node.jlName)}) instead\", :$(node.jlName)_init$(uppercasefirst(field.name)))")
        cprintln(env, "    init_$(field_snake)!(ptr, size, Val{:$(node.jlName)})")
        cprintln(env, "end")
    elseif field.fieldProperties.type.elementType isa Union{SchemaText, SchemaData, SchemaList, SchemaAnyPointer, SchemaInterface}
        # New API: init
        cprintln(env, "function init_$(field_snake)!(ptr, size, ::Type{Val{:$(node.jlName)}})")
        cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + $(field.fieldProperties.offset))")
        cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8 * size)")
        cprintln(env, "    child_ptr = Capnp.SimpleListPointer{$(runtimeElementType), typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Pointer, convert(UInt32, size))")
        cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
        generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
        cprintln(env, "    child_ptr")
        cprintln(env, "end")
        # Legacy API
        cprintln(env, "function $(node.jlName)_init$(uppercasefirst(field.name))(ptr, size)")
        cprintln(env, "    Base.depwarn(\"$(node.jlName)_init$(uppercasefirst(field.name)) is deprecated, use init_$(field_snake)!(ptr, size, Val{:$(node.jlName)}) instead\", :$(node.jlName)_init$(uppercasefirst(field.name)))")
        cprintln(env, "    init_$(field_snake)!(ptr, size, Val{:$(node.jlName)})")
        cprintln(env, "end")
    else
        # throw("Non-simple or non-struct lists not implemented yet")
    end
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaStruct)
    typeNode = env.nodes[field.fieldProperties.type.typeId]
    slotStructProps = typeNode.nodeProperties
    field_snake = to_snake_case(field.name)

    # New API: getter
    cprintln(env, "function get_$(field_snake)(ptr::Capnp.StructPointer{T}, ::Type{Val{:$(node.jlName)}}) where T <: Reader")
    cprintln(env, "    p = Capnp.read_struct_pointer(ptr, ptr.data_word_count, $(field.fieldProperties.offset))")
    generate_struct_pointer_assert(env, typeNode.jlName, "p")
    cprintln(env, "    p")
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr::Capnp.StructPointer{T}) where T <: Reader")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    # Pipelined getter (returns a pipelined Promise for the struct)
    cprintln(env, "function get_$(field_snake)(promise::Capnp.RPC.Promise, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16($(field.fieldProperties.offset)))])")
    cprintln(env, "end")

    # New API: init
    cprintln(env, "function init_$(field_snake)!(ptr, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + $(field.fieldProperties.offset))")
    cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, 8*$(slotStructProps.dataWordCount + slotStructProps.pointerCount))")
    cprintln(env, "    child_ptr = Capnp.StructPointer(ptr.traverser, segment, offset, UInt16($(slotStructProps.dataWordCount)), UInt16($(slotStructProps.pointerCount)))")
    cprintln(env, "    Capnp.write_struct_pointer(pointer_location, child_ptr)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    child_ptr")
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_init$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_init$(uppercasefirst(field.name)) is deprecated, use init_$(field_snake)!(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_init$(uppercasefirst(field.name)))")
    cprintln(env, "    init_$(field_snake)!(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaText)
    field_snake = to_snake_case(field.name)

    # New API: getter
    cprintln(env, "function get_$(field_snake)(ptr, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    p = Capnp.read_list_pointer(ptr, ptr.data_word_count, $(Int(field.fieldProperties.offset)))")
    cprintln(env, "    Capnp.read_text(p)")
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    # New API: setter
    cprintln(env, "function set_$(field_snake)!(ptr, txt, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + $(field.fieldProperties.offset))")
    cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(txt) + 1)")
    cprintln(env, "    child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(txt) + 1))")
    cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    Capnp.write_text(child_ptr, txt)")
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr, txt)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_set$(uppercasefirst(field.name)) is deprecated, use set_$(field_snake)!(ptr, txt, Val{:$(node.jlName)}) instead\", :$(node.jlName)_set$(uppercasefirst(field.name)))")
    cprintln(env, "    set_$(field_snake)!(ptr, txt, Val{:$(node.jlName)})")
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaData)
    field_snake = to_snake_case(field.name)
    pointer_index = Int(field.fieldProperties.offset)

    cprintln(env, "function get_$(field_snake)(ptr, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    p = Capnp.read_list_pointer(ptr, ptr.data_word_count, $(pointer_index))")
    cprintln(env, "    Capnp.read_data(p)")
    cprintln(env, "end")
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    cprintln(env, "function set_$(field_snake)!(ptr, data::AbstractVector{UInt8}, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + $(pointer_index))")
    cprintln(env, "    pointer_location, segment, offset = Capnp.alloc(ptr.traverser, pointer_location, length(data))")
    cprintln(env, "    child_ptr = Capnp.SimpleListPointer{UInt8, typeof(ptr.traverser)}(ptr.traverser, segment, offset, Capnp.Byte, UInt32(length(data)))")
    cprintln(env, "    Capnp.write_list_pointer(pointer_location, child_ptr)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "    Capnp.write_data(child_ptr, data)")
    cprintln(env, "end")
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr, data::AbstractVector{UInt8})")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_set$(uppercasefirst(field.name)) is deprecated, use set_$(field_snake)!(ptr, data, Val{:$(node.jlName)}) instead\", :$(node.jlName)_set$(uppercasefirst(field.name)))")
    cprintln(env, "    set_$(field_snake)!(ptr, data, Val{:$(node.jlName)})")
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaInterface)
    field_snake = to_snake_case(field.name)
    typeNode = env.nodes[type.typeId]

    # New API: getter
    cprintln(env, "function get_$(field_snake)(ptr, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    cap_ptr = Capnp.read_capability_pointer(ptr, ptr.data_word_count, $(field.fieldProperties.offset))")
    cprintln(env, "    if cap_ptr !== nothing && cap_ptr.cap_index < length(ptr.traverser.capabilities)")
    cprintln(env, "        cap = ptr.traverser.capabilities[cap_ptr.cap_index + 1]")
    cprintln(env, "        return $(typeNode.jlName)_Client(cap)")
    cprintln(env, "    end")
    cprintln(env, "    nothing")
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    # Pipelined getter (returns a Client wrapper around a pipelined Promise)
    cprintln(env, "function get_$(field_snake)(promise::Capnp.RPC.Promise, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    pipelined = Capnp.RPC.call_pipelined(promise, [Capnp.RPC.PipelineOp(Capnp.RPC.PipelineOpKind.GET_POINTER_FIELD, UInt16($(field.fieldProperties.offset)))])")
    cprintln(env, "    return $(typeNode.jlName)_Client(pipelined)")
    cprintln(env, "end")

    # New API: setter
    cprintln(env, "function set_$(field_snake)!(ptr, client, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    idx = Capnp.RPC.add_capability_to_message!(ptr.traverser, client)")
    cprintln(env, "    pointer_location = Capnp.WirePointer(ptr.segment, ptr.offset + ptr.data_word_count + $(field.fieldProperties.offset))")
    cprintln(env, "    Capnp.write_capability_pointer(pointer_location, ptr.traverser, idx)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr, client)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_set$(uppercasefirst(field.name)) is deprecated, use set_$(field_snake)!(ptr, client, Val{:$(node.jlName)}) instead\", :$(node.jlName)_set$(uppercasefirst(field.name)))")
    cprintln(env, "    set_$(field_snake)!(ptr, client, Val{:$(node.jlName)})")
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type::SchemaVoid)
    field_snake = to_snake_case(field.name)

    # New API: setter (void fields only have setter for discriminant)
    cprintln(env, "function set_$(field_snake)!(ptr, ::Type{Val{:$(node.jlName)}})")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_set$(uppercasefirst(field.name)) is deprecated, use set_$(field_snake)!(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_set$(uppercasefirst(field.name)))")
    cprintln(env, "    set_$(field_snake)!(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")
end

function generateSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps}, type)
    cprintln(env, "# $(node.jlName)'s $(field.name) has type $(type) which is not supported by Capnp.jl yet")
end

# Separate generator for bools than other "plain values" because capnp fits 8 bools into 1 byte.
function generateBoolSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps})
    @assert field.fieldProperties.type isa SchemaBool
    field_snake = to_snake_case(field.name)

    # New API: reader
    cprintln(env, "function get_$(field_snake)(ptr, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    value = Capnp.read_bool(ptr, $(field.fieldProperties.offset))")
    if field.fieldProperties.defaultValue != zero(Bool)
        cprintln(env, "    value = xor(value, Bool($(field.fieldProperties.defaultValue)))")
    end
    cprintln(env, "    value")
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    # New API: writer
    cprintln(env, "function set_$(field_snake)!(ptr, value, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    Capnp.write_bool(ptr, $(field.fieldProperties.offset), value)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr, value)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_set$(uppercasefirst(field.name)) is deprecated, use set_$(field_snake)!(ptr, value, Val{:$(node.jlName)}) instead\", :$(node.jlName)_set$(uppercasefirst(field.name)))")
    cprintln(env, "    set_$(field_snake)!(ptr, value, Val{:$(node.jlName)})")
    cprintln(env, "end")
end

function generateBitsSlotField(env, node::Node{StructNodeProps}, field::Field{SlotFieldProps})
    @assert !(field.fieldProperties.type isa SchemaBool)

    position = field.fieldProperties.offset * capnp_sizeof(field.fieldProperties.type)
    juliaBitsType = capnp_type_to_bits_type(field.fieldProperties.type)
    field_snake = to_snake_case(field.name)

    # New API: reader
    cprintln(env, "function get_$(field_snake)(ptr, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    value = Capnp.read_bits(ptr, $(position), $(juliaBitsType))")
    if field.fieldProperties.defaultValue != zero(juliaBitsType)
        cprintln(env, "    value = xor(value, $(juliaBitsType)($(field.fieldProperties.defaultValue)))")
    end
    cprintln(env, "    value")
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_get$(uppercasefirst(field.name))(ptr)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_get$(uppercasefirst(field.name)) is deprecated, use get_$(field_snake)(ptr, Val{:$(node.jlName)}) instead\", :$(node.jlName)_get$(uppercasefirst(field.name)))")
    cprintln(env, "    get_$(field_snake)(ptr, Val{:$(node.jlName)})")
    cprintln(env, "end")

    # New API: writer
    cprintln(env, "function set_$(field_snake)!(ptr, value, ::Type{Val{:$(node.jlName)}})")
    cprintln(env, "    Capnp.write_bits(ptr, $(position), $(juliaBitsType), value)")
    generateDiscriminantSetter(env, "ptr", node.nodeProperties, field)
    cprintln(env, "end")
    # Legacy API
    cprintln(env, "function $(node.jlName)_set$(uppercasefirst(field.name))(ptr, value)")
    cprintln(env, "    Base.depwarn(\"$(node.jlName)_set$(uppercasefirst(field.name)) is deprecated, use set_$(field_snake)!(ptr, value, Val{:$(node.jlName)}) instead\", :$(node.jlName)_set$(uppercasefirst(field.name)))")
    cprintln(env, "    set_$(field_snake)!(ptr, value, Val{:$(node.jlName)})")
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
    # Use >= for schema evolution compatibility (newer schemas may add fields)
    cprintln(env, "    Capnp.validate_struct_pointer($varname, $(jlName)_data_word_count, $(jlName)_pointer_count, \"$(jlName)\")")
end
