module Capnp

# Used by generated code at runtime
export MessageTraverser, Reader, Writer
export alloc, writeMessageToStream
export WirePointer, ListPointer, SimpleListPointer, CompositeListPointer, StructPointer

export read_bool, read_bits, read_struct_pointer, read_text, read_list_pointer
export read_bool, write_bits, write_struct_pointer, write_root_struct_pointer, write_text, write_list_pointer

export ElementSize, Empty, Bit, Byte, TwoBytes, FourBytes, EightBytes, Pointer, InlineComposite

include("capnp_types.jl")
include("runtime_lib.jl")

module Generator
using ..Capnp

include("schema.capnp.jl")
include("schema_tree.jl")
include("generator.jl")
end

end
