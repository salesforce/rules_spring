load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//springboot/deps_filter_rules/tests/test_utils:verification_utils.bzl",
        "verify_jars", 
        "verify_runtime_and_compile_jars",
        "verify_jars_and_dropped_counts", 
        "verify_dropped_counts",
        "update_jar_name",
)


def _test_no_filtering(ctx):
    """
    Tests that deps_filter preserves all dependencies when no exclusions are applied.
    
    Dependency Graph: 
        test_lib
        /     \\
       A       G
      / \\    /
     B   E   /
     |   | /
     |   F 
      \\  
       C
       |
       D
    
    Expected: All JARs from java_library must match deps_filter:
        - full_compile_jars: Implementation JARs (e.g., liblib_a.jar)
        - compile_jars: Interface JARs (e.g., liblib_a-hjar.jar)
        - transitive_compile_time_jars: Interface JARs from transitive deps
        - transitive_runtime_jars: Implementation JARs from transitive deps
    """
    env = unittest.begin(ctx)
    java_lib_info = ctx.attr.java_library[JavaInfo]
    deps_filter_info = ctx.attr.java_library_dependencyset[JavaInfo]
    
    # Verify all JAR fields match between java_library and deps_filter
    jar_fields = [
        "full_compile_jars",              # Implementation JARs
        "compile_jars",                   # Interface JARs
        "transitive_compile_time_jars",   # Transitive interface JARs
        "transitive_runtime_jars"         # Transitive implementation JARs
    ]

    for jar_field in jar_fields:
        java_lib_jars = getattr(java_lib_info, jar_field)
        deps_filter_jars = getattr(deps_filter_info, jar_field)
        asserts.equals(env, type(java_lib_jars), type(deps_filter_jars), 
            "JAR type mismatch: {} vs deps_filter".format(jar_field))
        java_lib_jars_list = [jar.basename for jar in java_lib_jars.to_list()]        
        deps_filter_jars_list = [jar.basename for jar in deps_filter_jars.to_list()]
        # Normalize output jar naming difference between dependencyset consumer and base_lib
        update_jar_name("libruntime_no_filtering_test_lib", "libbase_lib", deps_filter_jars_list)
        asserts.equals(env, java_lib_jars_list, deps_filter_jars_list,
            "JAR contents mismatch: {} vs deps_filter".format(jar_field))

    return unittest.end(env)

no_filtering_test = unittest.make(_test_no_filtering, attrs = {
    "java_library": attr.label(providers = [JavaInfo]),
    "java_library_dependencyset": attr.label(providers = [JavaInfo]),
})

def _test_filtered_deps(ctx):
    """
    Tests basic dependency filtering with label-based exclusions.
    
    Dependency Graph:
         test_lib      
            |
 dependencyset("runtime_deps")
        /     \\
       A       I
      / \\    /
     B   E   G
     |   | /
     |   F 
      \\  
       C
       |
       D

    Dependencyset Input:
        items = [":lib_a", ":lib_i"]
        deps_exclude_labels = [":lib_b", ":lib_g"]
        deps_exclude_paths = []
        exclude_transitives = False

    Expected Output:
        JARs preserved:
        - test_lib, A, I, E, F, C, D (runtime)
        - no compile-time jars present
        JARs excluded:
        - B, G and their transitive deps
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]

    expected_compile_jars = [
        "libruntime_exclude_b_g_test_lib-hjar.jar",
    ]

    expected_full_compile_jars = [
        "libruntime_exclude_b_g_test_lib.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "libruntime_exclude_b_g_test_lib.jar",
        "liblib_a.jar",
        "liblib_i.jar",
        "liblib_e.jar",
        "liblib_f.jar",
        "liblib_c.jar",
        "liblib_d.jar"
    ]
    
    expected_transitive_compile_jars = [
        "libruntime_exclude_b_g_test_lib-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

filtered_deps_test = unittest.make(_test_filtered_deps, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
})

def _test_filtered_deps_exclude_transitive(ctx):
    """
    Tests dependency filtering with transitive exclusions.
    
    Dependency Graph:
         test_lib      
            |
 dependencyset("runtime_deps")
        /     \\
       A       I
      / \\    /
     B   E   G
     |   | /
     |   F 
      \\  
       C
       |
       D

    Dependencyset Input:
        items = [":lib_a", ":lib_i"]
        deps_exclude_labels = [":lib_b", ":lib_g"]
        deps_exclude_paths = []
        exclude_transitives = True

    Expected Output:
        JARs preserved:
        - test_lib, A, I, E (runtime)
        - no compile-time jars present
        JARs excluded:
        - B, G and all transitive deps
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    expected_compile_jars = [
        "libruntime_exclude_b_g_transitives_test_lib-hjar.jar",
    ]

    expected_full_compile_jars = [
        "libruntime_exclude_b_g_transitives_test_lib.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "libruntime_exclude_b_g_transitives_test_lib.jar",
        "liblib_a.jar",
        "liblib_i.jar",
        "liblib_e.jar",
    ]
    
    expected_transitive_compile_jars = [
        "libruntime_exclude_b_g_transitives_test_lib-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

filtered_deps_exclude_transitive_test = unittest.make(_test_filtered_deps_exclude_transitive, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
})

def _test_path_based_exclusions(ctx):
    """
    Tests filtering based on path patterns in deps_exclude_paths.
    
    Dependency Graph:
         test_lib      
            |
 dependencyset("runtime_deps")
        /     \\
       A       I
      / \\    /
     B   E   G
     |   | /
     |   F 
      \\  
       C
       |
       D

    Dependencyset Input:
        items = [":lib_a", ":lib_i"]
        deps_exclude_labels = []
        deps_exclude_paths = ["lib_b", "lib_f"]
        exclude_transitives = False

    Expected Output:
        JARs preserved:
        - All JARs not matching path patterns
        JARs excluded:
        - JARs matching paths "lib_b" and "lib_f"
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    expected_compile_jars = [
        "libruntime_exclude_paths_test_lib-hjar.jar",
    ]

    expected_full_compile_jars = [
        "libruntime_exclude_paths_test_lib.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "libruntime_exclude_paths_test_lib.jar",
        "liblib_a.jar",
        "liblib_i.jar",
        "liblib_e.jar",
        "liblib_c.jar",
        "liblib_d.jar",
        "liblib_g.jar"
    ]
    
    expected_transitive_compile_jars = [
        "libruntime_exclude_paths_test_lib-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

path_based_exclusions_test = unittest.make(_test_path_based_exclusions, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
})

def _test_interface_implementation_jars(ctx):
    """
    Tests proper handling of interface (-hjar) and implementation JARs.
    
    Dependency Graph:
         test_lib      
            |
 dependencyset("runtime_deps")
        /     \\
       A       I
      / \\    /
     B   E   G
     |   | /
     |   F 
      \\  
       C
       |
       D

    Dependencyset Input:
        items = [":lib_a", ":lib_i"]
        deps_exclude_labels = [":lib_b", ":lib_g"]
        deps_exclude_paths = []
        exclude_transitives = False

    Expected Output:
        Interface JARs (compile_jars):
        - []

        Implementation JARs (full_compile_jars):
        - libtest_lib.jar
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    compile_jars = sorted([jar.basename for jar in javainfo_filtered.compile_jars.to_list()])
    full_compile_jars = sorted([jar.basename for jar in javainfo_filtered.full_compile_jars.to_list()])
    
    expected_compile_jars = [
        "libruntime_interface_impl_test_lib-hjar.jar",
    ]
    expected_full_compile_jars = [
        "libruntime_interface_impl_test_lib.jar",
    ]
    
    asserts.equals(env, compile_jars, expected_compile_jars)
    asserts.equals(env, full_compile_jars, expected_full_compile_jars)
    return unittest.end(env)

interface_implementation_jars_test = unittest.make(_test_interface_implementation_jars, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
})

def _test_multiple_exclusions_with_transitive(ctx):
    """
    Tests multiple exclusion levels with exclude_transitives=True.
    
    Dependency Graph:
         test_lib      
            |
 dependencyset("runtime_deps")
        /     \\
       A       I
      / \\    /
     B   E   G
     |   | /
     |   F 
      \\  
       C
       |
       D

    Dependencyset Input:
        items = [":lib_a", ":lib_i"]
        deps_exclude_labels = [":lib_b"]
        deps_exclude_paths = ["lib_g"]
        exclude_transitives = True

    Expected Output:
        JARs preserved:
        - test_lib, A, I, E, F (runtime)
        - no compile-time jars present
        JARs excluded:
        - B, G and all transitive deps
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    expected_compile_jars = [
        "libruntime_multi_excl_transitives_test_lib-hjar.jar",
    ]

    expected_full_compile_jars = [
        "libruntime_multi_excl_transitives_test_lib.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "libruntime_multi_excl_transitives_test_lib.jar",
        "liblib_a.jar",
        "liblib_i.jar",
        "liblib_e.jar",
        "liblib_f.jar",
    ]
    
    expected_transitive_compile_jars = [
        "libruntime_multi_excl_transitives_test_lib-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

def _test_multiple_exclusions_without_transitive(ctx):
    """
    Tests multiple exclusion levels with exclude_transitives=False.
    
    Dependency Graph:
         test_lib      
            |
 dependencyset("runtime_deps")
        /     \\
       A       I
      / \\    /
     B   E   G
     |   | /
     |   F 
      \\  
       C
       |
       D

    Dependencyset Input:
        items = [":lib_a", ":lib_i"]
        deps_exclude_labels = [":lib_b"]
        deps_exclude_paths = ["lib_g"]
        exclude_transitives = False

    Expected Output:
        JARs preserved:
        - test_lib, A, I, E, F, C, D (runtime)
        - no compile-time jars present
        JARs excluded:
        - B, G (direct deps only)
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    expected_compile_jars = [
        "libruntime_multi_excl_no_transitives_test_lib-hjar.jar",
    ]

    expected_full_compile_jars = [
        "libruntime_multi_excl_no_transitives_test_lib.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "libruntime_multi_excl_no_transitives_test_lib.jar",
        "liblib_a.jar",
        "liblib_i.jar",
        "liblib_e.jar",
        "liblib_f.jar",
        "liblib_c.jar",
        "liblib_d.jar",
    ]
    
    expected_transitive_compile_jars = [
        "libruntime_multi_excl_no_transitives_test_lib-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

multiple_exclusions_with_transitive_test = unittest.make(_test_multiple_exclusions_with_transitive, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
})

multiple_exclusions_without_transitive_test = unittest.make(_test_multiple_exclusions_without_transitive, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
})

def _test_empty_exclusion_lists(ctx):
    """
    Tests behavior when exclusion lists are empty.
    
    Dependency Graph:
         test_lib      
            |
 dependencyset("runtime_deps")
        /     \\
       A       I
      / \\    /
     B   E   G
     |   | /
     |   F 
      \\  
       C
       |
       D

    Dependencyset Input:
        items = [":lib_a", ":lib_i"]
        deps_exclude_labels = []
        deps_exclude_paths = []
        exclude_transitives = False

    Expected Output:
        All JARs preserved:
        - test_lib, A, I, B, C, D, E, F, G (runtime)
        - no compile-time jars present
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    expected_compile_jars = [
        "libruntime_empty_exclusions_test_lib-hjar.jar",
    ]

    expected_full_compile_jars = [
        "libruntime_empty_exclusions_test_lib.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "libruntime_empty_exclusions_test_lib.jar",
        "liblib_a.jar",
        "liblib_i.jar",
        "liblib_b.jar",
        "liblib_c.jar",
        "liblib_d.jar",
        "liblib_e.jar",
        "liblib_f.jar",
        "liblib_g.jar"
    ]
    
    expected_transitive_compile_jars = [
        "libruntime_empty_exclusions_test_lib-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

empty_exclusion_lists_test = unittest.make(_test_empty_exclusion_lists, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
})

def _test_multiple_paths(ctx):
    """
    Tests handling of multiple paths to the same dependency.
    
    Dependency Graph:
         test_lib      
            |
 dependencyset("runtime_deps")
        /     \\
       A       I
      / \\    /
     B   E   G
     |   | /
     |   F 
      \\  
       C
       |
       D

    Dependencyset Input:
        items = [":lib_a", ":lib_i"]
        deps_exclude_labels = [":lib_b", ":lib_g"]
        deps_exclude_paths = []
        exclude_transitives = False

    Expected Output:
        JARs preserved:
        - test_lib, A, I, E, F, C, D (runtime)
        - no compile-time jars present
        JARs excluded:
        - B, G
        Note: Dependencies not duplicated when reachable through multiple paths
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    expected_compile_jars = [
        "libruntime_multiple_paths_test_lib-hjar.jar",
    ]

    expected_full_compile_jars = [
        "libruntime_multiple_paths_test_lib.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "libruntime_multiple_paths_test_lib.jar",
        "liblib_a.jar",
        "liblib_i.jar",
        "liblib_e.jar",
        "liblib_f.jar",
        "liblib_c.jar",
        "liblib_d.jar"
    ]
    
    expected_transitive_compile_jars = [
        "libruntime_multiple_paths_test_lib-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

multiple_paths_test = unittest.make(_test_multiple_paths, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
})

