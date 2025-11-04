load("//springboot/deps_filter_rules:dependencyset.bzl", "dependencyset")
load(
    "//springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime:compile_and_runtime_test.bzl",
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
dependencyset(
    name = "deps_no_filtering",
    items = deps,
)

dependencyset(
    name = "runtime_deps_no_filtering",
    items = runtime_deps,
)

java_library(
    name = "no_filtering_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_no_filtering"],
    runtime_deps = [":runtime_deps_no_filtering"],
)

no_filtering_test(
    name = "no_filtering_test",
    test_lib = ":no_filtering_test_lib",
)

java_test(
    name = "DepsFilterNoFilteringTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterNoFilteringTest.java"
    ],
    deps = [":no_filtering_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 2: Label-based exclusions without transitives
dependencyset(
    name = "deps_with_label_exclusions",
    items = deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
)

dependencyset(
    name = "runtime_deps_with_label_exclusions",
    items = runtime_deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
)

java_library(
    name = "with_label_exclusions_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_with_label_exclusions"],
    runtime_deps = [":runtime_deps_with_label_exclusions"],
)

with_label_exclusions_test(
    name = "with_label_exclusions_test",
    test_lib = ":with_label_exclusions_test_lib",
)

java_test(
    name = "DepsFilterLabelExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterLabelExclusionsTest.java"
    ],
    deps = [":with_label_exclusions_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 3: Label-based exclusions with exclude_transitives
dependencyset(
    name = "deps_with_label_exclusions_with_exclude_transitives",
    items = deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
    exclude_transitives = True,
)

dependencyset(
    name = "runtime_deps_with_label_exclusions_with_exclude_transitives",
    items = runtime_deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
    exclude_transitives = True,
)

java_library(
    name = "with_label_exclusions_with_exclude_transitives_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_with_label_exclusions_with_exclude_transitives"],
    runtime_deps = [":runtime_deps_with_label_exclusions_with_exclude_transitives"],
)

with_label_exclusions_with_exclude_transitives_test(
    name = "with_label_exclusions_with_exclude_transitives_test",
    test_lib = ":with_label_exclusions_with_exclude_transitives_test_lib",
)

java_test(
    name = "DepsFilterExcludeTransitiveTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterExcludeTransitiveTest.java"
    ],
    deps = [":with_label_exclusions_with_exclude_transitives_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 4: Path-based exclusions without transitives
dependencyset(
    name = "deps_with_path_exclusions",
    items = deps,
    deps_exclude_paths = [
        "micrometer",
        "slf4j"
    ],
)

dependencyset(
    name = "runtime_deps_with_path_exclusions",
    items = runtime_deps,
    deps_exclude_paths = [
        "micrometer",
        "slf4j"
    ],
)

java_library(
    name = "with_path_exclusions_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_with_path_exclusions"],
    runtime_deps = [":runtime_deps_with_path_exclusions"],
)

with_path_exclusions_test(
    name = "with_path_exclusions_test",
    test_lib = ":with_path_exclusions_test_lib",
)

java_test(
    name = "DepsFilterPathExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterPathExclusionsTest.java"
    ],
    deps = [":with_path_exclusions_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 5: Path-based exclusions with exclude_transitives
dependencyset(
    name = "deps_with_path_exclusions_with_exclude_transitives",
    items = deps,
    deps_exclude_paths = [
        "micrometer",
        "slf4j"
    ],
    exclude_transitives = True,
)

dependencyset(
    name = "runtime_deps_with_path_exclusions_with_exclude_transitives",
    items = runtime_deps,
    deps_exclude_paths = [
        "micrometer",
        "slf4j"
    ],
    exclude_transitives = True,
)

java_library(
    name = "with_path_exclusions_with_exclude_transitives_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_with_path_exclusions_with_exclude_transitives"],
    runtime_deps = [":runtime_deps_with_path_exclusions_with_exclude_transitives"],
)

with_path_exclusions_with_exclude_transitives_test(
    name = "with_path_exclusions_with_exclude_transitives_test",
    test_lib = ":with_path_exclusions_with_exclude_transitives_test_lib",
)

java_test(
    name = "DepsFilterPathExclusionsWithTransitivesTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterPathExclusionsWithTransitivesTest.java"
    ],
    deps = [":with_path_exclusions_with_exclude_transitives_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 6: Multiple exclusions with exclude_transitives (labels + patterns)
dependencyset(
    name = "deps_multiple_exclusions_with_exclude_transitives",
    items = deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
    deps_exclude_paths = [
        "slf4j"
    ],
    exclude_transitives = True,
)

dependencyset(
    name = "runtime_deps_multiple_exclusions_with_exclude_transitives",
    items = runtime_deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
    deps_exclude_paths = [
        "slf4j"
    ],
    exclude_transitives = True,
)

java_library(
    name = "multiple_exclusions_with_exclude_transitives_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_multiple_exclusions_with_exclude_transitives"],
    runtime_deps = [":runtime_deps_multiple_exclusions_with_exclude_transitives"],
)

multiple_exclusions_with_exclude_transitives_test(
    name = "multiple_exclusions_with_exclude_transitives_test",
    test_lib = ":multiple_exclusions_with_exclude_transitives_test_lib",
)

java_test(
    name = "DepsFilterMultipleExclusionsWithTransitivesTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterMultipleExclusionsWithTransitivesTest.java"
    ],
    deps = [":multiple_exclusions_with_exclude_transitives_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 7: Multiple exclusions without exclude_transitives (labels + patterns)
dependencyset(
    name = "deps_multiple_exclusions_without_exclude_transitives",
    items = deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
    deps_exclude_paths = [
        "slf4j",
    ],
    exclude_transitives = False,
)

dependencyset(
    name = "runtime_deps_multiple_exclusions_without_exclude_transitives",
    items = runtime_deps,
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
        "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j",
    ],
    deps_exclude_paths = [
        "slf4j",
    ],
    exclude_transitives = False,
)

java_library(
    name = "multiple_exclusions_without_exclude_transitives_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_multiple_exclusions_without_exclude_transitives"],
    runtime_deps = [":runtime_deps_multiple_exclusions_without_exclude_transitives"],
)

multiple_exclusions_without_exclude_transitives_test(
    name = "multiple_exclusions_without_exclude_transitives_test",
    test_lib = ":multiple_exclusions_without_exclude_transitives_test_lib",
)

java_test(
    name = "DepsFilterMultipleExclusionsWithoutTransitivesTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterMultipleExclusionsWithoutTransitivesTest.java"
    ],
    deps = [":multiple_exclusions_without_exclude_transitives_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 8: Empty exclusion lists
dependencyset(
    name = "deps_empty_exclusion_lists",
    items = deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

dependencyset(
    name = "runtime_deps_empty_exclusion_lists",
    items = runtime_deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

java_library(
    name = "empty_exclusion_lists_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_empty_exclusion_lists"],
    runtime_deps = [":runtime_deps_empty_exclusion_lists"],
)

empty_exclusion_lists_test(
    name = "empty_exclusion_lists_test",
    test_lib = ":empty_exclusion_lists_test_lib",
)

java_test(
    name = "DepsFilterEmptyExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterEmptyExclusionsTest.java"
    ],
    deps = [":empty_exclusion_lists_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 9: Comprehensive path-based exclusions
dependencyset(
    name = "deps_path_based_exclusions_comprehensive",
    items = deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [
        "micrometer",
        "slf4j",
        "logback"
    ],
    exclude_transitives = False,
)

dependencyset(
    name = "runtime_deps_path_based_exclusions_comprehensive",
    items = runtime_deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [
        "micrometer",
        "slf4j",
        "logback"
    ],
    exclude_transitives = False,
)

java_library(
    name = "path_based_exclusions_comprehensive_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_path_based_exclusions_comprehensive"],
    runtime_deps = [":runtime_deps_path_based_exclusions_comprehensive"],
)

path_based_exclusions_comprehensive_test(
    name = "path_based_exclusions_comprehensive_test",
    test_lib = ":path_based_exclusions_comprehensive_test_lib",
)

java_test(
    name = "DepsFilterPathBasedExclusionsComprehensiveTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterPathBasedExclusionsComprehensiveTest.java"
    ],
    deps = [":path_based_exclusions_comprehensive_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 10: Runtime deps only
dependencyset(
    name = "runtime_deps_only",
    items = runtime_deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

java_library(
    name = "runtime_deps_only_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    runtime_deps = [":runtime_deps_only"],
)

runtime_deps_only_test(
    name = "runtime_deps_only_test",
    test_lib = ":runtime_deps_only_test_lib",
)

java_test(
    name = "DepsFilterRuntimeDepsOnlyTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterRuntimeDepsOnlyTest.java"
    ],
    deps = [":runtime_deps_only_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 11: Compile deps only
dependencyset(
    name = "compile_deps_only",
    items = deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

java_library(
    name = "compile_deps_only_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":compile_deps_only"],
)

compile_deps_only_test(
    name = "compile_deps_only_test",
    test_lib = ":compile_deps_only_test_lib",
)

java_test(
    name = "DepsFilterCompileDepsOnlyTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterCompileDepsOnlyTest.java"
    ],
    deps = [":compile_deps_only_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 12: Single dependency with exclusions
dependencyset(
    name = "deps_single_dep_with_exclusions",
    items = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
    ],
    deps_exclude_labels = [
        "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
    ],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

java_library(
    name = "single_dep_with_exclusions_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_single_dep_with_exclusions"],
)

single_dep_with_exclusions_test(
    name = "single_dep_with_exclusions_test",
    test_lib = ":single_dep_with_exclusions_test_lib",
)

java_test(
    name = "DepsFilterSingleDepWithExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterSingleDepWithExclusionsTest.java"
    ],
    deps = [":single_dep_with_exclusions_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 13: Single runtime dependency with exclusions
dependencyset(
    name = "runtime_deps_single_runtime_dep_with_exclusions",
    items = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
    ],
    deps_exclude_labels = [],
    deps_exclude_paths = [
        "slf4j",
    ],
    exclude_transitives = False,
)

java_library(
    name = "single_runtime_dep_with_exclusions_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    runtime_deps = [":runtime_deps_single_runtime_dep_with_exclusions"],
)

single_runtime_dep_with_exclusions_test(
    name = "single_runtime_dep_with_exclusions_test",
    test_lib = ":single_runtime_dep_with_exclusions_test_lib",
)

java_test(
    name = "DepsFilterSingleRuntimeDepWithExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterSingleRuntimeDepWithExclusionsTest.java"
    ],
    deps = [":single_runtime_dep_with_exclusions_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 14: One compile dep and one runtime dep
dependencyset(
    name = "deps_one_compile_one_runtime_dep",
    items = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
    ],
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

dependencyset(
    name = "runtime_deps_one_compile_one_runtime_dep",
    items = [
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
    ],
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    exclude_transitives = False,
)

java_library(
    name = "one_compile_one_runtime_dep_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_one_compile_one_runtime_dep"],
    runtime_deps = [":runtime_deps_one_compile_one_runtime_dep"],
)

one_compile_one_runtime_dep_test(
    name = "one_compile_one_runtime_dep_test",
    test_lib = ":one_compile_one_runtime_dep_test_lib",
)

java_test(
    name = "DepsFilterOneCompileOneRuntimeDepTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterOneCompileOneRuntimeDepTest.java"
    ],
    deps = [":one_compile_one_runtime_dep_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 15: Path patterns with special characters
dependencyset(
    name = "deps_path_patterns_with_special_characters",
    items = deps,
    deps_exclude_paths = [
        "io.micrometer",  
        "to-slf4j", 
    ],
    exclude_transitives = True,
)

dependencyset(
    name = "runtime_deps_path_patterns_with_special_characters",
    items = runtime_deps,
    deps_exclude_paths = [
        "io.micrometer",  
        "to-slf4j", 
    ],
    exclude_transitives = True,
)

java_library(
    name = "path_patterns_with_special_characters_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_path_patterns_with_special_characters"],
    runtime_deps = [":runtime_deps_path_patterns_with_special_characters"],
)

path_patterns_with_special_characters_test(
    name = "path_patterns_with_special_characters_test",
    test_lib = ":path_patterns_with_special_characters_test_lib",
)

java_test(
    name = "DepsFilterPathPatternsWithSpecialCharactersTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterPathPatternsWithSpecialCharactersTest.java"
    ],
    deps = [":path_patterns_with_special_characters_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)

# Test 16: Case sensitive pattern matching
dependencyset(
    name = "deps_case_sensitive_pattern_matching",
    items = deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [
        "SPRING",  # Uppercase pattern
        "Jackson", # Mixed case pattern
        "HIBERNATE", # Uppercase pattern
    ],
    exclude_transitives = False,
)

dependencyset(
    name = "runtime_deps_case_sensitive_pattern_matching",
    items = runtime_deps,
    deps_exclude_labels = [],
    deps_exclude_paths = [
        "SPRING",  # Uppercase pattern
        "Jackson", # Mixed case pattern
        "HIBERNATE", # Uppercase pattern
    ],
    exclude_transitives = False,
)

java_library(
    name = "case_sensitive_pattern_matching_test_lib",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [":deps_case_sensitive_pattern_matching"],
    runtime_deps = [":runtime_deps_case_sensitive_pattern_matching"],
)

case_sensitive_pattern_matching_test(
    name = "case_sensitive_pattern_matching_test",
    test_lib = ":case_sensitive_pattern_matching_test_lib",
)

java_test(
    name = "DepsFilterCaseSensitivePatternMatchingTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterCaseSensitivePatternMatchingTest.java"
    ],
    deps = [":case_sensitive_pattern_matching_test_lib", "//springboot/deps_filter_rules/tests/test_utils:test_utils"] + test_deps,
)