# Supported functionality

## Serialization

- Cap'n Proto stream framing and multiple segments
- Structs, primitive fields, lists, text, and capability pointers
- Default-value XOR handling
- Basic packed encoding
- Generic schema metadata and Julia code generation
- Preallocated buffer readers and builders

## Experimental or incomplete

- Generated RPC client calls and promise pipelining
- Complete handling of every RPC message variant
- Two-word far-pointer landing-pad generation
- Packed zero and literal run optimization
- Traversal and nesting budgets for hostile object graphs
- End-to-end interoperability coverage across supported Cap'n Proto versions

The package remains pre-1.0, so generated APIs may still change.
