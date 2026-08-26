# Work in progress, a test similar to the addressbok integration test

import Capnp

const capnp = Capnp.Generator.capnp # similar to include("schema.capnp.jl")

# Writer debugging:
builder = Capnp.AllocMessageBuilder()
request = capnp.schema.init_root!(builder, Val{:CodeGeneratorRequest})

# Read request.bin
input_buffer = read(joinpath(@__DIR__, "..", "request.bin"))
reader = Capnp.BufferMessageReader(input_buffer)
ptr_codeGeneratorRequest = capnp.schema.root(reader, Val{:CodeGeneratorRequest})

println("= capnp version")
capnpVersion = capnp.schema.init_capnp_version!(request, Val{:CodeGeneratorRequest})
capnp.schema.set_major!(capnpVersion, 1, Val{:CapnpVersion})
capnp.schema.set_minor!(capnpVersion, 2, Val{:CapnpVersion})
capnp.schema.set_micro!(capnpVersion, 3, Val{:CapnpVersion})

#

println("= requested files")
requestedFilesReader = capnp.schema.get_requested_files(ptr_codeGeneratorRequest, Val{:CodeGeneratorRequest})
requestedFilesWriter = capnp.schema.init_requested_files!(request, length(requestedFilesReader), Val{:CodeGeneratorRequest})

for (r, w) in zip(requestedFilesReader, requestedFilesWriter)
    capnp.schema.set_id!(w, capnp.schema.get_id(r, Val{:CodeGeneratorRequest_RequestedFile}), Val{:CodeGeneratorRequest_RequestedFile})
    println("   filename ", capnp.schema.get_filename(r, Val{:CodeGeneratorRequest_RequestedFile}))
    capnp.schema.set_filename!(w, capnp.schema.get_filename(r, Val{:CodeGeneratorRequest_RequestedFile}), Val{:CodeGeneratorRequest_RequestedFile})

    println("   imports")
    requestedFilesImportsReader = capnp.schema.get_imports(r, Val{:CodeGeneratorRequest_RequestedFile})
    requestedFilesImportsWriter = capnp.schema.init_imports!(w, length(requestedFilesImportsReader), Val{:CodeGeneratorRequest_RequestedFile})
    for (ri, wi) in zip(requestedFilesImportsReader, requestedFilesImportsWriter)
        capnp.schema.set_id!(wi, capnp.schema.get_id(ri, Val{:CodeGeneratorRequest_RequestedFile_Import}), Val{:CodeGeneratorRequest_RequestedFile_Import})
        println("       import name")
        capnp.schema.set_name!(wi, capnp.schema.get_name(ri, Val{:CodeGeneratorRequest_RequestedFile_Import}), Val{:CodeGeneratorRequest_RequestedFile_Import})
    end
end

println("= source info")
sourceInfoReader = capnp.schema.get_source_info(ptr_codeGeneratorRequest, Val{:CodeGeneratorRequest})
sourceInfoWriter = capnp.schema.init_source_info!(request, length(sourceInfoReader), Val{:CodeGeneratorRequest})

for (i, (r, w)) in enumerate(zip(sourceInfoReader, sourceInfoWriter))
    println(i, "/", length(sourceInfoReader))
    capnp.schema.set_id!(w, capnp.schema.get_id(r, Val{:Node_SourceInfo}), Val{:Node_SourceInfo})
    capnp.schema.set_doc_comment!(w, capnp.schema.get_doc_comment(r, Val{:Node_SourceInfo}), Val{:Node_SourceInfo})

    memberReader = capnp.schema.get_members(r, Val{:Node_SourceInfo})
    memberWriter = capnp.schema.init_members!(w, length(memberReader), Val{:Node_SourceInfo})

    for (im, (rm, wm)) in enumerate(zip(memberReader, memberWriter))
        capnp.schema.set_doc_comment!(wm, capnp.schema.get_doc_comment(rm, Val{:Node_SourceInfo_Member}), Val{:Node_SourceInfo_Member})
    end
end

println("= nodes")
nodesReader = capnp.schema.get_nodes(ptr_codeGeneratorRequest, Val{:CodeGeneratorRequest})
nodesWriter = capnp.schema.init_nodes!(request, length(nodesReader), Val{:CodeGeneratorRequest})

for (i, (r, w)) in enumerate(zip(nodesReader, nodesWriter))
    println(i, "/", length(nodesReader))
    capnp.schema.set_id!(w, capnp.schema.get_id(r, Val{:Node}), Val{:Node})
    capnp.schema.set_display_name!(w, capnp.schema.get_display_name(r, Val{:Node}), Val{:Node})
    capnp.schema.set_display_name_prefix_length!(w, capnp.schema.get_display_name_prefix_length(r, Val{:Node}), Val{:Node})
    capnp.schema.set_scope_id!(w, capnp.schema.get_scope_id(r, Val{:Node}), Val{:Node})

    # parameters
    parametersReader = capnp.schema.get_parameters(r, Val{:Node})
    parametersWriter = capnp.schema.init_parameters!(w, length(parametersReader), Val{:Node})

    for (ip, (rp, wp)) in enumerate(zip(parametersReader, parametersWriter))
        capnp.schema.set_name!(wp, capnp.schema.get_name(rp, Val{:Node_Parameter}), Val{:Node_Parameter})
    end

    #
    capnp.schema.set_is_generic!(w, capnp.schema.get_is_generic(r, Val{:Node}), Val{:Node})

    # nested nodes
    nestedNodesReader = capnp.schema.get_nested_nodes(r, Val{:Node})
    nestedNodesWriter = capnp.schema.init_nested_nodes!(w, length(nestedNodesReader), Val{:Node})

    for (in, (rn, wn)) in enumerate(zip(nestedNodesReader, nestedNodesWriter))
        capnp.schema.set_name!(wn, capnp.schema.get_name(rn, Val{:Node_NestedNode}), Val{:Node_NestedNode})
        capnp.schema.set_id!(wn, capnp.schema.get_id(rn, Val{:Node_NestedNode}), Val{:Node_NestedNode})
    end

    # annotations
    println("    annotations")
    annotationsReader = capnp.schema.get_annotations(r, Val{:Node})
    annotationsWriter = capnp.schema.init_annotations!(w, length(annotationsReader), Val{:Node})

    for (ia, (ra, wa)) in enumerate(zip(annotationsReader, annotationsWriter))
        println("        annotation")
        capnp.schema.set_id!(wa, capnp.schema.get_id(ra, Val{:Annotation}), Val{:Annotation})

        # brand
        brandReader = capnp.schema.get_brand(ra, Val{:Annotation})
        brandWriter = capnp.schema.init_brand!(wa, Val{:Annotation})

        brandScopesReader = capnp.schema.get_scopes(brandReader, Val{:Brand})
        brandScopesWriter = capnp.schema.init_scopes!(brandWriter, length(brandScopesReader), Val{:Brand})

        for (ibs, (rbs, wbs)) in enumerate(zip(brandScopesReader, brandScopesWriter))
            capnp.schema.set_scope_id!(wbs, capnp.schema.get_scope_id(rbs, Val{:Brand_Scope}), Val{:Brand_Scope})

            if capnp.schema.which(rbs, Val{:Brand_Scope}) == Brand_Scope_union_inherit # TODO: Also try Brand_Scope_isInherit(rbs)
                capnp.schema.set_inherit!(wbs, Val{:Brand_Scope})
            else # bind
                bindingReader = capnp.schema.get_bind(rbs, Val{:Brand_Scope})
                bindingWriter = capnp.schema.init_bind!(rbs, length(bindingReader), Val{:Brand_Scope})

                for (ibsb, (rbsb, wbsb)) in enumerate(zip(bindingReader, bindingWriter))
                    if capnp.schema.which(rbsb, Val{:Brand_Binding}) == capnp.schema.Brand_Binding_union_unbound
                        capnp.schema.set_unbound!(wbsb, Val{:Brand_Binding})
                    else # type
                        # TODO: This is hard and I don't want to do it now
                    end
                end
            end
        end

    end

    # if capnp.schema.Node_isFile() ...
end
