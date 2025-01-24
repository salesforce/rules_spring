def _depaggregator_rule_impl(merged, deps, ctx):
    """
    This method processes declared dependencies and their transitive closures 
    to assemble a cohesive set of jars essential for the build process. During 
    this process, it excludes all the transitives of dependencies specified 
    in 'deps_to_exclude_transitives'.
    """
    jars = []
    excludes = {}

    # exclude transitives of the specified deps
    deps_info_to_exclude_transitives = []
    for dep_info in ctx.attr.deps_to_exclude_transitives:
        deps_info_to_exclude_transitives.append(str(dep_info))
        for transitive_jar in dep_info[JavaInfo].transitive_runtime_jars.to_list():
            excludes[transitive_jar.path] = True

    # process the deps whose transitives are to be kept
    for dep_info in deps:
        # always keep the specified deps
        for compile_jar in dep_info[JavaInfo].full_compile_jars.to_list():
            if compile_jar.path in excludes:
                excludes[compile_jar.path] = False
                
        if str(dep_info) not in deps_info_to_exclude_transitives:
            for transitive_jar in dep_info[JavaInfo].transitive_runtime_jars.to_list():
                if transitive_jar.path in excludes:
                    excludes[transitive_jar.path] = False
            
            
    for dep in merged.transitive_runtime_jars.to_list():
        if excludes.get(dep.path, None) != None and excludes[dep.path]:
            pass
        else:
            jars.append(dep)
    return jars

def _deps_filter_disable_transitives_impl(ctx):
    """
    This rule filters out transitives of the specified dependencies and JARs 
    from the compile-time and runtime dependencies. 
    """ 
    if len(ctx.attr.deps) == 0:
        fail("Error: 'deps' cannot be an empty list")

    # deps whose transitives are to be excluded must be a subset of deps + runtime_deps 
    deps_info_list = []
    for dep_info in ctx.attr.deps:
        deps_info_list.append(str(dep_info))

    for dep_info in ctx.attr.runtime_deps:
        deps_info_list.append(str(dep_info))

    for dep_info in ctx.attr.deps_to_exclude_transitives:
        if str(dep_info) not in deps_info_list:
            fail("Error: 'deps' specified in deps_to_exclude_transitives must be subset of deps + runtime_deps")   

    
    # magical incantation for getting upstream transitive closure of java deps
    merged = java_common.merge([dep[java_common.provider] for dep in ctx.attr.deps])
    runtime_dep_merged = java_common.merge([runtime_dep[java_common.provider] for runtime_dep in ctx.attr.runtime_deps])

    compile_time_jars = _depaggregator_rule_impl(merged, ctx.attr.deps, ctx)
    runtime_jars = _depaggregator_rule_impl(runtime_dep_merged, ctx.attr.runtime_deps, ctx)

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


deps_filter_disable_transitives = rule(
    implementation = _deps_filter_disable_transitives_impl,
    attrs = {
        "deps": attr.label_list(providers = [java_common.provider]),
        "runtime_deps": attr.label_list(providers = [java_common.provider], allow_empty = True),
        "deps_to_exclude_transitives": attr.label_list(providers = [java_common.provider], allow_empty = True),
    },
)