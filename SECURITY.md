# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.2.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in Capnp.jl, please report it responsibly:

1. **Do not** open a public GitHub issue for security vulnerabilities
2. Email the maintainers directly with details of the vulnerability
3. Include steps to reproduce the issue if possible
4. Allow reasonable time for the maintainers to address the issue before public disclosure

## Security Considerations

Capnp.jl is a serialization library that processes untrusted input. When using this library:

- **Input Validation**: Always validate Cap'n Proto messages from untrusted sources
- **Memory Safety**: The library uses `unsafe` operations for performance; malformed messages could potentially cause issues
- **Denial of Service**: Large or deeply nested messages could consume significant resources

## Response Timeline

- We aim to acknowledge security reports within 48 hours
- We will provide an initial assessment within 7 days
- Critical vulnerabilities will be prioritized for immediate fixes
