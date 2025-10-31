def _depaggregator_rule_impl(merged, ctx):
    """
    This method processes declared deps and their transitive closures 
    to assemble a cohesive set of jars essential for the build process. During 
    this process, it excludes deps specified in 'deps_exclude_labels', which 
    lists jar labels to be omitted from packaging due to issues that cannot 
    be resolved upstream. If 'exclude_transitives' is set to 'true' (default:
    'false'), any transitive deps that are only required by excluded deps
    are also omitted, ensuring that only necessary transitives are included 
    in the final package. It uses 'deps_exclude_paths' to exclude deps 
    based on partial filename matches, ensuring problematic files are also 
    excluded from the build. This method ensures that only necessary 
    deps are included for the build process.
    """
    exclude_transitives = ctx.attr.exclude_transitives

    # list to store jars to be included and a dictionary to track excluded jars
    jars = []
    excludes = {}

    if exclude_transitives:
        # Dictionary to track transitive dependency paths that should be excluded
        transitives_excludes = {}

        # List to store deps info for deps present in 'deps_exclude_labels'
        direct_excludes = []

    # Iterate through the deps specified in 'deps_exclude_labels' to collect 
    # jars that should be excluded from the final set.

    for exclusion_info in ctx.attr.deps_exclude_labels:    
        # For each excluded dependency, add its compile-time JARs to the exclusion list
        for compile_jar in exclusion_info[JavaInfo].full_compile_jars.to_list():
            excludes[compile_jar.path] = True
        
        if exclude_transitives:
            # Mark all transitives of the current dependency as excluded
            # This list will be updated later based on transitives of non-excluded deps
            direct_excludes.append(str(exclusion_info))
            for transitive_jar in exclusion_info[JavaInfo].transitive_runtime_jars.to_list():
                transitives_excludes[transitive_jar.path] = True

    if exclude_transitives:
        # Iterate over all deps, for non-excluded deps, mark their transitives as included.
        for deps_info in ctx.attr.deps:
            # skip the current dependency if it is listed in 'deps_exclude_labels'.
            if str(deps_info) in direct_excludes:
                continue     
                    
            # For non-excluded deps, mark them and their transitive deps as included (not to be excluded)
            # (transitive_runtime_jars includes both the primary JAR and its transitive deps)
            for transitive_jar in deps_info[JavaInfo].transitive_runtime_jars.to_list():
                if transitive_jar.path in transitives_excludes:
                    transitives_excludes[transitive_jar.path] = False

        # update the excludes list
        for dep_path in transitives_excludes:            
            # print("Transitive:", str(dep_path), "is excluded", transitives_excludes[dep_path])
            if transitives_excludes[dep_path]:
                excludes[dep_path] = True
    
    # compute the final set of jars
    for dep in merged.transitive_runtime_jars.to_list():
        # If the current JAR is in the exclusion list, skip it (do not include it)
        if excludes.get(dep.path, None) != None:
             pass
        else:
            # Default to including the JAR unless a pattern match excludes it
            include = True
            for pattern in ctx.attr.deps_exclude_paths:
                if dep.path.find(pattern) > -1:
                    include = False
                    break
            if include:
                jars.append(dep)

    return jars

def _deps_filter_impl(ctx):
    """
    This rule filters out specified deps and JARs from the compile-time 
    and runtime deps. It utilizes the 'deps_exclude_labels' attribute to omit 
    specific JAR labels and the 'deps_exclude_paths' attribute to exclude 
    deps  based on partial paths in their filenames. If 'exclude_transitives'
    is set to `True` (default: `False`), any transitive deps solely required
    by the deps in 'deps_exclude_labels' are also excluded. These exclusions ensure
    the final collection includes only the necessary elements for the build
    process, eliminating problematic deps.
    """ 

    if len(ctx.attr.deps) == 0:
        fail("Error: 'deps' cannot be an empty list")
    
    # magical incantation for getting upstream transitive closure of java deps
    merged = java_common.merge([dep[java_common.provider] for dep in ctx.attr.deps])
    runtime_dep_merged = java_common.merge([runtime_dep[java_common.provider] for runtime_dep in ctx.attr.runtime_deps])

    compile_time_jars = _depaggregator_rule_impl(merged, ctx)
    runtime_jars = _depaggregator_rule_impl(runtime_dep_merged, ctx)

    if len(compile_time_jars) == 0:
        fail("Error: The rule must return at least one compile-time JAR. Excluding all compile-time dependencies is not allowed.")

    return [
            DefaultInfo(files = depset(compile_time_jars,)),
            JavaInfo(
                compile_jar = None,
                output_jar = compile_time_jars[0],         # output jar must be non-empty, adding a dummy value to it
                exports = [JavaInfo(source_jar = jar, compile_jar = jar, output_jar = jar) for jar in compile_time_jars],
                runtime_deps = [JavaInfo(source_jar = jar, compile_jar = jar, output_jar = jar) for jar in
                                runtime_jars],
                deps = [JavaInfo(source_jar = jar, compile_jar = jar, output_jar = jar) for jar in compile_time_jars],
            ),
            ]


deps_filter = rule(
    implementation = _deps_filter_impl,
    attrs = {
        "deps": attr.label_list(providers = [java_common.provider]),
        "runtime_deps": attr.label_list(providers = [java_common.provider], allow_empty = True),
        "deps_exclude_labels": attr.label_list(providers = [java_common.provider], allow_empty = True),
        "deps_exclude_paths": attr.string_list(),
        "exclude_transitives": attr.bool(default = False),
    },
)