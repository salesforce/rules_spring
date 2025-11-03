# External Dependencies Testing

`external_dependencies` under both `depsfilter` and `dependencyset` contain comprehensive tests for the `deps_filter` rule and `dependencyset` macro using real external deps (Spring Boot, Jakarta libraries) to ensure correct filtering in complex dependency graphs.

## Purpose

- Validate `deps_filter` and `dependencyset` with real-world, complex external deps
- Dynamically verify results using bazel's dependency graph
- Cover all exclusion mechanisms and multiple edge cases

## Directory Structure

```
tests/
├── depsfilter/
│   └── external_dependencies/
│       ├── compile_and_runtime/
│       └── compile_and_runtime_through_java_library/
└── dependencyset/
    └── external_dependencies/
        └── compile_and_runtime/
```

## Testing Approach

Similar testing scenarios are implemented using two different approaches:

### 1. Deps Filter Rule Testing

**Pattern**: `external deps -> deps_filter() -> bazel starlark/java tests`

**Example from compile_and_runtime**:
```bazel
# Direct external deps in deps_filter
deps_filter(
    name = "no_filtering",
    deps = deps,
    runtime_deps = runtime_deps,
)

no_filtering_test(
    name = "no_filtering_test",
    filtered = ":no_filtering",
)

java_test(
    name = "DepsFilterNoFilteringTest",
    size = "small",
    srcs = ["src/test/java/com/depsfilter/DepsFilterNoFilteringTest.java"],
    deps = [":no_filtering", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)
```

**Example from compile_and_runtime_through_java_library**:
```bazel
# External deps wrapped in java_library first
java_library(
    name = "base_lib_with_deps_and_runtime_deps",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = deps,
    runtime_deps = runtime_deps,
)

# Then filtered through deps_filter
deps_filter(
    name = "no_filtering",
    deps = [":base_lib_with_deps_and_runtime_deps"],
)

no_filtering_test(
    name = "no_filtering_test",
    filtered = ":no_filtering",
)

java_test(
    name = "DepsFilterNoFilteringTest",
    size = "small",
    srcs = ["src/test/java/com/depsfilter/DepsFilterNoFilteringTest.java"],
    deps = [":no_filtering", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)
```

### 2. Dependencyset Macro Testing

**Pattern**: `dependencyset("deps"), dependencyset("runtime_deps") -> java_library -> bazel starlark/java tests`

**Consistent approach across all test scenarios**:
```bazel
# Create filtered dependency sets
dependencyset(
    name = "deps_no_filtering",
    items = deps,
)

dependencyset(
    name = "runtime_deps_no_filtering",
    items = runtime_deps,
)

# Create test library using filtered sets
java_library(
    name = "no_filtering_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_no_filtering"],
    runtime_deps = [":runtime_deps_no_filtering"],
)

# Test the filtered result
no_filtering_test(
    name = "no_filtering_test",
    test_lib = ":no_filtering_test_lib",
)

# Java test for runtime verification
java_test(
    name = "DepsFilterNoFilteringTest",
    size = "small",
    srcs = ["src/test/java/com/depsfilter/DepsFilterNoFilteringTest.java"],
    deps = [":no_filtering_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)
```

## Test Structure

The testing is organized into two comprehensive test suites that focus on real external deps:

### `depsfilter/external_dependencies/`

**Key Characteristics:**
- Tests the `deps_filter` rule directly
- Uses actual external libraries directly in deps_filter targets
- Complex dependency graph with 100+ transitive deps
- Tests both compile-time and runtime deps

#### `compile_and_runtime/`
- Uses actual external libraries directly in deps_filter targets
- Tests both compile-time and runtime deps

#### `compile_and_runtime_through_java_library/`
- Uses actual external libraries wrapped in java_library targets
- External deps are passed through java_library targets before testing
- Tests the same scenarios but with an additional layer of indirection
- More realistic testing scenario where external deps are consumed through internal libraries

### `dependencyset/external_dependencies/`

**Key Characteristics:**
- Tests the `dependencyset` macro
- Uses actual external libraries through dependencyset targets
- Tests the same scenarios as depsfilter but using the macro approach
- Validates that dependencyset provides the same filtering capabilities

#### `compile_and_runtime/`
- Uses dependencyset macro to manage external deps
- Tests both compile-time and runtime deps through dependencyset
- Validates macro-level filtering behavior

**Deps Used (for both approaches):**
```python
# Compile-time Deps
deps = [
    "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
    "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security", 
    "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
    "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
    "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
]
# Runtime Deps
runtime_deps = [
    "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
    "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
    "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
]
```

## Test Coverage

Both test suites cover:
- **No filtering**: Baseline test with all deps included
- **Label-based exclusions**: Exclude specific deps by label (with and without transitives)
- **Path-based exclusions**: Exclude deps by path patterns (with and without transitives)
- **Multiple exclusions**: Combined label and path exclusions (with and without transitives)
- **Empty exclusions**: Behavior with empty exclusion lists
- **Comprehensive path-based exclusions**: Multiple path patterns, including common libraries (micrometer, slf4j, logback)
- **Runtime deps only**: Only runtime deps, no compile-time deps
- **Compile deps only**: Only compile-time deps, no runtime deps
- **Single dependency with exclusions**: One dep with label/path exclusions
- **Single runtime dependency with exclusions**: One runtime dep with exclusions
- **One compile dep and one runtime dep**
- **Path patterns with special characters**: Patterns with dots, hyphens, etc.
- **Case sensitive pattern matching**: Patterns with different cases (upper, lower, mixed)

## Verification Approach

We use two complementary testing strategies to ensure comprehensive validation:

### Java Testing - Runtime Classpath Verification

Java tests verify that the correct JARs are available at runtime by:

1. **Computing Expected Deps**: 
   - Parse `dependency_graph.txt` generated by bazel's `deps()` query
   - Build complete dependency graph using `DependencyGraphAnalyzer`
   - Apply exclusion logic (labels, paths, transitives) to simulate `deps_filter`/`dependencyset` behavior
   - Generate expected runtime classpath from filtered graph

2. **Obtaining Available Deps**:
   - Read actual runtime classpath using `System.getProperty("java.class.path")`
   - Parse and normalize classpath entries to JAR names

3. **Comparison**:
   - Compare expected runtime JARs vs actual available runtime JARs
   - Verify excluded deps are absent and required deps are present

```java
// Compute expected runtime JARs
Set<String> expectedJars = DependencyGraphTestConfig
    .getExpectedJarsForLabelExclusionsFiltered(excludedLabels, excludeTransitives);

// Get actual runtime classpath
List<String> availableDeps = DepsFilterTestHelper.computeClasspathDependencies();

// Compare expected vs available
assertEquals(expectedJars, new HashSet<>(availableDeps));
```

### Starlark Testing - Rule/Macro Output Verification

Starlark tests verify the `deps_filter` rule's and `dependencyset` macro's output by:

1. **Computing Expected Deps**:
   - Iterate through all `deps` and `runtime_deps`
   - Apply exclusion logic (label matching, path patterns, transitive handling)
   - Generate expected JAR lists for each of the four JAR types: `compile_jars`, `full_compile_jars`, `transitive_compile_jars`, `transitive_runtime_jars`

2. **Obtaining Available Deps**:
   - Extract JAR collections from the `deps_filter` rule's `JavaInfo` or `dependencyset` macro's output
   - Get all four JAR types: `compile_jars`, `full_compile_jars`, `transitive_compile_jars`, `transitive_runtime_jars`

3. **Comparison**:
   - Compare expected vs actual JARs for all four JAR types
   - Verify exclusion counts (number of jars excluded) and JAR contents match

```python
# Verify all four JAR types
def verify_jars(env, actual_jars, expected_jars, jar_field):
    asserts.equals(env, expected_jars, actual_jars,
        "JAR contents mismatch: {} vs deps_filter/dependencyset".format(jar_field))
```

## Test Verification

Each Starlark test verifies the following JAR fields:

- **`compile_jars`**: Interface JARs (e.g., `header_spring-boot-starter-data-jpa-3.3.11.jar`)
- **`full_compile_jars`**: Implementation JARs (e.g., `processed_spring-boot-starter-data-jpa-3.3.11.jar`)
- **`transitive_compile_time_jars`**: Transitive interface JARs
- **`transitive_runtime_jars`**: Transitive implementation JARs

## Java Test Files

Each test scenario includes corresponding java test files that:
- Verify the jars available at runtime
- Use centralized test helper (`DepsFilterTestHelper`)
- Compute expected results from dependency graph

## Key Testing Concepts

### 1. Label-based Exclusions
- Excludes deps by their label
- Can optionally exclude transitive deps

### 2. Path-based Exclusions
- Excludes deps matching path patterns in JAR names
- Does not exclude transitives (`exclude_transitives = true` doesn't work)

### 3. Transitive Exclusion Behavior
- `exclude_transitives=False`: Only excludes deps specified in `deps_exclude_labels`, preserves their transitives
- `exclude_transitives=True`: Excludes both direct and transitive deps specified in `deps_exclude_labels`

### 4. Runtime Classpath Verification
- Compare expected vs actual runtime classpath
- Verify excluded deps are absent
- Verify required deps are present
- Handle complex transitive dependency scenarios

### 5. Rule vs Macro Testing
- **deps_filter rule**: Tests direct rule usage with external deps
- **dependencyset macro**: Tests macro-level dependency management
- Both approaches should produce equivalent results for the same filtering criteria
