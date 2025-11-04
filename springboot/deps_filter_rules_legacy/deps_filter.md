# `deps_filter` Rule
## Overview
The `deps_filter` rule provides a way to filter java dependencies in Bazel projects, ensuring only the necessary ones 
are included in the build. This rule can be referenced by other java targets, such as `java_library` and helps to 
remove problematic or unwanted dependencies, offering better control over dependency graphs. 

It removes Java dependencies from your dependency graph. This is done when you have knowledge that Bazel does not, 
specifically that your application does not need a dependency at runtime.

This is useful in cases where:
- You want to exclude a dependency for a specific reason (it has a vulnerability)
- There are multiple versions of a dependency on the classpath (dupe classes) and you want to exclude the unfavored one.


## Rule Definition
The rule is defined as `dep_filter` in `deps_filter.bzl`. It filters out specified deps and JARs from the compile-time and runtime deps. It utilizes the `deps_exclude_labels` attribute to omit specific JAR labels and the `deps_exclude_paths` attribute to exclude dependencies based on partial paths in their filenames. If `exclude_transitives` is set to `True` (default: `False`), any transitive dependencies solely required by the dependencies in `deps_exclude_labels` are also excluded. These exclusions ensure the final collection includes only the necessary elements for the build process, eliminating problematic dependencies.

```
deps_filter(
    name = <string>,
    deps = <list of labels>,
    runtime_deps = <list of labels>,
    deps_exclude_labels = <list of labels>,
    deps_exclude_paths = <list of strings>,
    exclude_transitives = <boolean, default = False>,
    testonly = <boolean, default = False>,
)
```


### Attributes:
- `name` (Required): Name of the target.
- `deps` (Required): List of dependencies to include.
- `runtime_deps` (Optional): List of runtime dependencies to include.
- `deps_exclude_labels` (Optional): Dependencies to exclude from the build.
- `deps_exclude_paths` (Optional): Filename patterns for excluding dependencies.
- `exclude_transitives` (Optional, Default: `False`): If `True`, transitive dependencies of excluded dependencies are 
  also removed, unless needed by other included dependencies.
- `testonly` (Optional, Default: `False`): Restricts usage to test environments.

### Behavior
1. **Excludes Specific Dependencies**:
   - Removes any dependencies listed in `deps_exclude_labels`.
2. **Handles Transitive Dependencies**:
   - If `exclude_transitives` is `True`, transitive dependencies that are only required by excluded dependencies are removed.
   - If `False`, transitive dependencies remain in the build.
3. **Filename-Based Exclusions**:
   - Dependencies matching patterns in `deps_exclude_paths` are excluded.


## Adding to Your Project
### Step 1: Add `rules_spring` to your workspace:
Follow the steps mentioned [here](../../README.md#loading-the-spring-rules-in-your-workspace). 

### Step 2: Load the `deps_filter` rule in your BUILD file:
```
load("@rules_spring//springboot/deps_filter_rules_legacy:deps_filter.bzl", "deps_filter")
```

### Step 3: Define and reference the `deps_filter` rule in other targets (e.g., `java_library`) to manage their dependencies:
```
load("@rules_spring//springboot/deps_filter_rules_legacy:deps_filter.bzl", "deps_filter")

deps = [
    ...
]

runtime_deps = [
    ...
]

deps_filter(
    name = "filtered_deps",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_labels = [
        "@maven//:some_dep_you_dont_want",  
    ],
    deps_exclude_paths = [
        "javax-servlet",
    ],
    exclude_transitives = True,
)

java_library(
    name = "my_library",
    deps = [":filtered_deps"], # <--- KEY LINE: USE YOUR FILTERED DEPS HERE!
    ...
)

# the filter is not specific to springboot apps, but is often used for springboot
# due to the complexity of classpaths in springboot apps
salesforce_springboot(
    name = "myspringboot_app",
    java_library = ":my_library",
)

```

## Example Usage
### Example 1: Without Excluding Transitives
```
deps_filter(
    name = "filtered_deps",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    deps_exclude_labels = [
        "@maven//:org_springframework_spring_web",
    ],
    exclude_transitives = False,
    testonly = True,
)
```
#### Behavior:
`org_springframework_spring_web` is excluded, but its transitive dependencies remain.

### Example 2: With Excluding Transitives
```
deps_filter(
    name = "filtered_deps",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    deps_exclude_labels = [
        "@maven//:org_springframework_spring_web",
    ],
    exclude_transitives = True,
    testonly = True,
)
```
#### Behavior:
Both `org_springframework_spring_web` and its transitive dependencies are excluded, except those required by `org_springframework_spring_jdbc`.
