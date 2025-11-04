load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//springboot/deps_filter_rules:deps_filter.bzl", "deps_filter")
load("//springboot/deps_filter_rules/tests/test_utils:verification_utils.bzl",
        "verify_jars", 
        "verify_runtime_and_compile_jars",
        "verify_jars_and_dropped_counts", 
        "verify_dropped_counts",
        "compute_expected_jars",
)


def _test_no_filtering(ctx):
    """
    Tests deps without any filtering - baseline test.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "no_filtering_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    verify_jars_and_dropped_counts(env, expected, 
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = "0",
                          expected_transitive_runtime_dropped = "0")

    return unittest.end(env)

no_filtering_test = unittest.make(_test_no_filtering, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [],
    ),
})


def _test_with_label_exclusions(ctx):
    """
    Tests deps with label-based exclusions (without transitives).
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "with_label_exclusions_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    # Verify dropped counts - label exclusions should drop direct JARs but not transitives when exclude_transitives=False
    dropped_counts = {
        "compile_jars_dropped": expected["compile_jars_dropped"],
    "full_compile_jars_dropped": expected["full_compile_jars_dropped"],
        "transitive_compile_jars_dropped": expected["transitive_compile_jars_dropped"],
        "transitive_runtime_jars_dropped": expected["transitive_runtime_jars_dropped"],
    }
    verify_dropped_counts(env, expected, 
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = ">0",
                          expected_transitive_runtime_dropped = ">0")

    return unittest.end(env)

with_label_exclusions_test = unittest.make(_test_with_label_exclusions, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
            "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
            
        ],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})

def _test_with_label_exclusions_with_exclude_transitives(ctx):
    """
    Tests deps with label-based exclusions including exclude_transitives.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "with_label_exclusions_with_exclude_transitives_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    verify_jars_and_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = ">0",
                          expected_transitive_runtime_dropped = ">0")

    return unittest.end(env)

with_label_exclusions_with_exclude_transitives_test = unittest.make(_test_with_label_exclusions_with_exclude_transitives, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
            "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
            
        ],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [],
    ),
    "exclude_transitives": attr.bool(
        default = True,
    ),
})


def _test_with_path_exclusions(ctx):
    """
    Tests deps with path-based exclusions (without transitives).
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "with_path_exclusions_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = ">0",
                          expected_transitive_runtime_dropped = ">0")
    return unittest.end(env)

with_path_exclusions_test = unittest.make(_test_with_path_exclusions, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [        
        ],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [
            "micrometer",
            "slf4j"
        ],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})


def _test_with_path_exclusions_with_exclude_transitives(ctx):
    """
    Tests deps with path-based exclusions including exclude_transitives.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "with_path_exclusions_with_exclude_transitives_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)
    
    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )

    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = ">0",
                          expected_transitive_runtime_dropped = ">0")
    return unittest.end(env)

with_path_exclusions_with_exclude_transitives_test = unittest.make(_test_with_path_exclusions_with_exclude_transitives, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [        
        ],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [
            "micrometer",
            "slf4j"
        ],
    ),
    "exclude_transitives": attr.bool(
        default = True,
    ),
})

def _test_multiple_exclusions_with_exclude_transitives(ctx):
    """
    Tests multiple exclusion types (labels + paths) with exclude_transitives=True.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "multiple_exclusions_with_exclude_transitives_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )

    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = ">0",
                          expected_transitive_runtime_dropped = ">0")
    return unittest.end(env)

multiple_exclusions_with_exclude_transitives_test = unittest.make(_test_multiple_exclusions_with_exclude_transitives, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
            "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
        ],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [
            "slf4j"
        ],
    ),
    "exclude_transitives": attr.bool(
        default = True,
    ),
})

def _test_multiple_exclusions_without_exclude_transitives(ctx):
    """
    Tests multiple exclusion types (labels + paths) with exclude_transitives=False.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "multiple_exclusions_without_exclude_transitives_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )

    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = ">0",
                          expected_transitive_runtime_dropped = ">0")
    return unittest.end(env)

multiple_exclusions_without_exclude_transitives_test = unittest.make(_test_multiple_exclusions_without_exclude_transitives, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
            "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
        ],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [
            "slf4j"
        ],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})

def _test_empty_exclusion_lists(ctx):
    """
    Tests behavior when exclusion lists are empty.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "empty_exclusion_lists_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )

    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = "0",
                          expected_transitive_runtime_dropped = "0")
    return unittest.end(env)

empty_exclusion_lists_test = unittest.make(_test_empty_exclusion_lists, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})

def _test_path_based_exclusions_comprehensive(ctx):
    """
    Tests comprehensive path-based exclusions with various patterns.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "path_based_exclusions_comprehensive_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    # Additional verification: ensure excluded patterns are not present
    transitive_runtime_jars = [jar.basename for jar in javainfo_filtered.transitive_runtime_jars.to_list()]
    for pattern in ["micrometer", "slf4j", "logback"]:
        for jar in transitive_runtime_jars:
            asserts.true(env, pattern not in jar, 
                "Excluded pattern '{}' found in JAR: {}".format(pattern, jar))

    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = ">0",
                          expected_transitive_runtime_dropped = ">0")
    
    return unittest.end(env)

path_based_exclusions_comprehensive_test = unittest.make(_test_path_based_exclusions_comprehensive, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [
            "micrometer",
            "slf4j",
            "logback"
        ],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})

def _test_runtime_deps_only(ctx):
    """
    Tests behavior when only runtime_deps are provided (no deps).
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "runtime_deps_only_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )

    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = "0",
                          expected_transitive_runtime_dropped = "0")
    return unittest.end(env)

runtime_deps_only_test = unittest.make(_test_runtime_deps_only, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})

def _test_compile_deps_only(ctx):
    """
    Tests behavior when only deps are provided (no runtime_deps).
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "compile_deps_only_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    # Compile deps should contribute to both compile and runtime JARs
    compile_jars = [jar.basename for jar in javainfo_filtered.compile_jars.to_list()]
    transitive_runtime_jars = [jar.basename for jar in javainfo_filtered.transitive_runtime_jars.to_list()]
    
    asserts.true(env, len(compile_jars) > 0, 
        "Expected compile JARs when deps provided, got: {}".format(len(compile_jars)))
    asserts.true(env, len(transitive_runtime_jars) > 0, 
        "Expected transitive runtime JARs when deps provided, got: {}".format(len(transitive_runtime_jars)))
    
    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = "0",
                          expected_transitive_runtime_dropped = "0")
    return unittest.end(env)

compile_deps_only_test = unittest.make(_test_compile_deps_only, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})

def _test_single_dep_with_exclusions(ctx):
    """
    Tests behavior with a single dependency and exclusions.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "single_dep_with_exclusions_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = ">0",
                          expected_transitive_runtime_dropped = ">0")
    return unittest.end(env)

single_dep_with_exclusions_test = unittest.make(_test_single_dep_with_exclusions, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        ],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})

def _test_single_runtime_dep_with_exclusions(ctx):
    """
    Tests behavior with a single runtime dependency and exclusions.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "single_runtime_dep_with_exclusions_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = "0",
                          expected_transitive_runtime_dropped = ">0")
    return unittest.end(env)

single_runtime_dep_with_exclusions_test = unittest.make(_test_single_runtime_dep_with_exclusions, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [
            "slf4j",
        ],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})

def _test_one_compile_one_runtime_dep(ctx):
    """
    Tests behavior with exactly one compile dep and one runtime dep.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "one_compile_one_runtime_dep_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = "0",
                          expected_transitive_runtime_dropped = "0")
    return unittest.end(env)

one_compile_one_runtime_dep_test = unittest.make(_test_one_compile_one_runtime_dep, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})

def _test_path_patterns_with_special_characters(ctx):
    """
    Tests behavior with path patterns containing special characters.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "path_patterns_with_special_characters_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = ">0",
                          expected_transitive_runtime_dropped = ">0")
    return unittest.end(env)

path_patterns_with_special_characters_test = unittest.make(_test_path_patterns_with_special_characters, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [
            "io.micrometer",  # Pattern with dot
            "to-slf4j",  # Pattern with hyphen
        ],
    ),
    "exclude_transitives": attr.bool(
        default = True,
    ),
})

def _test_case_sensitive_pattern_matching(ctx):
    """
    Tests case sensitivity in path pattern matching.
    """
    env = unittest.begin(ctx)
    javainfo_filtered = ctx.attr.test_lib[JavaInfo]
    
    test_lib_name = "case_sensitive_pattern_matching_test_lib"
    expected = compute_expected_jars(ctx, test_lib_name)

    verify_runtime_and_compile_jars(
        ctx, env, javainfo_filtered,
        expected_compile_jars = expected["compile_jars"],
        expected_full_compile_jars = expected["full_compile_jars"],
        expected_transitive_compile_jars = expected["transitive_compile_jars"],
        expected_transitive_runtime_jars = expected["transitive_runtime_jars"],
    )
    
    verify_dropped_counts(env, expected,
                          expected_compile_dropped = "0",
                          expected_full_compile_dropped = "0",
                          expected_transitive_compile_dropped = "0",
                          expected_transitive_runtime_dropped = "0")
    return unittest.end(env)

case_sensitive_pattern_matching_test = unittest.make(_test_case_sensitive_pattern_matching, attrs = {
    "test_lib": attr.label(providers = [JavaInfo]),
    "deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
        ],
        providers = [JavaInfo],
    ),
    "runtime_deps_labels": attr.label_list(
        default = [
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
        ],
        providers = [JavaInfo],
    ),
    "deps_exclude_labels": attr.label_list(
        default = [],
    ),
    "deps_exclude_paths": attr.string_list( 
        default = [
            "SPRING",  # Uppercase pattern
            "Jackson", # Mixed case pattern
            "HIBERNATE", # Uppercase pattern
        ],
    ),
    "exclude_transitives": attr.bool(
        default = False,
    ),
})




