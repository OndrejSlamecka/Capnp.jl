# Changelog

All notable changes to Capnp.jl are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Experimental Cap'n Proto RPC client, server, promise, transport, and persistence infrastructure.
- Default-value, packed-encoding, generic-schema, and preallocated-buffer support.
- Cross-platform CI, Aqua quality checks, code coverage, Dependabot, and Documenter documentation.
- Strict stream-framing limits and malformed-message regression tests.

### Fixed

- Hangs during RPC message resolution due to invalid parsing of `Return` messages.
- Silent failure during `Finish` message dispatch for RPC calls.
- `InvalidCapabilityException` during `bootstrap` extraction from `Return` messages.

### Changed

- Replaced multiple unstructured string throws with typed `InvalidMessageError`.
- Removed currently unused RPC server/connection options (e.g. `connection_timeout`, `send_buffer_size`) to clarify the working API.

### Changed

- Julia 1.10 is now the minimum supported version.
- The generated API uses Julia-style snake-case names while retaining deprecated compatibility wrappers.

### Security

- Message framing now rejects excessive segment counts, oversized messages, non-zero padding, and truncated segments.
- Core pointer reads and writes validate segment and byte ranges before accessing memory.
