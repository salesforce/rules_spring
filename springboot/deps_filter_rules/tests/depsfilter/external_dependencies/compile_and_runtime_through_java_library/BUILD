load("//springboot/deps_filter_rules:deps_filter.bzl", "deps_filter")
load(
    "//springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime_through_java_library:compile_and_runtime_test.bzl",
    "no_filtering_test",
    "with_label_exclusions_test",
    "with_label_exclusions_with_exclude_transitives_test",
    "with_path_exclusions_test",
    "with_path_exclusions_with_exclude_transitives_test",
    "multiple_exclusions_with_exclude_transitives_test",
    "multiple_exclusions_without_exclude_transitives_test",
    "empty_exclusion_lists_test",
    "path_based_exclusions_comprehensive_test",
    "runtime_deps_only_A_test",
    "runtime_deps_only_B_test",
    "single_runtime_dep_with_exclusions_A_test",
    "single_runtime_dep_with_exclusions_B_test",
    "compile_deps_only_test",
    "single_dep_with_exclusions_test",
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

# Setup libraries for testing
java_library(
    name = "base_lib_with_deps_and_runtime_deps",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = deps,
    runtime_deps = runtime_deps,
)

java_library(
    name = "base_lib_with_deps",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = deps,
)

java_library(
    name = "base_lib_with_runtime_deps",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    runtime_deps = runtime_deps,
)

java_library(
    name = "base_lib_with_single_dep_and_runtime_dep",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
    ],
    runtime_deps = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
    ],
)

java_library(
    name = "base_lib_with_single_dep",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
    ],
)

java_library(
    name = "base_lib_with_single_runtime_dep",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    runtime_deps = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
    ],
)

# Test 1: No filtering - baseline test
deps_filter(
    name = "no_filtering",
    deps = [":base_lib_with_deps_and_runtime_deps"],
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
    deps = [":base_lib_with_deps_and_runtime_deps"],
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
    deps = [":base_lib_with_deps_and_runtime_deps"],
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
    deps = [":base_lib_with_deps_and_runtime_deps"],
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
    deps = [":base_lib_with_deps_and_runtime_deps"],
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
    deps = [":base_lib_with_deps_and_runtime_deps"],
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
    deps = [":base_lib_with_deps_and_runtime_deps"],
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
    deps = [":base_lib_with_deps_and_runtime_deps"],
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
    deps = [":base_lib_with_deps_and_runtime_deps"],
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

# Test 10.A: Runtime deps only
deps_filter(
    name = "runtime_deps_only_A",
    runtime_deps = [":base_lib_with_runtime_deps"],
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

runtime_deps_only_A_test(
    name = "runtime_deps_only_A_test",
    filtered = ":runtime_deps_only_A",
)

java_test(
    name = "DepsFilterRuntimeDepsOnlyATest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterRuntimeDepsOnlyATest.java"
    ],
    deps = [":runtime_deps_only_A", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 10.B: Runtime deps only
deps_filter(
    name = "runtime_deps_only_B",
    deps = [":base_lib_with_runtime_deps"],
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

runtime_deps_only_B_test(
    name = "runtime_deps_only_B_test",
    filtered = ":runtime_deps_only_B",
)

java_test(
    name = "DepsFilterRuntimeDepsOnlyBTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterRuntimeDepsOnlyBTest.java"
    ],
    deps = [":runtime_deps_only_B", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 11.A: Single runtime dependency with exclusions
deps_filter(
    name = "single_runtime_dep_with_exclusions_A",
    runtime_deps = [":base_lib_with_single_runtime_dep",], 
    deps_exclude_labels = [],
    deps_exclude_paths = [
        "slf4j",
    ],
    exclude_transitives = False,
)

single_runtime_dep_with_exclusions_A_test(
    name = "single_runtime_dep_with_exclusions_test_A",
    filtered = ":single_runtime_dep_with_exclusions_A",
)

java_test(
    name = "DepsFilterSingleRuntimeDepWithExclusionsATest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterSingleRuntimeDepWithExclusionsATest.java"
    ],
    deps = [":single_runtime_dep_with_exclusions_A", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 11.B: Single runtime dependency with exclusions
deps_filter(
    name = "single_runtime_dep_with_exclusions_B",
    deps = [":base_lib_with_single_runtime_dep",], 
    # runtime_deps = [],
    deps_exclude_labels = [],
    deps_exclude_paths = [
        "slf4j",
    ],
    exclude_transitives = False,
)

single_runtime_dep_with_exclusions_B_test(
    name = "single_runtime_dep_with_exclusions_test_B",
    filtered = ":single_runtime_dep_with_exclusions_B",
)

java_test(
    name = "DepsFilterSingleRuntimeDepWithExclusionsBTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterSingleRuntimeDepWithExclusionsBTest.java"
    ],
    deps = [":single_runtime_dep_with_exclusions_B", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 12: Compile deps only
deps_filter(
    name = "compile_deps_only",
    deps = [":base_lib_with_deps"],
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

# Test 13: Single dependency with exclusions
deps_filter(
    name = "single_dep_with_exclusions",
    deps = [":base_lib_with_single_dep"],
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

# Test 14: One compile dep and one runtime dep
deps_filter(
    name = "one_compile_one_runtime_dep",
    deps = [":base_lib_with_single_dep_and_runtime_dep"],
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
    deps = [":base_lib_with_deps_and_runtime_deps"],
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
    deps = [":base_lib_with_deps_and_runtime_deps"],
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

