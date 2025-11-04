load("@bazel_tools//tools/jdk:toolchain_utils.bzl", "find_java_toolchain")

def _filter_deps(deps_list, excludes, ctx, is_compile_time = False):
    """
    Filters dependencies based on exclusion patterns.
    
    Args:
        deps_list: List of dependencies to filter
        excludes: Dictionary of paths that should be excluded
        ctx: The rule context containing exclusion patterns
        
    Returns:
        List of filtered dependencies that don't match any exclusion patterns
    """
    filtered_deps = []
    for dep in deps_list:
        dep_path = dep.path
        if is_compile_time:
            dep_path = dep_path.replace("-ijar.jar", ".jar")
            dep_path = dep_path.replace("-hjar.jar", ".jar")
            dep_path = dep_path.replace("/header_", "/processed_")
        
        if excludes.get(dep_path, None) != None:
            if ctx.attr.verbose:
                print("[DEBUG] excluded: " + dep_path)
            pass
        else:
            # Default to including the JAR unless a pattern match excludes it
            include = True
            for pattern in ctx.attr.deps_exclude_paths:
                if dep_path.find(pattern) > -1:
                    include = False
                    break
            if include:
                filtered_deps.append(dep)    
            else:
                if ctx.attr.verbose:
                    print("[DEBUG] excluded: " + dep_path)
    return filtered_deps

def _pack_jars(jars, ctx, java_toolchain, label_name = ""):
    """
    Packs multiple JARs into a single JAR.
    
    Args:
        jars: List of JARs to pack
        ctx: Rule context
        java_toolchain: Java toolchain to use
        label_name: Name for the output JAR
    
    Returns: 
        The packed JAR
    """
    if len(jars) == 0:
        return None
    if len(jars) == 1:
        return jars[0]
        
    if not label_name:
        fail("Error: label_name cannot be empty")
        
    return java_common.pack_sources(
        ctx.actions,
        output_source_jar = ctx.actions.declare_file(label_name),
        sources = jars,
        java_toolchain = java_toolchain,
    )

def _build_exclusion_set(excluded_deps, exclude_transitives):
    """Builds a set of JAR paths to exclude from dependencies.
    
    Args:
        excluded_deps: List of dependencies to exclude
        exclude_transitives: Whether to exclude transitive deps

    Returns:
        excludes: Dictionary of JAR paths to exclude
    """
    excludes = {}
    for dep in excluded_deps:
        # Add direct JARs
        for jar in dep[JavaInfo].full_compile_jars.to_list() + dep[JavaInfo].compile_jars.to_list():
            excludes[jar.path] = True
            
        # Add transitive JARs if exclude_transitives is set to True
        if exclude_transitives:
            for jar in dep[JavaInfo].transitive_compile_time_jars.to_list() + dep[JavaInfo].transitive_runtime_jars.to_list():
                excludes[jar.path] = True
                
    return excludes

def _create_filtered_java_info(filtered_jars, filtered_compile_jar, filtered_full_compile_jar):
    """
    Creates a JavaInfo object with filtered JARs.
    
    Args:
        filtered_jars: Dictionary containing filtered JARs
        filtered_compile_jar: Filtered interace/header JAR
        filtered_full_compile_jar: Filtered implementation JAR
            
    Returns:
        JavaInfo object with filtered JARs
    """
    return JavaInfo(
        source_jar = filtered_full_compile_jar, 
        compile_jar = filtered_compile_jar,  # Interface/Header JAR
        output_jar = filtered_full_compile_jar,  # Implementation JAR
        # Note: filtered_transitive_compile_jars contains only interface jars (ijars)
        # Using impl_jar as output_jar to avoid interface jar output
        deps = [JavaInfo(source_jar = None, compile_jar = jar, output_jar = filtered_full_compile_jar) 
               for jar in filtered_jars["transitive_compile_jars"]],
        runtime_deps = [JavaInfo(source_jar = jar, compile_jar = jar, output_jar = jar) 
                      for jar in filtered_jars["transitive_runtime_jars"]],
    )

def _check_jar(full_compile_jar, compile_jar):
    dep_path = compile_jar.path
    dep_path = dep_path.replace("-ijar.jar", ".jar")
    dep_path = dep_path.replace("-hjar.jar", ".jar")
    dep_path = dep_path.replace("/header_", "/processed_")
    if dep_path == full_compile_jar.path:
        return True
    return False

def _get_compile_jar(full_compile_jar, index, compile_jars_list):
    if len(compile_jars_list) > index and _check_jar(full_compile_jar, compile_jars_list[index]):
        return compile_jars_list[index]

    for jar in compile_jars_list:
        if _check_jar(full_compile_jar, jar):
            return jar
    return None

def _aggregate_deps(declared_deps, ctx, java_toolchain):
    """
    Aggregates and processes dependencies, handling exclusions and transitive dependencies.
    
    Args:
        declared_deps: List of all explicitly declared direct dependencies to process
        ctx: The rule context containing exclusion settings
        java_toolchain: Java toolchain to use
        
    Returns:
        Tuple of (processed JavaInfo objects, filtered direct dependencies)
    """
    # Build exclusion set from excluded labels
    excludes = _build_exclusion_set(ctx.attr.deps_exclude_labels, ctx.attr.exclude_transitives)
    
    # Process each dependency:
    # 1. Extract compile and transitive JARs
    # 2. Filter out excluded JARs
    # 3. Create new JavaInfo with filtered JARs
    output_java_info_list = []
    output_direct_jars_list = []
    
    for dep in declared_deps:
        # Example: lets say dep is A, and the dependency graph is:
        #
        #     A (compile)
        #    /   \
        #   B     C (transitive compile)
        #  /       \
        # D         E (transitive runtime)
        #
        # Initial sets:
        #   - compile_jars            = [A-i.jar]
        #   - full_compile_jars       = [A.jar]
        #   - transitive_compile_jars = [A-i.jar, B-i.jar, C-i.jar]
        #   - transitive_runtime_jars = [A.jar, B.jar, C.jar, D.jar, E.jar]
        #
        # If C.jar and D.jar are excluded:
        #   - filtered_compile_jars            = [A-i.jar]
        #   - filtered_full_compile_jars       = [A.jar]
        #   - filtered_transitive_compile_jars = [A-i.jar, B-i.jar]         # C-i.jar removed
        #   - filtered_transitive_runtime_jars = [A.jar, B.jar, E.jar]      # C.jar, D.jar removed
        #
        # If exclude_transitives=True and C.jar is excluded:
        #   - filtered_compile_jars            = [A-i.jar]
        #   - filtered_full_compile_jars       = [A.jar]
        #   - filtered_transitive_compile_jars = [A-i.jar, B-i.jar]
        #   - filtered_transitive_runtime_jars = [A.jar, B.jar]             # E.jar dropped (reachable only via C)
        #
        # dep_java_info will be constructed with:
        #   - source_jar   = A.jar
        #   - compile_jar  = A-i.jar
        #   - output_jar   = A.jar
        #   - deps         = [JavaInfo for A-i.jar, B-i.jar]
        #   - runtime_deps = [JavaInfo for A.jar, B.jar, E.jar]  # E.jar not included if exclude_transitives=True
        
        # JAR Types:
        # - full_compile_jars: Implementation JARs (e.g., lib_A.jar)
        # - compile_jars: Interface/Header JARs (e.g., lib_A-ijar.jar)
        # - transitive_compile_jars: Interface JARs from transitive deps
        # - transitive_runtime_jars: Implementation JARs from transitive deps
        
        filtered_jars = {
            "compile_jars": _filter_deps(dep[JavaInfo].compile_jars.to_list(), excludes, ctx, is_compile_time = True),
            "full_compile_jars": _filter_deps(dep[JavaInfo].full_compile_jars.to_list(), excludes, ctx),
            "transitive_compile_jars": _filter_deps(dep[JavaInfo].transitive_compile_time_jars.to_list(), excludes, ctx, is_compile_time = True),
            "transitive_runtime_jars": _filter_deps(dep[JavaInfo].transitive_runtime_jars.to_list(), excludes, ctx),
        }
        
        if len(filtered_jars["full_compile_jars"]) == 0:
            fail("Error: " + dep.label.name + " has no implementation jars left after filtering exclusions. Remove it from 'deps' and 'runtime_deps'.")

        for index in range(len(filtered_jars["full_compile_jars"])):
            filtered_full_compile_jar = filtered_jars["full_compile_jars"][index]
            filtered_compile_jar = _get_compile_jar(filtered_full_compile_jar, index, filtered_jars["compile_jars"])
            if filtered_compile_jar == None:
                print("[DEBUG] No compile jar found for:" + filtered_full_compile_jar.path + ". Check compile jars list:" + str(filtered_jars["compile_jars"]))

            # Create JavaInfo with filtered JARs
            java_info = _create_filtered_java_info(filtered_jars, filtered_compile_jar, filtered_full_compile_jar)
            output_java_info_list.append(java_info)
            output_direct_jars_list.append(filtered_full_compile_jar)

    return output_java_info_list, output_direct_jars_list


def _deps_filter_impl(ctx):
    """
    Implementation of the deps_filter rule that filters out specified dependencies and JARs.
    
    This rule filters out specified deps and JARs from the compile-time 
    and runtime deps. It utilizes the 'deps_exclude_labels' attribute to omit 
    specific JAR labels and the 'deps_exclude_paths' attribute to exclude 
    deps based on partial paths in their filenames. If 'exclude_transitives'
    is set to `True` (default: `False`), any transitive deps solely required
    by the deps in 'deps_exclude_labels' are also excluded. These exclusions ensure
    the final collection includes only the necessary elements for the build
    process, eliminating problematic deps.
    """ 
    
    if len(ctx.attr.deps) == 0 and len(ctx.attr.runtime_deps) == 0:
        fail("Error: atleast one of 'deps' or 'runtime_deps' must be non-empty")
    
    java_toolchain = find_java_toolchain(ctx, ctx.attr._java_toolchain)
    compile_deps_info, compile_jars = _aggregate_deps(ctx.attr.deps, ctx, java_toolchain)
    runtime_deps_info, runtime_jars = _aggregate_deps(ctx.attr.runtime_deps, ctx, java_toolchain)

    if len(compile_jars) == 0 and len(runtime_jars) == 0:
        fail("Error: The rule must return at least one compile-time or runtime JAR. Excluding all compile-time or runtime dependencies is not allowed.")

    if len(compile_jars) == 0:
        # Only runtime deps present
        output_jar = runtime_jars[0]
        return [
            DefaultInfo(files = depset([])),
            JavaInfo(
                compile_jar = None,
                output_jar = output_jar,
                # exports = runtime_deps_info,
                runtime_deps = runtime_deps_info,
            ),
        ]
    else:
        # Compile-time deps present
        output_jar = compile_jars[0]
        return [
            DefaultInfo(files = depset(compile_jars)),
            JavaInfo(
                source_jar = output_jar,
                compile_jar = None,
                output_jar = output_jar,
                exports = compile_deps_info,
                runtime_deps = compile_deps_info + runtime_deps_info,
                deps = compile_deps_info,
            ),
        ]


# Rule definition for filtering dependencies
deps_filter = rule(
    implementation = _deps_filter_impl,
    attrs = {
        "deps": attr.label_list(providers = [java_common.provider], allow_empty = True),
        "runtime_deps": attr.label_list(providers = [java_common.provider], allow_empty = True),
        "deps_exclude_labels": attr.label_list(providers = [java_common.provider], allow_empty = True),
        "deps_exclude_paths": attr.string_list(),
        "exclude_transitives": attr.bool(default = False),
        "verbose": attr.bool(default = False),
        "_java_toolchain": attr.label(default = "@bazel_tools//tools/jdk:current_java_toolchain"),
    },    
    toolchains = ["@bazel_tools//tools/jdk:toolchain_type"],
)

def deps_filter_rule(name, deps, runtime_deps, deps_exclude_labels = [], deps_exclude_paths = [], exclude_transitives = False, testonly = False, verbose = False):
    # We will not be using this as we planned to use dependencyset for both deps and runtime_deps.
    # Keeping it here for now.
    deps_filter(
        name = name + "_compile",
        deps = deps,
        deps_exclude_labels = deps_exclude_labels,
        deps_exclude_paths = deps_exclude_paths,
        exclude_transitives = exclude_transitives,
        verbose = verbose,
        testonly = testonly,
    )

    deps_filter(
        name = name + "_runtime",
        runtime_deps = runtime_deps,
        deps_exclude_labels = deps_exclude_labels,
        deps_exclude_paths = deps_exclude_paths,
        exclude_transitives = exclude_transitives,
        verbose = verbose,
        testonly = testonly,
    )