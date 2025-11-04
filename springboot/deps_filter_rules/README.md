# Dependencies Filter

A Bazel rule that filters compile-time and runtime dependencies in Java projects, ensuring only the necessary ones are included in the build. This rule can be referenced by other Java targets, such as `java_library`, and helps to remove problematic or unwanted dependencies, offering better control over dependency graphs.

## Overview

The `deps_filter` rule removes Java dependencies from your dependency graph when you have knowledge that Bazel does not, specifically that your application does not need a dependency at runtime. It provides two main exclusion mechanisms:

- **Label-based exclusions**: Exclude specific dependencies by their Bazel label
- **Path-based exclusions**: Exclude dependencies matching path patterns in their filenames

This is useful in cases where:
- You want to exclude a dependency for a specific reason (it has a vulnerability)
- There are multiple versions of a dependency on the classpath (dupe classes) and you want to exclude the unfavored one

> **For large monorepos**: Consider using the [`dependencyset` macro](DEPENDENCYSET.md) which wraps `deps_filter` to enable centralized exclusion management and policy-as-code enforcement across hundreds of services.

## Usage

```python
load("//springboot/deps_filter_rules:deps_filter.bzl", "deps_filter")

deps_filter(
    name = "filtered_deps",
    deps = [":lib_a", ":lib_b"],
    runtime_deps = [":lib_c", ":lib_d"],
    deps_exclude_labels = [":lib_e"],  # Exclude by label
    deps_exclude_paths = ["lib_f"],    # Exclude by path pattern
    exclude_transitives = False,       # Whether to exclude transitive deps
)
```

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `deps` | `label_list` | `[]` | List of dependencies to include |
| `runtime_deps` | `label_list` | `[]` | List of runtime dependencies to include |
| `deps_exclude_labels` | `label_list` | `[]` | Dependencies to exclude from the build |
| `deps_exclude_paths` | `string_list` | `[]` | patterns for excluding dependencies |
| `exclude_transitives` | `bool` | `False` | If `True`, transitive dependencies of excluded dependencies are also removed |
| `testonly` | `bool` | `False` | Restricts usage to test environments |
| `verbose` | `bool` | `False` | Enable debug output |

## Key Features

### 1. Dual Exclusion Mechanisms
- **Label-based**: Precise exclusion using Bazel labels
- **Path-based**: Flexible exclusion using filename patterns

### 2. Transitive Dependency Control
- `exclude_transitives=False`: Only excludes direct dependencies, preserves transitives
- `exclude_transitives=True`: Excludes both direct and transitive dependencies of deps_exclude_labels
- **Important**: `exclude_transitives` only removes transitive deps of deps specified in `deps_exclude_labels`, not those matched by `deps_exclude_paths`.

### 3. JAR Type Handling
- Properly handles interface JARs (`-ijar`) and implementation JARs
- Maintains distinction between compile-time and runtime JARs
- Preserves transitive dependency relationships

### 4. Mixed Dependency Support
- Supports projects with only compile-time dependencies
- Supports projects with only runtime dependencies  
- Supports projects with mixed compile-time and runtime dependencies

## Examples

### Basic Filtering
```python
deps_filter(
    name = "basic_filter",
    deps = [":base_lib"],
    deps_exclude_labels = [":unwanted_lib"],
)
```

### Path-based Filtering
```python
deps_filter(
    name = "path_filter",
    deps = [":base_lib"],
    deps_exclude_paths = ["unwanted", "deprecated"],
)
```

### Path and Label-based Filtering
```python
deps_filter(
    name = "mixed_filter",
    deps = [":compile_lib"],
    runtime_deps = [":runtime_lib"],
    deps_exclude_labels = [":unwanted_compile"],
    deps_exclude_paths = ["unwanted_runtime"],
)
```

### With Transitive Exclusions
```python
deps_filter(
    name = "transitive_filter",
    deps = [":base_lib"],
    deps_exclude_labels = [":problematic_lib"],
    exclude_transitives = True,  # Also exclude transitives of problematic_lib
    testonly = True,  # Restrict to test environments
)
```

## Output

The rule returns a `JavaInfo` provider with:
- **Compile-time JARs**: Interface and implementation JARs for compilation
- **Runtime JARs**: Implementation JARs needed at runtime
- **Transitive dependencies**: Properly filtered transitive JARs

## Testing

Comprehensive tests are available in `tests/internal_dependencies/` covering:
- Compile-time only scenarios
- Runtime only scenarios  
- Mixed dependency scenarios
- Complex dependency graphs
- Various exclusion patterns

Run tests with:
```bash
bazel test //tests/internal_dependencies/...
```

## Integration with Other Targets

The `deps_filter` rule is designed to be referenced by other Java targets:

```python
deps_filter(
    name = "filtered_deps",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_labels = ["@maven//:some_dep_you_dont_want"],
    deps_exclude_paths = ["javax-servlet"],
    exclude_transitives = True,
)

java_library(
    name = "my_library",
    deps = [":filtered_deps"],  # Use your filtered deps here!
    # ... other attributes
)
```

## Use Cases

- **Dependency pruning**: Remove unwanted dependencies from the classpath
- **Security**: Exclude dependencies with known vulnerabilities
- **Size optimization**: Reduce JAR size by excluding unnecessary dependencies
- **Conflict resolution**: Exclude conflicting dependency versions
- **Build optimization**: Remove dependencies that cause build issues
- **Spring Boot applications**: Particularly useful for complex classpaths in Spring Boot apps

## Important: Bazel Query Limitations

**Note:** The `bazel query "deps(target)"` command does not accurately reflect the filtered deps when using `deps_filter_rule`. This is due to how bazel processes dependency queries.


## Edge Cases and Behaviors

### 1. Empty Dependencies
At least one of `deps` or `runtime_deps` must be non-empty:
```python
# Fails: Error: atleast one of 'deps' or 'runtime_deps' must be non-empty
deps_filter(
    name = "empty_deps",
    deps = [],
    runtime_deps = [],
    deps_exclude_labels = [],
    deps_exclude_paths = [],
)
```

### 2. Duplicate Exclusions
Duplicate labels or paths in exclusion lists are not allowed:
```python
# Fails: Label '@@maven//:io_micrometer_micrometer_commons' is duplicated in the 'deps_exclude_labels' attribute of rule 'duplicates'
deps_filter(
    name = "duplicates",
    deps = [":lib_a"],
    deps_exclude_labels = [
        "@maven//:io_micrometer_micrometer_commons",
        "@maven//:io_micrometer_micrometer_commons",  # Duplicate
        "@maven//:org_slf4j_jul_to_slf4j",
    ],
    deps_exclude_paths = [
        "slf4j",
    ],
)
```

### 3. Non-existent Dependencies
Excluding non-existent dependencies will cause a build failure:
```python
# Fails: Error: no such target '@@maven//:nonexistent_dependency': target 'nonexistent_dependency' not declared in package
deps_filter(
    name = "nonexistent",
    deps = [":lib_a"],
    deps_exclude_labels = ["@maven//:nonexistent_dependency"],
)
```

### 4. Complete Dependency Exclusion
Excluding all dependencies from a target will cause a build failure:
```python
# Fails: Error: org_springframework_boot_spring_boot_starter_data_jpa has no implementation jars left after filtering exclusions. Remove it from 'deps' and 'runtime_deps'.
deps_filter(
    name = "exclude_all",
    deps = [
            "@maven//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@maven//:org_springframework_boot_spring_boot_starter_security",
        ],
    deps_exclude_labels = [
            "@maven//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@maven//:org_springframework_boot_spring_boot_starter_security",
        ],  # Excluding all deps
)
```

### 5. Filtering Removes All Implementation JARs (listed in `deps` or `runtime_deps`)
When filtering removes all implementation JARs from a dependency, the build fails:
```python
# Fails: Error: com_fasterxml_jackson_core_jackson_databind has no implementation jars left after filtering exclusions. Remove it from 'deps' and 'runtime_deps'
deps_filter(
    name = "filtered_to_nothing",
    deps = [
            ":lib_a",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
        ],
    deps_exclude_paths = ["jackson"],  # Removes all implementation JARs
    exclude_transitives = True,
)
```
