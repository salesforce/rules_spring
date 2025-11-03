load("//springboot/deps_filter_rules:deps_filter.bzl", "deps_filter")
load(
    "//springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime:compile_and_runtime_test.bzl",
    "no_filtering_test",
    "with_label_exclusions_test",
    "with_label_exclusions_with_exclude_transitives_test",
    "with_path_exclusions_test",
    "with_path_exclusions_with_exclude_transitives_test",
    "multiple_exclusions_with_exclude_transitives_test",
    "multiple_exclusions_without_exclude_transitives_test",
    "empty_exclusion_lists_test",
    "path_based_exclusions_comprehensive_test",
    "runtime_deps_only_test",
    "compile_deps_only_test",
    "single_dep_with_exclusions_test",
    "single_runtime_dep_with_exclusions_test",
    "one_compile_one_runtime_dep_test",
    "path_patterns_with_special_characters_test",
    "case_sensitive_pattern_matching_test",
)

deps = [
    "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
    "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security", 
    "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
    "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
    "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api",
]

runtime_deps = [
    "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
    "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
    "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator",
]

test_deps = [
    "@unmanaged_deps_filter//:junit_junit",
    "@unmanaged_deps_filter//:org_assertj_assertj_core",
]

# Test 1: No filtering - baseline test
deps_filter(
    name = "no_filtering",
    deps = deps,
    runtime_deps = runtime_deps,
)

no_filtering_test(
    name = "no_filtering_test",
    filtered = ":no_filtering",
)

java_test(
    name = "DepsFilterNoFilteringTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterNoFilteringTest.java"
    ],
    deps = [":no_filtering", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 2: Label-based exclusions without transitives
deps_filter(
    name = "with_label_exclusions",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
)

with_label_exclusions_test(
    name = "with_label_exclusions_test",
    filtered = ":with_label_exclusions",
)

java_test(
    name = "DepsFilterLabelExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterLabelExclusionsTest.java"
    ],
    deps = [":with_label_exclusions", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 3: Label-based exclusions with exclude_transitives
deps_filter(
    name = "with_label_exclusions_with_exclude_transitives",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
    exclude_transitives = True,
)

with_label_exclusions_with_exclude_transitives_test(
    name = "with_label_exclusions_with_exclude_transitives_test",
    filtered = ":with_label_exclusions_with_exclude_transitives",
)

java_test(
    name = "DepsFilterExcludeTransitiveTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterExcludeTransitiveTest.java"
    ],
    deps = [":with_label_exclusions_with_exclude_transitives", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 4: Path-based exclusions without transitives
deps_filter(
    name = "with_path_exclusions",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_paths = [
        "micrometer",
        "slf4j"
    ],
)

with_path_exclusions_test(
    name = "with_path_exclusions_test",
    filtered = ":with_path_exclusions",
)

java_test(
    name = "DepsFilterPathExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterPathExclusionsTest.java"
    ],
    deps = [":with_path_exclusions", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 5: Path-based exclusions with exclude_transitives
deps_filter(
    name = "with_path_exclusions_with_exclude_transitives",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_paths = [
        "micrometer",
        "slf4j"
    ],
    exclude_transitives = True,
)

with_path_exclusions_with_exclude_transitives_test(
    name = "with_path_exclusions_with_exclude_transitives_test",
    filtered = ":with_path_exclusions_with_exclude_transitives",
)

java_test(
    name = "DepsFilterPathExclusionsWithTransitivesTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterPathExclusionsWithTransitivesTest.java"
    ],
    deps = [":with_path_exclusions_with_exclude_transitives", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 6: Multiple exclusions with exclude_transitives (labels + patterns)
deps_filter(
    name = "multiple_exclusions_with_exclude_transitives",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
    deps_exclude_paths = [
        "slf4j"
    ],
    exclude_transitives = True,
)

multiple_exclusions_with_exclude_transitives_test(
    name = "multiple_exclusions_with_exclude_transitives_test",
    filtered = ":multiple_exclusions_with_exclude_transitives",
)

java_test(
    name = "DepsFilterMultipleExclusionsWithTransitivesTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterMultipleExclusionsWithTransitivesTest.java"
    ],
    deps = [":multiple_exclusions_with_exclude_transitives", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 7: Multiple exclusions without exclude_transitives (labels + patterns)
deps_filter(
    name = "multiple_exclusions_without_exclude_transitives",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
    deps_exclude_paths = [
        "slf4j",
    ],
    exclude_transitives = True,
)

multiple_exclusions_without_exclude_transitives_test(
    name = "multiple_exclusions_without_exclude_transitives_test",
    filtered = ":multiple_exclusions_without_exclude_transitives",
)

java_test(
    name = "DepsFilterMultipleExclusionsWithoutTransitivesTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterMultipleExclusionsWithoutTransitivesTest.java"
    ],
    deps = [":multiple_exclusions_without_exclude_transitives", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 8: Empty exclusion lists
deps_filter(
    name = "empty_exclusion_lists",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

empty_exclusion_lists_test(
    name = "empty_exclusion_lists_test",
    filtered = ":empty_exclusion_lists",
)

java_test(
    name = "DepsFilterEmptyExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterEmptyExclusionsTest.java"
    ],
    deps = [":empty_exclusion_lists", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 9: Comprehensive path-based exclusions
deps_filter(
    name = "path_based_exclusions_comprehensive",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [
        "micrometer",
        "slf4j",
        "logback"
    ],
    exclude_transitives = False,
)

path_based_exclusions_comprehensive_test(
    name = "path_based_exclusions_comprehensive_test",
    filtered = ":path_based_exclusions_comprehensive",
)

java_test(
    name = "DepsFilterPathBasedExclusionsComprehensiveTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterPathBasedExclusionsComprehensiveTest.java"
    ],
    deps = [":path_based_exclusions_comprehensive", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 10: Runtime deps only
deps_filter(
    name = "runtime_deps_only",
    runtime_deps = runtime_deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

runtime_deps_only_test(
    name = "runtime_deps_only_test",
    filtered = ":runtime_deps_only",
)

java_test(
    name = "DepsFilterRuntimeDepsOnlyTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterRuntimeDepsOnlyTest.java"
    ],
    deps = [":runtime_deps_only", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 11: Compile deps only
deps_filter(
    name = "compile_deps_only",
    deps = deps,
    runtime_deps = [],
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

compile_deps_only_test(
    name = "compile_deps_only_test",
    filtered = ":compile_deps_only",
)

java_test(
    name = "DepsFilterCompileDepsOnlyTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterCompileDepsOnlyTest.java"
    ],
    deps = [":compile_deps_only", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 12: Single dependency with exclusions
deps_filter(
    name = "single_dep_with_exclusions",
    deps = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
    ],
    runtime_deps = [],
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
    ],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

single_dep_with_exclusions_test(
    name = "single_dep_with_exclusions_test",
    filtered = ":single_dep_with_exclusions",
)

java_test(
    name = "DepsFilterSingleDepWithExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterSingleDepWithExclusionsTest.java"
    ],
    deps = [":single_dep_with_exclusions", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 13: Single runtime dependency with exclusions
deps_filter(
    name = "single_runtime_dep_with_exclusions",
    deps = [],
    runtime_deps = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
    ],
    deps_exclude_labels = [],
    deps_exclude_paths = [
        "slf4j",
    ],
    exclude_transitives = False,
)

single_runtime_dep_with_exclusions_test(
    name = "single_runtime_dep_with_exclusions_test",
    filtered = ":single_runtime_dep_with_exclusions",
)

java_test(
    name = "DepsFilterSingleRuntimeDepWithExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterSingleRuntimeDepWithExclusionsTest.java"
    ],
    deps = [":single_runtime_dep_with_exclusions", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 14: One compile dep and one runtime dep
deps_filter(
    name = "one_compile_one_runtime_dep",
    deps = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
    ],
    runtime_deps = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
    ],
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

one_compile_one_runtime_dep_test(
    name = "one_compile_one_runtime_dep_test",
    filtered = ":one_compile_one_runtime_dep",
)

java_test(
    name = "DepsFilterOneCompileOneRuntimeDepTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterOneCompileOneRuntimeDepTest.java"
    ],
    deps = [":one_compile_one_runtime_dep", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 15: Path patterns with special characters
deps_filter(
    name = "path_patterns_with_special_characters",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_paths = [
        "io.micrometer",  
        "to-slf4j", 
    ],
    exclude_transitives = True,
)

path_patterns_with_special_characters_test(
    name = "path_patterns_with_special_characters_test",
    filtered = ":path_patterns_with_special_characters",
)

java_test(
    name = "DepsFilterPathPatternsWithSpecialCharactersTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterPathPatternsWithSpecialCharactersTest.java"
    ],
    deps = [":path_patterns_with_special_characters", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 16: Case sensitive pattern matching
deps_filter(
    name = "case_sensitive_pattern_matching",
    deps = deps,
    runtime_deps = runtime_deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [
        "SPRING",  # Uppercase pattern
        "Jackson", # Mixed case pattern
        "HIBERNATE", # Uppercase pattern
    ],
    exclude_transitives = False,
)

case_sensitive_pattern_matching_test(
    name = "case_sensitive_pattern_matching_test",
    filtered = ":case_sensitive_pattern_matching",
)

java_test(
    name = "DepsFilterCaseSensitivePatternMatchingTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterCaseSensitivePatternMatchingTest.java"
    ],
    deps = [":case_sensitive_pattern_matching", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Toolchain for unittest
toolchain(
    name = "unittest_toolchain",
    toolchain_type = "@bazel_skylib//toolchains/unittest:toolchain_type",
    toolchain = "@bazel_skylib//toolchains/unittest:toolchain",
)

