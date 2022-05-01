# This file defines types of the Capnp schema tree structure and functions for parsing a provided schema into that tree.
# The root is CodeGeneratorRequest and the corresponding function is read_CodeGeneratorRequest.

const noDiscriminant = 0xff_ff::UInt16

# Types as parsed from the given schema.
abstract type SchemaType end

@enum Inherit inherit
const Binding = Union{Nothing,SchemaType}
struct Scope
    scopeId::UInt64
    scope::Union{Vector{Binding},Inherit}
end
struct Brand
    scopes::Vector{Scope}
end

struct SchemaVoid <: SchemaType end
struct SchemaBool <: SchemaType end
struct SchemaInt8 <: SchemaType end
struct SchemaInt16 <: SchemaType end
struct SchemaInt32 <: SchemaType end
struct SchemaInt64 <: SchemaType end
struct SchemaUInt8 <: SchemaType end
struct SchemaUInt16 <: SchemaType end
struct SchemaUInt32 <: SchemaType end
struct SchemaUInt64 <: SchemaType end
struct SchemaFloat32 <: SchemaType end
struct SchemaFloat64 <: SchemaType end
struct SchemaText <: SchemaType end
struct SchemaData <: SchemaType end
struct SchemaList <: SchemaType
    # TODO maybe elementType could be a parameter of SchemaTypeList?
    elementType::SchemaType
end
struct SchemaEnum <: SchemaType
    typeId::UInt64
    brand::Brand
end
struct SchemaStruct <: SchemaType
    typeId::UInt64
    brand::Brand
end
struct SchemaInterface <: SchemaType
    typeId::UInt64
    brand::Brand
end
struct SchemaAnyPointer <: SchemaType
    # TODO
end

struct SchemaUnconstrainedPointer <: SchemaType
    type::Any # capnp.schema.Type_anyPointer_unconstrained_union
end

struct SchemaParameterPointer <: SchemaType
    scopeId::UInt64
    parameterIndex::UInt16
end

struct SchemaImplicitMethodParameterPointer <: SchemaType
    parameterIndex::UInt16
end

elementsize(::SchemaVoid) = Capnp.Empty
elementsize(::SchemaBool) = Capnp.Bit
elementsize(::SchemaInt8) = Capnp.Byte
elementsize(::SchemaInt16) = Capnp.TwoBytes
elementsize(::SchemaInt32) = Capnp.FourBytes
elementsize(::SchemaInt64) = Capnp.EightBytes
elementsize(::SchemaUInt8) = Capnp.Byte
elementsize(::SchemaUInt16) = Capnp.TwoBytes
elementsize(::SchemaUInt32) = Capnp.FourBytes
elementsize(::SchemaUInt64) = Capnp.EightBytes
elementsize(::SchemaFloat32) = Capnp.FourBytes
elementsize(::SchemaFloat64) = Capnp.EightBytes

# capnp_sizeof returns the number of bytes a capnp type takes.
# Bool variant is intentionally not defined. Bools get separate treatment because capnp fits 8 bools into a byte.

# capnp_sizeof(::SchemaTypeBool)
capnp_sizeof(::SchemaInt8) = 1
capnp_sizeof(::SchemaInt16) = 2
capnp_sizeof(::SchemaInt32) = 4
capnp_sizeof(::SchemaInt64) = 8
capnp_sizeof(::SchemaUInt8) = 1
capnp_sizeof(::SchemaUInt16) = 2
capnp_sizeof(::SchemaUInt32) = 4
capnp_sizeof(::SchemaUInt64) = 8
capnp_sizeof(::SchemaFloat32) = 4
capnp_sizeof(::SchemaFloat64) = 8

# capnp_type_to_bits_type(::SchemaTypeBool) = Bool see capnp_sizeof
capnp_type_to_bits_type(::SchemaInt8) = UInt8
capnp_type_to_bits_type(::SchemaInt16) = UInt16
capnp_type_to_bits_type(::SchemaInt32) = UInt32
capnp_type_to_bits_type(::SchemaInt64) = UInt64
capnp_type_to_bits_type(::SchemaUInt8) = UInt8
capnp_type_to_bits_type(::SchemaUInt16) = UInt16
capnp_type_to_bits_type(::SchemaUInt32) = UInt32
capnp_type_to_bits_type(::SchemaUInt64) = UInt64
capnp_type_to_bits_type(::SchemaFloat32) = Float32
capnp_type_to_bits_type(::SchemaFloat64) = Float64
capnp_type_to_bits_type(::Any) = nothing

is_capnp_bits(type) = capnp_type_to_bits_type(type) !== nothing


const Value = Any # TODO: consider whether it's worth making this more precise

struct Annotation
    id::UInt64
    brand::Union{Nothing,Brand}
    value::Value
end

struct NestedNode
    id::UInt64
    name::String
end

struct Parameter
    name::String
end

abstract type FieldProperties end

struct SlotFieldProps <: FieldProperties
    offset::UInt32
    type::SchemaType
    defaultValue::Value
    hadExplicitDefault::Bool
end

struct GroupFieldProps <: FieldProperties
    typeId::UInt64
end

struct Field{T<:FieldProperties}
    name::String
    codeOrder::UInt16
    annotations::Vector{Annotation}
    discriminantValue::UInt16
    fieldProperties::T
    ordinal::Union{Nothing,UInt16} # implicit, explicit
end

abstract type NodeProperties end

mutable struct Node{T<:NodeProperties}
    id::UInt64
    displayName::String
    displayNamePrefixLength::UInt32
    scopeId::UInt64
    parameters::Vector{Parameter}
    isGeneric::Bool
    nestedNodes::Vector{NestedNode}
    annotations::Vector{Annotation}
    nodeProperties::T

    # fields added for code generator
    jlName::String
end

struct FileNodeProps <: NodeProperties end

struct AnnotationNodeProps <: NodeProperties
    type::SchemaType
    targetsFile::Bool
    targetsConst::Bool
    targetsEnum::Bool
    targetsEnumerant::Bool
    targetsStruct::Bool
    targetsField::Bool
    targetsUnion::Bool
    targetsGroup::Bool
    targetsInterface::Bool
    targetsMethod::Bool
    targetsParam::Bool
    targetsAnnotation::Bool
end

struct Enumerant
    name::String
    codeOrder::UInt16
    annotations::Vector{Annotation}
end

struct EnumNodeProps <: NodeProperties
    enumerants::Vector{Enumerant}
end

struct ConstNodeProps <: NodeProperties
    type::SchemaType
    value::Value
end

struct StructNodeProps <: NodeProperties
    dataWordCount::UInt16
    pointerCount::UInt16
    preferredListEncoding::capnp.schema.ElementSize
    isGroup::Bool
    discriminantCount::UInt16
    discriminantOffset::UInt32
    fields::Vector{Field}
end

struct Import
    id::UInt64
    name::String
end
struct RequestedFile
    id::UInt64
    filename::String
    imports::Vector{Import}
end
struct CodeGeneratorRequest
    nodes::Vector{Node}
    requestedFiles::Vector{RequestedFile}
    capnpVersion::Tuple{UInt32,UInt16,UInt16}
    sourceInfo::Any # Might avoid implementing this
end

# Handcrafted reader
function read_CapnpVersion(ptr::Capnp.StructPointer)
    (capnp.schema.CapnpVersion_getMajor(ptr), capnp.schema.CapnpVersion_getMinor(ptr), capnp.schema.CapnpVersion_getMicro(ptr))
end

function read_RequestedFile(ptr::Capnp.StructPointer)
    id = capnp.schema.CodeGeneratorRequest_RequestedFile_getId(ptr)
    filename = capnp.schema.CodeGeneratorRequest_RequestedFile_getFilename(ptr)
    imports = [read_CodeGeneratorRequest_RequestedFile_Import(p) for p in capnp.schema.CodeGeneratorRequest_RequestedFile_getImports(ptr)]
    RequestedFile(id, filename, imports)
end

function read_CodeGeneratorRequest_RequestedFile_Import(ptr::Capnp.StructPointer)
    id = capnp.schema.CodeGeneratorRequest_RequestedFile_Import_getId(ptr)
    name = capnp.schema.CodeGeneratorRequest_RequestedFile_Import_getName(ptr)
    Import(id, name)
end

function read_Parameter(ptr::Capnp.StructPointer)
    name = capnp.schema.Parameter_getName(ptr)
    Parameter(name)
end

function read_NestedNode(ptr::Capnp.StructPointer)
    id = capnp.schema.Node_NestedNode_getId(ptr)
    name = capnp.schema.Node_NestedNode_getName(ptr)
    NestedNode(id, name)
end

function read_Type(ptr::Capnp.StructPointer)
    unionTag = capnp.schema.Type_which(ptr)

    result = nothing
    if unionTag == capnp.schema.Type_union_void
        result = SchemaVoid()
    elseif unionTag == capnp.schema.Type_union_bool
        result = SchemaBool()
    elseif unionTag == capnp.schema.Type_union_int8
        result = SchemaInt8()
    elseif unionTag == capnp.schema.Type_union_int16
        result = SchemaInt16()
    elseif unionTag == capnp.schema.Type_union_int32
        result = SchemaInt32()
    elseif unionTag == capnp.schema.Type_union_int64
        result = SchemaInt64()
    elseif unionTag == capnp.schema.Type_union_uint8
        result = SchemaUInt8()
    elseif unionTag == capnp.schema.Type_union_uint16
        result = SchemaUInt16()
    elseif unionTag == capnp.schema.Type_union_uint32
        result = SchemaUInt32()
    elseif unionTag == capnp.schema.Type_union_uint64
        result = SchemaUInt64()
    elseif unionTag == capnp.schema.Type_union_float32
        result = SchemaFloat32()
    elseif unionTag == capnp.schema.Type_union_float64
        result = SchemaFloat64()
    elseif unionTag == capnp.schema.Type_union_text
        result = SchemaText()
    elseif unionTag == capnp.schema.Type_union_data
        result = SchemaData()
    elseif unionTag == capnp.schema.Type_union_list
        elementType = read_Type(capnp.schema.Type_list_getElementType(ptr))
        result = SchemaList(elementType)
    elseif unionTag == capnp.schema.Type_union_enum
        typeId = capnp.schema.Type_enum_getTypeId(ptr)
        brand = read_Brand(capnp.schema.Type_enum_getBrand(ptr))

        result = SchemaEnum(typeId, brand)
    elseif unionTag == capnp.schema.Type_union_struct
        typeId = capnp.schema.Type_struct_getTypeId(ptr)
        brand = read_Brand(capnp.schema.Type_struct_getBrand(ptr))

        result = SchemaStruct(typeId, brand)
    elseif unionTag == capnp.schema.Type_union_anyPointer
        pointerUnionTag = capnp.schema.Type_anyPointer_which(ptr)

        if pointerUnionTag == capnp.schema.Type_anyPointer_union_unconstrained
            unconstrainedPointerUnionTag = capnp.schema.Type_anyPointer_unconstrained_which(ptr)
            result = SchemaUnconstrainedPointer(unconstrainedPointerUnionTag)
        elseif pointerUnionTag == capnp.schema.Type_anyPointer_union_parameter
            scopeId = capnp.schema.Type_anyPointer_parameter_scopeId(ptr)
            parameterIndex = capnp.schema.Type_anyPointer_Parameter_getParameterIndex(ptr)
            result = SchemaParameterPointer(scopeId, parameterIndex)
        elseif pointerUnionTag == capnp.schema.Type_anyPointer_union_implicitMethodParameter
            parameterIndex = capnp.schema.Type_anyPointer_ImplciitMethodParameter_getParameterIndex(ptr)
            result = SchemaImplicitMethodParameterPointer(parameterIndex)
        end
    end

    result
end

function read_Value(ptr::Capnp.StructPointer)
    tag = capnp.schema.Value_which(ptr)

    result = nothing
    if tag == capnp.schema.Value_union_void
        result = nothing
    elseif tag == capnp.schema.Value_union_bool
        result = capnp.schema.Value_getBool(ptr)
    elseif tag == capnp.schema.Value_union_int8
        result = capnp.schema.Value_getInt8(ptr)
    elseif tag == capnp.schema.Value_union_int16
        result = capnp.schema.Value_getInt16(ptr)
    elseif tag == capnp.schema.Value_union_int32
        result = capnp.schema.Value_getInt32(ptr)
    elseif tag == capnp.schema.Value_union_int64
        result = capnp.schema.Value_getInt64(ptr)
    elseif tag == capnp.schema.Value_union_uint8
        result = capnp.schema.Value_getUint8(ptr)
    elseif tag == capnp.schema.Value_union_uint16
        result = capnp.schema.Value_getUint16(ptr)
    elseif tag == capnp.schema.Value_union_uint32
        result = capnp.schema.Value_getUint32(ptr)
    elseif tag == capnp.schema.Value_union_uint64
        result = capnp.schema.Value_getUint64(ptr)
    elseif tag == capnp.schema.Value_union_float32
        result = capnp.schema.Value_getFloat32(ptr)
    elseif tag == capnp.schema.Value_union_float64
        result = capnp.schema.Value_getFloat64(ptr)
    elseif tag == capnp.schema.Value_union_text
        result = capnp.schema.Value_getText(ptr)
    elseif tag == capnp.schema.Value_union_data
        p = Capnp.read_list_pointer(ptr, 2, 0)
        if p isa Capnp.ListPointer && !isempty(p)
            throw("TODO")
        else
            []
        end
    elseif tag == capnp.schema.Value_union_list
        p = capnp.schema.Value_getList(ptr)
        if p isa Capnp.ListPointer && !isempty(p)
            throw("TODO")
        else
            []
        end
    elseif tag == capnp.schema.Value_union_enum
        result = capnp.schema.Value_getEnum(ptr)
    elseif tag == capnp.schema.Value_union_struct
        p = Capnp.read_struct_pointer(ptr, 2, 0)
        if p isa Capnp.StructPointer
            throw("TODO")
        else
            []
        end
    elseif tag == capnp.schema.Value_union_interface
        result = nothing
    elseif tag == capnp.schema.Value_union_anyPointer
        ptr = Capnp.read_struct_pointer(ptr, 2, 0)
        if ptr === nothing
            result = []
        else
            throw("TODO")
        end
    end

    result
end

function read_Brand_Binding(ptr::Capnp.StructPointer)
    tag = capnp.schema.Brand_Binding_which(ptr)

    if tag == capnp.schema.Brand_Binding_union_unbound
        Binding(nothing)
    elseif tag == capnp.schema.Brand_Binding_union_type
        capnpType = read_Type(capnp.schema.Brand_Binding_getType(ptr))
        Binding(capnpType)
    else
        throw("Invalid union tag in Binding")
    end
end

function read_Brand_Scope(ptr::Capnp.StructPointer)
    scopeId = capnp.schema.Brand_Scope_scopeId(ptr)
    tag = capnp.schema.Brand_Scope_which(ptr)

    if tag == capnp.schema.Brand_Scope_union_bind
        bind = [read_Brand_Binding(p) for p in capnp.schema.Brand_Scope_bind(ptr)]
        Scope(scopeId, bind)
    elseif tag == capnp.schema.Brand_Scope_union_inherit
        Scope(scopeId, nothing)
    end
end

function read_Brand(ptr)
    scopes = [read_Brand_Scope(p) for p in capnp.schema.Brand_getScopes(ptr)]
    Brand(scopes)
end

function read_Annotation(ptr::Capnp.StructPointer)
    id = capnp.schema.Annotation_getId(ptr)
    value = read_Value(capnp.schema.Annotation_getValue(ptr))
    brand = read_Brand(capnp.schema.Annotation_getBrand(ptr))

    Annotation(id, brand, value)
end

function read_Enumerant(ptr::Capnp.StructPointer)
    name = capnp.schema.Enumerant_getName(ptr)
    codeOrder = capnp.schema.Enumerant_getCodeOrder(ptr)
    annotations = [read_Annotation(p) for p in capnp.schema.Enumerant_getAnnotations(ptr)]
    Enumerant(name, codeOrder, annotations)
end

function read_Field(ptr::Capnp.StructPointer)
    name = capnp.schema.Field_getName(ptr)
    codeOrder = capnp.schema.Field_getCodeOrder(ptr)
    annotations = Annotation[read_Annotation(p) for p in capnp.schema.Field_getAnnotations(ptr)]
    discriminantValue = capnp.schema.Field_getDiscriminantValue(ptr)

    unionTag = capnp.schema.Field_which(ptr)
    fieldProps = nothing
    if unionTag == capnp.schema.Field_union_slot
        offset = capnp.schema.Field_slot_getOffset(ptr)
        type = read_Type(capnp.schema.Field_slot_getType(ptr))
        defaultValue = read_Value(capnp.schema.Field_slot_getDefaultValue(ptr))
        hadExplicitDefault = capnp.schema.Field_slot_getHadExplicitDefault(ptr)

        fieldProps = SlotFieldProps(offset, type, defaultValue, hadExplicitDefault)
    elseif unionTag == capnp.schema.Field_union_group
        typeId = capnp.schema.Field_group_getTypeId(ptr)
        fieldProps = GroupFieldProps(typeId)
    end

    unionTag = capnp.schema.Field_ordinal_which(ptr)
    ordinal = nothing
    if unionTag == capnp.schema.Field_ordinal_union_implicit
        ordinal = nothing
    elseif unionTag == capnp.schema.Field_ordinal_union_explicit
        ordinal = capnp.schema.Field_ordinal_getExplicit(ptr)
    end

    Field(name, codeOrder, annotations, discriminantValue, fieldProps, ordinal)
end

function read_Node(ptr::Capnp.StructPointer)
    id = capnp.schema.Node_getId(ptr)
    displayName = capnp.schema.Node_getDisplayName(ptr)
    displayNamePrefixLength = capnp.schema.Node_getDisplayNamePrefixLength(ptr)
    scopeId = capnp.schema.Node_getScopeId(ptr)
    parameters = Parameter[Parameter(read_Parameter(p)) for p in capnp.schema.Node_getParameters(ptr)]
    isGeneric = capnp.schema.Node_getIsGeneric(ptr)
    nestedNodes = NestedNode[read_NestedNode(p) for p in capnp.schema.Node_getNestedNodes(ptr)]
    annotations = Annotation[read_Annotation(p) for p in capnp.schema.Node_getAnnotations(ptr)]

    unionTag = capnp.schema.Node_which(ptr)
    properties = nothing
    if unionTag == capnp.schema.Node_union_file
        properties = FileNodeProps()
    elseif unionTag == capnp.schema.Node_union_struct
        dataWordCount = capnp.schema.Node_struct_getDataWordCount(ptr)
        pointerCount = capnp.schema.Node_struct_getPointerCount(ptr)
        preferredListEncoding = capnp.schema.Node_struct_getPreferredListEncoding(ptr)
        isGroup = capnp.schema.Node_struct_getIsGroup(ptr)
        discriminantCount = capnp.schema.Node_struct_getDiscriminantCount(ptr)
        discriminantOffset = capnp.schema.Node_struct_getDiscriminantOffset(ptr)
        fields = [read_Field(p) for p in capnp.schema.Node_struct_getFields(ptr)]

        properties = StructNodeProps(dataWordCount, pointerCount, preferredListEncoding, isGroup, discriminantCount, discriminantOffset, fields)
    elseif unionTag == capnp.schema.Node_union_enum
        enumerants = [read_Enumerant(p) for p in capnp.schema.Node_enum_getEnumerants(ptr)]
        properties = EnumNodeProps(enumerants)
    elseif unionTag == capnp.schema.Node_union_const
        type = read_Type(capnp.schema.Node_const_getType(ptr))
        value = read_Value(capnp.schema.Node_const_getValue(ptr))

        properties = ConstNodeProps(type, value)
    elseif unionTag == capnp.schema.Node_union_annotation
        annotationType = read_Type(capnp.schema.Node_annotation_getType(ptr))

        properties = AnnotationNodeProps(
            annotationType,
            capnp.schema.Node_annotation_getTargetsFile(ptr),
            capnp.schema.Node_annotation_getTargetsConst(ptr),
            capnp.schema.Node_annotation_getTargetsEnum(ptr),
            capnp.schema.Node_annotation_getTargetsEnumerant(ptr),
            capnp.schema.Node_annotation_getTargetsStruct(ptr),
            capnp.schema.Node_annotation_getTargetsField(ptr),
            capnp.schema.Node_annotation_getTargetsUnion(ptr),
            capnp.schema.Node_annotation_getTargetsGroup(ptr),
            capnp.schema.Node_annotation_getTargetsInterface(ptr),
            capnp.schema.Node_annotation_getTargetsMethod(ptr),
            capnp.schema.Node_annotation_getTargetsParam(ptr),
            capnp.schema.Node_annotation_getTargetsAnnotation(ptr),
        )
    end

    Node(id, displayName, displayNamePrefixLength, scopeId, parameters, isGeneric, nestedNodes, annotations, properties, "")
end

function read_CodeGeneratorRequest(ptr::Capnp.StructPointer)
    @assert ptr.data_word_count == 0 && ptr.pointer_count == 4

    nodes = [read_Node(p) for p in capnp.schema.CodeGeneratorRequest_getNodes(ptr)]

    requestedFiles = [read_RequestedFile(p) for p in capnp.schema.CodeGeneratorRequest_getRequestedFiles(ptr)]

    ptr_capnpVersion = capnp.schema.CodeGeneratorRequest_getCapnpVersion(ptr)
    capnpVersion = read_CapnpVersion(ptr_capnpVersion)

    sourceInfo = [] # Not implemented because there was no need so far

    CodeGeneratorRequest(nodes, requestedFiles, capnpVersion, sourceInfo)
end
