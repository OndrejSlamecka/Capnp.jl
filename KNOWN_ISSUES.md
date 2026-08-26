# Known Issues

This document tracks known issues, workarounds, and compatibility notes for the Capnp.jl implementation.

## RPC Issues

### Non-standard MessageTarget Discriminant from C++ Clients

**Status:** Workaround implemented
**Affected:** C++ Cap'n Proto clients calling receiver-hosted capabilities
**Fixed in:** Commit `384d4e9`

#### Description

When a Julia server returns a capability via `senderHosted` in the CapDescriptor (e.g., `senderHosted = 2`), some C++ Cap'n Proto RPC clients send subsequent Call messages with an unexpected MessageTarget format.

According to the Cap'n Proto RPC specification (`rpc.capnp`), MessageTarget is a union with two variants:
```
struct MessageTarget {
  union {
    importedCap @0 :ImportId;
    promisedAnswer @1 :PromisedAnswer;
  }
}
```

**Expected behavior:** When calling a capability that was received via `senderHosted = N`, the client should send:
- `MessageTarget.importedCap = N` (discriminant = 0, value = N at offset 4)

**Observed behavior:** The C++ client sends:
- discriminant = N (the export ID is used as the discriminant value)
- value at offset 4 = 0

For example, for a capability exported with `senderHosted = 2`:
- Expected: `0x0000000200000000` (discriminant=0, importedCap=2)
- Actual: `0x0000000000000002` (discriminant=2, value=0)

#### Workaround

The `parse_message_target` function in `src/rpc/protocol.jl` handles this by treating non-standard discriminant values (>1) as import IDs:

```julia
if target_type_raw == 0  # importedCap
    import_id = read_data_field(seg, target_start, 4, UInt32)
    return ParsedMessageTarget(MessageTargetType.IMPORTED_CAP, ImportId(import_id))
elseif target_type_raw == 1  # promisedAnswer
    return ParsedMessageTarget(MessageTargetType.PROMISED_ANSWER, nothing)
else
    # Non-standard discriminant: treat as importedCap with discriminant value as import_id
    return ParsedMessageTarget(MessageTargetType.IMPORTED_CAP, ImportId(target_type_raw))
end
```

#### Impact

Without this workaround, calling methods on capabilities returned from functions like `getSubCalculator()` would fail with "Invalid capability" errors.

#### Environment

- Observed with: Cap'n Proto C++ library v0.9.2
- Julia: 1.10+
- Platform: Linux x86_64

#### Reproduction

1. Julia server exports a capability with `senderHosted = N` (where N > 1)
2. C++ client receives the capability and calls a method on it
3. Without workaround: Server rejects the call with "Invalid capability"
4. With workaround: Call succeeds

#### References

- Cap'n Proto RPC specification: https://capnproto.org/rpc.html
- MessageTarget definition: https://github.com/capnproto/capnproto/blob/master/c%2B%2B/src/capnp/rpc.capnp

---

## Reporting New Issues

If you encounter a new issue, please report it at:
https://github.com/s-celles/Capnp.jl/issues

Include:
- Julia version
- Cap'n Proto version (if applicable)
- Minimal reproduction case
- Expected vs actual behavior
