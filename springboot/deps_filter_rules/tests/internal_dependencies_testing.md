# Internal Dependencies Testing

`internal_dependencies` under both `depsfilter` and `dependencyset` contain comprehensive tests for the `deps_filter` rule and `dependencyset` macro, which filters compile-time and runtime dependencies in Java projects. The tests cover various dependency scenarios and filtering mechanisms to ensure the rule works correctly across different use cases.

## Directory Structure

```
tests/
├── depsfilter/
│   └── internal_dependencies/
│       ├── compile_time_only/
│       ├── runtime_only/
│       ├── compile_and_runtime_1/
│       └── compile_and_runtime_2/
└── dependencyset/
    └── internal_dependencies/
        ├── compile_time_only/
        ├── runtime_only/
        ├── compile_and_runtime_1/
        └── compile_and_runtime_2/
```

## Testing Approach

Similar testing scenarios are implemented using two different approaches:

### 1. Deps Filter Rule Testing

**Pattern**: `base_lib -> deps_filter() -> bazel starlark/java tests`

**Example from compile_and_runtime_1**:
```bazel
# Base library with dependencies
java_library(
    name = "base_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":lib_a"],
    runtime_deps = [":lib_g"],
)

# Apply filtering
deps_filter(
    name = "filtered_deps_exclude_b_g",
    deps = [":base_lib"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

# Test the filtered result
filtered_deps_test(
    name = "deps_filter_exclude_b_g_test",
    filtered = ":filtered_deps_exclude_b_g",
)
```

**Exception in compile_and_runtime_2**: No base_lib, direct `deps` and `runtime_deps` specified in `deps_filter` rule:
```bazel
deps_filter(
    name = "filtered_deps_exclude_b_g",
    deps = [":lib_a", ":lib_i"],
    runtime_deps = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

filtered_deps_test(
    name = "deps_filter_exclude_b_g_test",
    filtered = ":filtered_deps_exclude_b_g",
)
```

### 2. Dependencyset Macro Testing

**Pattern**: `dependencyset("deps), dependencyset("runtime_deps") -> java_library -> bazel starlark/java tests`

**Consistent approach across all test categories**:
```bazel
# Create filtered dependency sets
dependencyset(
    name = "deps_exclude_b_g",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

dependencyset(
    name = "runtime_deps_exclude_b_g",
    items = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

# Create test library using filtered sets
java_library(
    name = "exclude_b_g_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":deps_exclude_b_g"],
    runtime_deps = [":runtime_deps_exclude_b_g"],
)

# Test the filtered result
filtered_deps_test(
    name = "deps_filter_exclude_b_g_test",
    test_lib = ":exclude_b_g_test_lib",
)

# Java test for runtime verification
java_test(
    name = "DepsFilterFilteredDepsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterFilteredDepsTest.java"
    ],
    deps = [":exclude_b_g_test_lib"] + test_deps,
)
```

## Test Structure

The testing is organized into four main categories, each focusing on different aspects of dependency filtering:

### 1. `compile_time_only/`
**Purpose**: Tests dependency filtering when only compile-time dependencies are present.

**Key Characteristics**:
- All dependencies are compile-time (`deps` attribute)
- No runtime dependencies (`runtime_deps` attribute)
- Tests both interface JARs (`-hjar`) and implementation JARs

**Test Scenarios**:
- **No Filtering**: Verifies that `deps_filter`/`dependencyset` preserves all dependencies when no exclusions are applied
- **Basic Filtering**: Tests label-based exclusions with `exclude_transitives=False`
- **Transitive Exclusions**: Tests label-based exclusions with `exclude_transitives=True`
- **Path-based Exclusions**: Tests filtering based on path patterns

**Dependency Graph for depsfilter**:
```
        base_lib
        /     \
       A       G
      / \     /
     B   E   /
     |   | /
     |   F 
      \ / 
       C
       |
       D
```

**Dependency Graph for dependencyset**:
```
        base_lib
           |
     dependencyset()
        /     \
       A       I
      / \     /
     B   E   G
     |   | /
     |   F 
      \ / 
       C
       |
       D
```

### 2. `runtime_only/`
**Purpose**: Tests dependency filtering when only runtime dependencies are present.

**Key Characteristics**:
- All dependencies are runtime (`runtime_deps` attribute)
- No compile-time dependencies (`deps` attribute)
- Focuses on runtime JARs only

**Test Scenarios**:
- **No Filtering**: Verifies preservation of all runtime dependencies
- **Basic Filtering**: Tests label-based exclusions for runtime deps
- **Transitive Exclusions**: Tests transitive exclusion behavior for runtime deps
- **Path-based Exclusions**: Tests path pattern filtering for runtime deps

**Dependency Graph**: Same as compile_time_only, but all edges represent runtime dependencies.

### 3. `compile_and_runtime_1/`
**Purpose**: Tests mixed compile-time and runtime dependencies with a single direct dep.

**Key Characteristics**:
- Mixed compile-time and runtime dependencies
- Single root dependency (`base_lib`)
- Tests interface vs implementation JAR distinction

**Test Scenarios**:
- **No Filtering**: Verifies preservation of both compile and runtime JARs
- **Basic Filtering**: Tests label-based exclusions preserving transitives
- **Transitive Exclusions**: Tests label-based exclusions with transitives removal
- **Path-based Exclusions**: Tests path pattern filtering

**Dependency Graph for depsfilter**:
```
         base_lib      
        /       \  
      A (c)    G (r)
      /  \        |
     /    \       |
    /      \      |
   B (c)  E (r)   /
    |      |     /
    |      |   /
    |    F (c)
     \   /
    C (c)
     | 
    D (r)   
```

**Dependency Graph for dependencyset**:
```
         base_lib     
            |
      dependencyset() 
        /       \  
      A (c)    I (r)
      /  \        |
     /    \    G (r)
    /      \      |
   B (c)  E (r)   /
    |      |     /
    |      |   /
    |    F (c)
     \   /
    C (c)
     | 
    D (r)   
```

**Legend**: (c) = compile-time dependency, (r) = runtime dependency

### 4. `compile_and_runtime_2/`
**Purpose**: Tests complex mixed dependencies with multiple deps and runtime deps, and cross-branch connections.

**Key Characteristics**:
- More than one deps and runtime deps (A, I for compile; H, J for runtime)
- Cross-branch dependencies
- More complex dependency graph
- Tests interface/implementation JAR handling

**Test Scenarios**:
- **Filtered Dependencies**: Basic label-based exclusions
- **Transitive Exclusions**: Label-based exclusions with transitives removal
- **Path-based Exclusions**: Path pattern filtering
- **Interface/Implementation JARs**: Tests proper handling of -hjar vs full JARs
- **Multiple Exclusions**: Combined label and path exclusions
- **Empty Exclusions**: Behavior with no exclusions
- **Multiple Paths**: Handling of multiple paths to same dependency

**Dependency Graph for depsfilter**:
```
      J(r)      A (c)     H (r)   I (c)  
        \      /  \       |       |
         \    /    \    G (r)     |
          \  /     \      |      /
           B (c)  E (r)   /     /
            |      |     /    /
            |      |    /   /
            |      |   /  /
            |      |  / /
            |     F (c)
             \   /
            C (c)
              | 
            D (r) 
```

**Dependency Graph for dependencyset**:
```
                   test_lib
                      |
                 dependencyset
                 /           \
          ("deps")      ("runtime_deps")  
          /      \          /      \ 
        J(r)      A (c)     H (r)   I (c)  
          \      /  \       |       |
           \    /    \    G (r)     |
            \  /     \      |      /
             B (c)  E (r)   /     /
              |      |     /    /
              |      |    /   /
              |      |   /  /
              |      |  / /
              |     F (c)
               \   /
              C (c)
                | 
              D (r) 
```

## Test Verification

Each test verifies the following JAR fields:

- **`compile_jars`**: Interface JARs (e.g., `liblib_a-hjar.jar`)
- **`full_compile_jars`**: Implementation JARs (e.g., `liblib_a.jar`)
- **`transitive_compile_time_jars`**: Transitive interface JARs
- **`transitive_runtime_jars`**: Transitive implementation JARs

## Java Test Files

Each test scenario includes corresponding Java test files that:
- Verify the jars available at runtime
- Use centralized test helper (`DepsFilterTestHelper`)

## Key Testing Concepts

### 1. Label-based Exclusions
- Excludes dependencies by their Bazel label
- Can optionally exclude transitive dependencies
- More precise than path-based exclusions

### 2. Path-based Exclusions
- Excludes dependencies matching path patterns
- Less precise but more flexible
- Does not exclude transitives (exclude_transitives = true doesn't work)

### 3. Transitive Exclusion Behavior
- `exclude_transitives=False`: Only excludes direct dependencies, preserves transitives
- `exclude_transitives=True`: Excludes both direct and transitive dependencies

### 4. Interface vs Implementation JARs
- Interface JARs (`-hjar`) contain only public APIs
- Implementation JARs contain full class implementations
- Both are verified in tests to ensure proper filtering

### 5. Compile-time vs Runtime Dependencies
- Compile-time dependencies are needed during compilation
- Runtime dependencies are needed during execution
- Tests verify proper handling of both types

### 6. Rule vs Macro Testing
- **deps_filter rule**: Tests direct rule usage with synthetic dependency graphs
- **dependencyset macro**: Tests macro-level dependency management
- Both approaches should produce equivalent results for the same filtering criteria

## Test Coverage

The test suite covers:

- Basic dependency filtering functionality
- Label-based exclusion mechanisms
- Path-based exclusion mechanisms
- Transitive dependency handling
- Interface vs implementation JAR distinction
- Mixed compile-time and runtime dependencies
- Multiple deps and runtime deps
- Cross-branch dependency relationships
- Empty exclusion list behavior
- Multiple path handling to same dependency
- Complex dependency graph scenarios

## Running Tests

```bash
# Run all internal dependency tests
bazel test //springboot/deps_filter_rules/tests/depsfilter/internal_dependencies/...
bazel test //springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/...
```

This comprehensive test suite ensures the `deps_filter` rule and `dependencyset` macro work correctly across all expected use cases and edge cases. 