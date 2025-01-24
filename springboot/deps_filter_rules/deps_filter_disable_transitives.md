_# `deps_filter` Rule
## Overview
The `deps_filter_disable_transitives` rule lets you control transitive dependencies in your project. It disables the 
resolution of transitive dependencies for specific dependencies, which is useful when you need to exclude 
problematic transitive dependencies, similar to [this](https://docs.gradle.org/current/userguide/resolution_rules.html#sec:disabling-resolution-transitive-dependencies) Gradle's transitive dependencies resolution rule.


## Rule Definition
This rule filters out transitives of the specified dependencies and JARs
from the compile-time and runtime dependencies.

```
deps_filter_disable_transitives(
    name = <string>,
    deps = <list of labels>,
    runtime_deps = <list of labels>,
    deps_to_exclude_transitives = <list of labels>,
    testonly = <boolean, default = False>,
)
```

### Attributes:
- `name` (Required): Name of the target.
- `deps` (Required): List of dependencies to include.
- `runtime_deps` (Optional): List of runtime dependencies to include.
- `deps_to_exclude_transitives` (Optional): List of dependencies for which transitive dependencies should be 
  excluded. (must be a subset of `deps` + `runtime_deps`)
- `testonly` (Optional, Default: False): Restricts usage to test environments.


## Adding to Your Project
### Step 1: Add `rules_spring` to your workspace:
Follow the steps mentioned [here](../../README.md#loading-the-spring-rules-in-your-workspace). 

### Step 2: Load the `deps_filter_disable_transitives` rule in your BUILD file:
```
load("@rules_spring//springboot/deps_filter_rules:deps_filter_disable_transitives.bzl", "deps_filter_disable_transitives")
```

### Step 3: Use the `deps_filter_disable_transitives` rule, and reference it by other targets (e.g., `java_library`) to manage dependencies:
```
load("@rules_spring//springboot/deps_filter_rules:deps_filter_disable_transitives.bzl", "deps_filter_disable_transitives")

deps = [
    ...
]

runtime_deps = [
    ...
]

deps_filter_disable_transitives(
    name = "filtered_deps",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_to_exclude_transitives = ["@maven//:some_dep_whose_transitives_you_dont_want",]
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
### Example 1
```
deps_filter_disable_transitives(
    name = "filtered_deps_disable_transitives_case_A",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    deps_to_exclude_transitives = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
)
```
#### Behavior:
The build includes `@maven//:org_springframework_spring_jdbc` and `@maven//:org_springframework_spring_web`, but all transitive dependencies of both are excluded.

### Example 2
```
deps_filter_disable_transitives(
    name = "filtered_deps_disable_transitives_case_A",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    deps_to_exclude_transitives = [
        "@maven//:org_springframework_spring_web",
    ],
)
```
#### Behavior:
- The build includes `@maven//:org_springframework_spring_jdbc` and its transitive dependencies, as well as `@maven//:org_springframework_spring_web`.
- Transitive dependencies of `@maven//:org_springframework_spring_web` are excluded, but transitive dependencies of 
  `@maven//:org_springframework_spring_jdbc` are included.

### Example 3
```
deps_filter_disable_transitives(
    name = "filtered_deps_disable_transitives_case_A",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
)
```
#### Behavior:
- The build includes `@maven//:org_springframework_spring_jdbc` and `@maven//:org_springframework_spring_web`, along with their respective transitive dependencies.
- No dependencies are excluded.
