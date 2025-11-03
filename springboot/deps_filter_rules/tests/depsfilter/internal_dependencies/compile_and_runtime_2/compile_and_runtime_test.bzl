load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//springboot/deps_filter_rules/tests/test_utils:verification_utils.bzl",
        "verify_jars", 
        "verify_runtime_and_compile_jars",
        "verify_jars_and_dropped_counts", 
        "verify_dropped_counts"
)


# def _test_no_filtering(ctx):
    # We can't test this because we can't compare base_lib with deps_filter without base_lib as a dep 

def _test_filtered_deps(ctx):
    """
    Tests basic dependency filtering with label-based exclusions.
    
    Dependency Graph:

      J(r)      A (c)     H (r)   I (c)  
        \\      /  \\      |       |
         \\    /    \\    G (r)    |
          \\  /     \\     |      /
           B (c)  E (r)   /     /
            |      |     /    /
            |      |    /   /
            |      |   /  /
            |      |  / /
            |     F (c)
            \\   /
            C (c)
             | 
            D (r) 

    Input:
        deps = [":lib_a", ":lib_i]
        runtime_deps = [":lib_h", ":lib_j"]
        deps_exclude_labels = [":lib_b", ":lib_g"]
        deps_exclude_paths = []
        exclude_transitives = False

    Expected Output:
        JARs preserved: A, I, C, D, E, F, H, J
        JARs excluded: B, G (by label, direct deps only, transitives preserved)
        
        Compile-time JARs: A-hjar, I-hjar, C-hjar, F-hjar
        Runtime JARs: A, I, C, D, E, F, H, J
        Reasoning: B,G excluded by label, but their transitives (C,D,F) are preserved
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.filtered[JavaInfo]

    expected_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_i-hjar.jar",
    ]

    expected_full_compile_jars = [
        "liblib_a.jar",
        "liblib_i.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "liblib_a.jar",
        "liblib_c.jar",
        "liblib_d.jar",
        "liblib_e.jar",
        "liblib_f.jar",
        "liblib_h.jar",
        "liblib_i.jar",
        "liblib_j.jar",
    ]
    
    expected_transitive_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_c-hjar.jar",
        "liblib_f-hjar.jar",
        "liblib_i-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

filtered_deps_test = unittest.make(_test_filtered_deps, attrs = {
    "filtered": attr.label(providers = [JavaInfo]),
})

def _test_filtered_deps_exclude_transitive(ctx):
    """
    Tests dependency filtering with transitive exclusions.
    
    Dependency Graph:

      J(r)      A (c)     H (r)   I (c)  
        \\      /  \\      |       |
         \\    /    \\    G (r)    |
          \\  /     \\     |      /
           B (c)   E (r)   /     /
            |      |     /    /
            |      |    /   /
            |      |   /  /
            |      |  / /
            |     F (c)
            \\   /
            C (c)
             | 
            D (r)   

    Input:
        deps = [":lib_a", ":lib_i]
        runtime_deps = [":lib_h", ":lib_j"]
        deps_exclude_labels = [":lib_b", ":lib_g"]
        deps_exclude_paths = []
        exclude_transitives = True

    Expected Output:
        JARs preserved: A, I, E, H, J
        JARs excluded: B, G (by label) and all their transitives
        
        Compile-time JARs: A-hjar, I-hjar
        Runtime JARs: A, I, E, H, J (only preserved deps, no transitives of excluded deps)
        Reasoning: B,G excluded by label with exclude_transitives=True, so C,D,F also excluded
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.filtered[JavaInfo]
    
    expected_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_i-hjar.jar",
    ]

    expected_full_compile_jars = [
        "liblib_a.jar",
        "liblib_i.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "liblib_a.jar",
        "liblib_e.jar",
        "liblib_h.jar",
        "liblib_i.jar",
        "liblib_j.jar",
    ]
    
    expected_transitive_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_i-hjar.jar",
    ]

    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

filtered_deps_exclude_transitive_test = unittest.make(_test_filtered_deps_exclude_transitive, attrs = {
    "filtered": attr.label(providers = [JavaInfo]),
})

def _test_path_based_exclusions(ctx):
    """
    Tests filtering based on path patterns in deps_exclude_paths.
    
    Dependency Graph:

      J(r)      A (c)     H (r)   I (c)  
        \\      /  \\      |       |
         \\    /    \\    G (r)    |
          \\  /     \\     |      /
           B (c)  E (r)   /     /
            |      |     /    /
            |      |    /   /
            |      |   /  /
            |      |  / /
            |     F (c)
            \\   /
            C (c)
             | 
            D (r) 

    Input:
        deps = [":lib_a", ":lib_i]
        runtime_deps = [":lib_h", ":lib_j"]
        deps_exclude_labels = []
        deps_exclude_paths = ["lib_b", "lib_f"]
        exclude_transitives = False
    ## IMPORTANT_FEATURE
    Expected Output:
        JARs preserved: A, I, C, D, E, G, H, J
        JARs excluded: B, F (by path pattern match, transitives may be preserved)
        
        Compile-time JARs: A-hjar, I-hjar, C-hjar
        Runtime JARs: A, I, C, D, E, G, H, J (all preserved deps + transitives not matching exclusion path patterns)
        Reasoning: B,F excluded by path pattern, but their transitives are preserved as they didn't match the pattern
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.filtered[JavaInfo]
    
    expected_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_i-hjar.jar",
    ]

    expected_full_compile_jars = [
        "liblib_a.jar",
        "liblib_i.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "liblib_a.jar",
        "liblib_c.jar",
        "liblib_d.jar",
        "liblib_e.jar",
        "liblib_g.jar",
        "liblib_h.jar",
        "liblib_i.jar",
        "liblib_j.jar",
    ]
    
    expected_transitive_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_c-hjar.jar",
        "liblib_i-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

path_based_exclusions_test = unittest.make(_test_path_based_exclusions, attrs = {
    "filtered": attr.label(providers = [JavaInfo]),
})

def _test_interface_implementation_jars(ctx):
    """
    Tests proper handling of interface (-hjar) and implementation JARs.
    
    Dependency Graph:

      J(r)      A (c)     H (r)   I (c)  
        \\      /  \\      |       |
         \\    /    \\    G (r)    |
          \\  /     \\     |      /
           B (c)  E (r)   /     /
            |      |     /    /
            |      |    /   /
            |      |   /  /
            |      |  / /
            |     F (c)
            \\   /
            C (c)
             | 
            D (r) 

    Input:
        deps = [":lib_a", ":lib_i]
        runtime_deps = [":lib_h", ":lib_j"]
        deps_exclude_labels = [":lib_b", ":lib_g"]
        deps_exclude_paths = []
        exclude_transitives = False

    Expected Output:
        compile_jars: liblib_a-hjar.jar, liblib_i-hjar.jar
        full_compile_jars: liblib_a.jar, liblib_i.jar
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.filtered[JavaInfo]
    
    compile_jars = sorted([jar.basename for jar in javainfo_filtered.compile_jars.to_list()])
    full_compile_jars = sorted([jar.basename for jar in javainfo_filtered.full_compile_jars.to_list()])
    
    expected_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_i-hjar.jar",
    ]

    expected_full_compile_jars = [
        "liblib_a.jar",
        "liblib_i.jar",
    ]
    
    asserts.equals(env, compile_jars, expected_compile_jars)
    asserts.equals(env, full_compile_jars, expected_full_compile_jars)
    return unittest.end(env)

interface_implementation_jars_test = unittest.make(_test_interface_implementation_jars, attrs = {
    "filtered": attr.label(providers = [JavaInfo]),
})

def _test_multiple_exclusions_with_transitive(ctx):
    """
    Tests multiple exclusion levels with exclude_transitives=True.
    
    Dependency Graph:

      J(r)      A (c)     H (r)   I (c)  
        \\      /  \\      |       |
         \\    /    \\    G (r)    |
          \\  /     \\     |      /
           B (c)  E (r)   /     /
            |      |     /    /
            |      |    /   /
            |      |   /  /
            |      |  / /
            |     F (c)
            \\   /
            C (c)
             | 
            D (r) 

    Input:
        deps = [":lib_a", ":lib_i]
        runtime_deps = [":lib_h", ":lib_j"]
        deps_exclude_labels = [":lib_b"]
        deps_exclude_paths = ["lib_g"]
        exclude_transitives = True

    Expected Output:
        JARs preserved: A, I, E, F, H, J
        JARs excluded: B and its transitives; G (not neccessarily its transitives as specified exclusion by path pattern is matched)
        
        Compile-time JARs: A-hjar, I-hjar, F-hjar
        Runtime JARs: A, I, E, F, H, J
        Reasoning: B excluded by label with exclude_transitives=True (C,D excluded); 
                   G excluded by exclusion path pattern (exclusion by path pattern doesn't exclude transitives)
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.filtered[JavaInfo]
    
    expected_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_i-hjar.jar",
    ]

    expected_full_compile_jars = [
        "liblib_a.jar",
        "liblib_i.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "liblib_a.jar",
        "liblib_e.jar",
        "liblib_f.jar",
        "liblib_h.jar",
        "liblib_i.jar",
        "liblib_j.jar",
    ]
    
    expected_transitive_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_f-hjar.jar",
        "liblib_i-hjar.jar",
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

      J(r)      A (c)     H (r)   I (c)  
        \\      /  \\      |       |
         \\    /    \\    G (r)    |
          \\  /     \\     |      /
           B (c)  E (r)   /     /
            |      |     /    /
            |      |    /   /
            |      |   /  /
            |      |  / /
            |     F (c)
            \\   /
            C (c)
             | 
            D (r) 

    Input:
        deps = [":lib_a", ":lib_i]
        runtime_deps = [":lib_h", ":lib_j"]
        deps_exclude_labels = [":lib_b"]
        deps_exclude_paths = ["lib_g"]
        exclude_transitives = False

    Expected Output:
        JARs preserved: A, I, C, D, E, F, H, J
        JARs excluded: B (by label, direct only); G (by path pattern match, direct only)
        
        Compile-time JARs: A-hjar, I-hjar, C-hjar, F-hjar
        Runtime JARs: A, I, C, D, E, F, H, J
        Reasoning: B excluded by label (direct only, and its transitives are preserved); 
                   G excluded by exclusion path pattern (exclusion by path pattern doesn't exclude transitives)
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.filtered[JavaInfo]
    
    expected_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_i-hjar.jar",
    ]

    expected_full_compile_jars = [
        "liblib_a.jar",
        "liblib_i.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "liblib_a.jar",
        "liblib_c.jar",
        "liblib_d.jar",
        "liblib_e.jar",
        "liblib_f.jar",
        "liblib_h.jar",
        "liblib_i.jar",
        "liblib_j.jar",
    ]
    
    expected_transitive_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_c-hjar.jar",
        "liblib_f-hjar.jar",
        "liblib_i-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

multiple_exclusions_with_transitive_test = unittest.make(_test_multiple_exclusions_with_transitive, attrs = {
    "filtered": attr.label(providers = [JavaInfo]),
})

multiple_exclusions_without_transitive_test = unittest.make(_test_multiple_exclusions_without_transitive, attrs = {
    "filtered": attr.label(providers = [JavaInfo]),
})

def _test_empty_exclusion_lists(ctx):
    """
    Tests behavior when exclusion lists are empty.
    
    Dependency Graph:

      J(r)      A (c)     H (r)   I (c)  
        \\      /  \\      |       |
         \\    /    \\    G (r)    |
          \\  /     \\     |      /
           B (c)  E (r)   /     /
            |      |     /    /
            |      |    /   /
            |      |   /  /
            |      |  / /
            |     F (c)
            \\   /
            C (c)
             | 
            D (r) 

    Input:
        deps = [":lib_a", ":lib_i]
        runtime_deps = [":lib_h", ":lib_j"]
        deps_exclude_labels = []
        deps_exclude_paths = []
        exclude_transitives = False

    Expected Output:
        JARs preserved: A, I, B, C, D, E, F, G, H, J
        
        Compile-time JARs: A-hjar, I-hjar, B-hjar, C-hjar, F-hjar
        Runtime JARs: A, I, B, C, D, E, F, G, H, J
        Reasoning: No exclusions applied, all dependencies preserved
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.filtered[JavaInfo]
    
    expected_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_i-hjar.jar",
    ]

    expected_full_compile_jars = [
        "liblib_a.jar",
        "liblib_i.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "liblib_a.jar",
        "liblib_b.jar",
        "liblib_c.jar",
        "liblib_d.jar",
        "liblib_e.jar",
        "liblib_f.jar",
        "liblib_g.jar",
        "liblib_h.jar",
        "liblib_i.jar",
        "liblib_j.jar",
    ]
    
    expected_transitive_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_b-hjar.jar",
        "liblib_c-hjar.jar",
        "liblib_f-hjar.jar",
        "liblib_i-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

empty_exclusion_lists_test = unittest.make(_test_empty_exclusion_lists, attrs = {
    "filtered": attr.label(providers = [JavaInfo]),
})

def _test_multiple_paths(ctx):
    """
    Tests handling of multiple paths to the same dependency.
    
    Dependency Graph:

      J(r)      A (c)     H (r)   I (c)  
        \\      /  \\      |       |
         \\    /    \\    G (r)    |
          \\  /     \\     |      /
           B (c)  E (r)   /     /
            |      |     /    /
            |      |    /   /
            |      |   /  /
            |      |  / /
            |     F (c)
            \\   /
            C (c)
             | 
            D (r) 
    # IMPORTANT_FEATURE
    Input:
        deps = [":lib_a", ":lib_i]
        runtime_deps = [":lib_h", ":lib_j"]
        deps_exclude_labels = [":lib_b", ":lib_g"]
        deps_exclude_paths = []
        exclude_transitives = False

    Expected Output:
        JARs preserved: A, I, C, D, E, F, H, J
        JARs excluded: B, G (not duplicated if reachable via multiple paths)
        
        Compile-time JARs: A-hjar, I-hjar, C-hjar, F-hjar
        Runtime JARs: A, I, C, D, E, F, H, J
        Reasoning: B,G excluded by label, but transitives are preserved as exclude_transitives = False
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.filtered[JavaInfo]
    
    expected_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_i-hjar.jar",
    ]

    expected_full_compile_jars = [
        "liblib_a.jar",
        "liblib_i.jar",
    ]
    
    expected_transitive_runtime_jars = [
        "liblib_a.jar",
        "liblib_c.jar",
        "liblib_d.jar",
        "liblib_e.jar",
        "liblib_f.jar",
        "liblib_h.jar",
        "liblib_i.jar",
        "liblib_j.jar",
    ]
    
    expected_transitive_compile_jars = [
        "liblib_a-hjar.jar",
        "liblib_c-hjar.jar",
        "liblib_f-hjar.jar",
        "liblib_i-hjar.jar",
    ]
    
    verify_runtime_and_compile_jars(ctx, env, javainfo_filtered, 
        expected_compile_jars = expected_compile_jars, 
        expected_full_compile_jars = expected_full_compile_jars, 
        expected_transitive_compile_jars = expected_transitive_compile_jars, 
        expected_transitive_runtime_jars = expected_transitive_runtime_jars)
    return unittest.end(env)

multiple_paths_test = unittest.make(_test_multiple_paths, attrs = {
    "filtered": attr.label(providers = [JavaInfo]),
})

