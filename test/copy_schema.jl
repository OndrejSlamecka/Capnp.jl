# Work in progress, a test similar to the addressbok integration test

import Capnp

const capnp = Capnp.Generator.capnp # similar to include("schema.capnp.jl")

# Writer debugging:
builder = Capnp.AllocMessageBuilder()
request = capnp.schema.initRoot_CodeGeneratorRequest(builder)

println(builder.segments[1][1:64])

println("= capnp version")
capnpVersion = capnp.schema.CodeGeneratorRequest_initCapnpVersion(request)
capnp.schema.CapnpVersion_setMajor(capnpVersion, 1)
capnp.schema.CapnpVersion_setMinor(capnpVersion, 2)
capnp.schema.CapnpVersion_setMicro(capnpVersion, 3)

#

println("= requested files")
requestedFilesReader = capnp.schema.CodeGeneratorRequest_getRequestedFiles(ptr_codeGeneratorRequest)
requestedFilesWriter = capnp.schema.CodeGeneratorRequest_initRequestedFiles(request, length(requestedFilesReader))

for (r, w) in zip(requestedFilesReader, requestedFilesWriter)
    capnp.schema.CodeGeneratorRequest_RequestedFile_setId(w, capnp.schema.CodeGeneratorRequest_RequestedFile_getId(r))
    println("   filename ", capnp.schema.CodeGeneratorRequest_RequestedFile_getFilename(r))
    capnp.schema.CodeGeneratorRequest_RequestedFile_setFilename(w, capnp.schema.CodeGeneratorRequest_RequestedFile_getFilename(r))

    println("   imports")
    requestedFilesImportsReader = capnp.schema.CodeGeneratorRequest_RequestedFile_getImports(r)
    requestedFilesImportsWriter = capnp.schema.CodeGeneratorRequest_RequestedFile_initImports(w, length(requestedFilesImportsReader))
    for (ri, wi) in zip(requestedFilesImportsReader, requestedFilesImportsWriter)
        capnp.schema.CodeGeneratorRequest_RequestedFile_Import_setId(wi, capnp.schema.CodeGeneratorRequest_RequestedFile_Import_getId(ri))
        println("       import name")
        capnp.schema.CodeGeneratorRequest_RequestedFile_Import_setName(wi, capnp.schema.CodeGeneratorRequest_RequestedFile_Import_getName(ri))
    end
end

println("= source info")
sourceInfoReader = capnp.schema.CodeGeneratorRequest_getSourceInfo(ptr_codeGeneratorRequest)
sourceInfoWriter = capnp.schema.CodeGeneratorRequest_initSourceInfo(request, length(sourceInfoReader))

for (i, (r, w)) in enumerate(zip(sourceInfoReader, sourceInfoWriter))
    println(i, "/", length(sourceInfoReader))
    capnp.schema.Node_SourceInfo_setId(w, capnp.schema.Node_SourceInfo_getId(r))
    capnp.schema.Node_SourceInfo_setDocComment(w, capnp.schema.Node_SourceInfo_getDocComment(r))

    memberReader = capnp.schema.Node_SourceInfo_getMembers(r)
    memberWriter = capnp.schema.Node_SourceInfo_initMembers(w, length(memberReader))

    for (im, (rm, wm)) in enumerate(zip(memberReader, memberWriter))
        capnp.schema.Node_SourceInfo_Member_setDocComment(wm, capnp.schema.Node_SourceInfo_Member_getDocComment(rm))
    end
end

println("= nodes")
nodesReader = capnp.schema.CodeGeneratorRequest_getNodes(ptr_codeGeneratorRequest)
nodesWriter = capnp.schema.CodeGeneratorRequest_initNodes(request, length(nodesReader))

for (i, (r, w)) in enumerate(zip(nodesReader, nodesWriter))
    println(i, "/", length(nodesReader))
    capnp.schema.Node_setId(w, capnp.schema.Node_getId(r))
    capnp.schema.Node_setDisplayName(w, capnp.schema.Node_getDisplayName(r))
    capnp.schema.Node_setDisplayNamePrefixLength(w, capnp.schema.Node_getDisplayNamePrefixLength(r))
    capnp.schema.Node_setScopeId(w, capnp.schema.Node_getScopeId(r))

    # parameters
    parametersReader = capnp.schema.Node_getParameters(r)
    parametersWriter = capnp.schema.Node_initParameters(w, length(parametersReader))

    for (ip, (rp, wp)) in enumerate(zip(parametersReader, parametersWriter))
        capnp.schema.Node_Parameter_setName(wp, capnp.schema.Node_Parameter_getName(rp))
    end

    #
    capnp.schema.Node_setIsGeneric(w, capnp.schema.Node_getIsGeneric(r))

    # nested nodes
    nestedNodesReader = capnp.schema.Node_getNestedNodes(r)
    nestedNodesWriter = capnp.schema.Node_initNestedNodes(w, length(nestedNodesReader))

    for (in, (rn, wn)) in enumerate(zip(nestedNodesReader, nestedNodesWriter))
        capnp.schema.Node_NestedNode_setName(wn, capnp.schema.Node_NestedNode_getName(rn))
        capnp.schema.Node_NestedNode_setId(wn, capnp.schema.Node_NestedNode_getId(rn))
    end

    # annotations
    println("    annotations")
    annotationsReader = capnp.schema.Node_getAnnotations(r)
    annotationsWriter = capnp.schema.Node_initAnnotations(w, length(annotationsReader))

    for (ia, (ra, wa)) in enumerate(zip(annotationsReader, annotationsWriter))
        println("        annotation")
        capnp.schema.Annotation_setId(wa, capnp.schema.Annotation_getId(ra))

        # brand
        brandReader = capnp.schema.Annotation_getBrand(ra)
        brandWriter = capnp.schema.Annotation_initBrand(wa)

        brandScopesReader = capnp.schema.Brand_getScopes(brandReader)
        brandScopesWriter = capnp.schema.Brand_initScopes(brandWriter, length(brandScopesReader))

        for (ibs, (rbs, wbs)) in enumerate(zip(brandScopesReader, brandScopesWriter))
            capnp.schema.Brand_Scope_setId(wbs, capnp.schema.Brand_Scope_getId(rbs))

            if capnp.schema.Brand_Scope_which(rbs) == Brand_Scope_union_inherit # TODO: Also try Brand_Scope_isInherit(rbs)
                capnp.schema.Brand_Scope_setInherit(wbs)
            else # bind
                bindingReader = capnp.schema.Brand_Scope_getBind(rbs)
                bindingWriter = capnp.schema.Brand_Scope_initBind(rbs, length(bindingReader))

                for (ibsb, (rbsb, wbsb)) in enumerate(zip(bindingReader, bindingWriter))
                    if capnp.schema.Brand_Binding_which(rbsb) == capnp.schema.Brand_Binding_union_unbound
                        capnp.schema.Brand_Binding_setUnbound(wbsb)
                    else # type
                        # TODO: This is hard and I don't want to do it now
                    end
                end
            end
        end

    end

    # if capnp.schema.Node_isFile() ...
end
