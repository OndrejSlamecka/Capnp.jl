# Contributing to Capnp.jl

Thank you for your interest in contributing to Capnp.jl! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/s-celles/Capnp.jl.git
   cd Capnp.jl
   ```
3. Install Cap'n Proto (1.3.0+):

See https://capnproto.org/install.html or

   - **macOS**: `brew install capnp`
   - **Linux**: Build from source (see CI workflow)
   - **Windows**: `choco install capnproto`

4. Run the tests to ensure everything works:
   ```bash
   julia --project -e 'using Pkg; Pkg.test()'
   ```

## Development Workflow

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the coding standards below

3. Add tests for new functionality

4. Ensure all tests pass:
   ```bash
   julia --project -e 'using Pkg; Pkg.test()'
   ```

5. Commit your changes with a descriptive message:
   ```bash
   git commit -m "feat: add new feature description"
   ```

6. Push to your fork and open a Pull Request

## Coding Standards

### Julia Style

- Follow Julia naming conventions:
  - `lowercase_with_underscores` for functions
  - `CamelCase` for types
- Keep functions focused and reasonably sized
- Add docstrings for public API functions

### Commit Messages

Use conventional commit format:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `test:` for test additions/changes
- `refactor:` for code refactoring
- `chore:` for maintenance tasks

### Testing

- All new functionality must include tests
- Bug fixes should include a regression test
- Tests should be placed in the `test/` directory

## Code Organization

- `src/runtime_types.jl` - Type definitions
- `src/runtime_lib.jl` - Core runtime functionality
- `src/generator.jl` - Code generator for `.capnp` schemas
- `src/schema.capnp.jl` - Generated code for Cap'n Proto meta-schema
- `src/rpc/` - RPC implementation
- `test/` - Test files

## Pull Request Process

1. Update documentation if needed
2. Ensure CI passes on all platforms (Linux, macOS, Windows)
3. Request review from maintainers
4. Address any feedback
5. Once approved, a maintainer will merge your PR

## Reporting Issues

When reporting issues, please include:
- Julia version (`julia --version`)
- Cap'n Proto version (`capnp --version`)
- Operating system
- Minimal reproducible example
- Expected vs actual behavior

## Questions?

Feel free to open a GitHub issue for questions about contributing.
