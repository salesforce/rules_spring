# Testing Overview

This directory contains comprehensive tests for the `deps_filter` Bazel rule and `dependencyset` macro. The test suites validate compile-time and runtime dependency filtering across synthetic internal graphs and real external libraries.

## Directory Structure

```
tests/
├── depsfilter/                    # Tests for deps_filter rule
│   ├── internal_dependencies/     # Synthetic dependency graphs
│   └── external_dependencies/     # Real external libraries
├── dependencyset/                 # Tests for dependencyset macro
│   ├── internal_dependencies/     
│   └── external_dependencies/     
├── test_utils/                    # Shared testing utilities
│   ├── verification_utils.bzl     # Starlark verification helpers
│   ├── dependency_graph.txt       # Pre-generated dependency graph
│   └── src/                       # Java test utilities
└── external_deps/                 # External dependency management
    ├── unmanaged_deps_filter.bzl  # Maven dependency definitions
    └── unmanaged_deps_filter_install.json  # Lock file
```

## Detailed Documentation

- **[Internal Dependencies Testing](internal_dependencies_testing.md)**: Comprehensive guide for internal dependency testing
- **[External Dependencies Testing](external_dependencies_testing.md)**: Comprehensive guide for real external dependency testing

## What These Tests Verify

### Core Functionality
- Correct JAR sets for all jar types: `compile_jars`, `full_compile_jars`, `transitive_compile_jars`, `transitive_runtime_jars`
- Interface (compile time) vs implementation (runtime) JAR distinction (`-hjar` vs full JARs)
- Mixed dependency graphs: compile-only, runtime-only, and mixed compile+runtime cases

### Exclusion Mechanisms
- **Label-based exclusions**: Exclude dependencies by their Bazel label
- **Path/pattern-based exclusions**: Exclude dependencies matching path patterns in JAR names
- **`exclude_transitives`**: Control whether transitive dependencies are also excluded
- **Multiple exclusions**: Combined label and path exclusions

### Edge Cases
- Empty exclusion lists
- Special characters in path patterns (dots, hyphens)
- Case sensitivity in pattern matching
- Multiple paths to the same dependency
- Complex cross-branch dependency relationships

## Testing Approaches

### Starlark Testing - Rule/Macro Output Verification
Starlark tests verify the `deps_filter` rule's and `dependencyset` macro's output.

### Java Testing - Runtime Classpath Verification
Java tests verify that the correct JARs are available at runtime.

More details in [internal dependencies testing](internal_dependencies_testing.md) and [external dependencies testing](external_dependencies_testing.md).

## Common Utilities

### test_utils/
- **`verification_utils.bzl`**: Starlark utilities for verifying JAR collections and exclusion counts
- **`DependencyGraphAnalyzer`**: Java utility for parsing and analyzing Bazel dependency graphs
- **`DepsFilterTestHelper`**: Java utility for computing runtime classpath dependencies

### external_deps/
- **`unmanaged_deps_filter.bzl`**: Defines external Maven dependencies (Spring Boot, Jakarta, etc.)
- **`unmanaged_deps_filter_install.json`**: Lock file for pinned dependency versions

## Managing External Dependencies

To update external dependencies:
1. Edit `external_deps/unmanaged_deps_filter.bzl`
2. Run: `bazel run @unpinned_unmanaged_deps_filter//:pin`

## Refreshing Dependency Graphs

Some Java tests use a pre-generated graph file. To refresh:
```bash
bazel query 'deps("//springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime:no_filtering")' --output=graph > dependency_graph.txt
```

## Running Tests

```bash
# Run all tests
bazel test //springboot/deps_filter_rules/tests/...
```

## Test Coverage Summary

The comprehensive test suite ensures the `deps_filter` rule and `dependencyset` macro work correctly across:
- Basic dependency filtering functionality
- All exclusion mechanisms (label, path, transitive)
- Interface vs implementation JAR distinction
- Mixed compile-time and runtime dependencies
- Complex dependency graph scenarios
- Real-world external library integration
- Edge cases and error conditions
