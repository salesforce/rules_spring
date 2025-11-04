# dependencyset Macro

A wrapper around `deps_filter` that scales dependency filtering across your entire monorepo. Enforces consistent dependency management patterns.

## Why dependencyset?

For large monorepos with hundreds of services, managing exclusions at each `deps_filter` call is impractical. `dependencyset` enables:

- **Centralized exclusions**: Security and platform teams maintain shared exclusion lists (CVEs, deprecated libs, etc.)
- **Local flexibility**: Services and libraries can add target-level exclusions when needed
- **Standardized usage**: All services must use `dependencyset`, ensuring consistent classpaths

## How It Works

The `dependencyset` macro automatically detects whether to apply exclusions to `deps` or `runtime_deps` based on the target name:

```python
load("@rules_spring//springboot/deps_filter_rules:dependencyset.bzl", "dependencyset")

# Automatically treats as deps (compile-time)
dependencyset(
    name = "deps",
    items = [":lib_a", ":lib_b"],
    deps_exclude_labels = [":local_exclude"],  # Additional exclusions other than centralized exclusions
)

# Automatically treats as runtime_deps (name contains "runtime_deps")
dependencyset(
    name = "runtime_deps",
    items = [":lib_c", ":lib_d"],
    # Centralized exclusions automatically applied here
)
```

## Before vs After

### Before: Manual Dependency Lists

```python
deps = [
    # list of deps
],

runtime_deps = [
    # list of runtime deps
],

java_library(
    name = "base_lib",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [":deps"],
    runtime_deps = [":runtime_deps"],
)
```

### After: Standardized Dependency Sets

```python
load("@rules_spring//springboot/deps_filter_rules:dependencyset.bzl", "dependencyset")

dependencyset(
    name = "deps",
    items = [
        # list of deps
    ],
    # Centralized exclusions automatically applied
    # Optional: deps_exclude_labels = [":additional_exclusions"]
)

dependencyset(
    name = "runtime_deps",
    items = [
        # list of runtime deps
    ],
)

java_library(
    name = "base_lib",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [":deps"],
    runtime_deps = [":runtime_deps"],
)
```

**Important**: This structure enforces all services/libs to use `dependencyset` instead of raw dependency lists. This standardized approach provides better control over dependencies across large monorepos.

## Problems It Helps Fix

✓ **Eliminates classpath conflicts**
- Prevents duplicate classes from conflicting versions
- Removes version skew issues

✓ **Stops test flakiness**
- Aligns test and production classpaths
- Eliminates "works in test, fails in prod" surprises

✓ **Accelerates security response**
- Centralized CVE exclusions remove vulnerable jars automatically
- Enables faster remediation across the fleet

✓ **Removes dependency noise**
- Filters out unwanted transitives you don't actually use
- Creates cleaner, smaller classpaths

✓ **Ensures consistent dependency hygiene**
- Standardized patterns enforce clean classpaths everywhere
- Provides centralized control with local flexibility

## Adoption Path

1. **Introduce dependencyset macro**: Add wrapper around `deps_filter` rule in your repo
2. **Seed central exclude lists**: Security + platform teams define shared exclusions
3. **Migrate targets**: Convert services/libs to use `dependencyset`
4. **Add target-level exclusions**: Allow local exclusions where needed

## Customization

To add centralized exclusions, modify the `dependencyset` macro in your repository to include default exclusion lists:

```python
def dependencyset(name, items, deps_exclude_labels = [], ...):
    # Add your centralized exclusions here
    central_excludes = [
        "@maven//:vulnerable_lib",
        # ... more centralized exclusions
    ]
    
    deps_exclude_labels = central_excludes + deps_exclude_labels
    
    return deps_filter(
        name = name,
        items = items,
        deps_exclude_labels = deps_exclude_labels,
        # ...
    )
```

## See Also

- [`deps_filter` rule documentation](README.md): The underlying rule that powers `dependencyset`
- [dependencyset tests](../../tests/dependencyset/): Comprehensive test examples

