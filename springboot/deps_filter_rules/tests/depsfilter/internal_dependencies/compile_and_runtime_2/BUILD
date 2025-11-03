load("//springboot/deps_filter_rules:deps_filter.bzl", "deps_filter")
load(
    "//springboot/deps_filter_rules/tests/depsfilter/internal_dependencies/compile_and_runtime_2:compile_and_runtime_test.bzl",
    "filtered_deps_test",
    "filtered_deps_exclude_transitive_test",
    "path_based_exclusions_test",
    "interface_implementation_jars_test",
    "multiple_exclusions_with_transitive_test",
    "multiple_exclusions_without_transitive_test",
    "empty_exclusion_lists_test",
    "multiple_paths_test",
)

# Dependency Graph Structure:

#  J(r)    A (c)     H (r)   I (c)  
#    \     /  \        |      |   
#     \   /   \      G (r)    |     
#      \ /     \       |      /
#       B (c)  E (r)  /     /
#       |      |     /    /
#       |      |    /   /
#       |      |   /  /
#       |      |  / /
#       |     F (c)
#        \   /
#        C (c)
#         | 
#        D (r)   

java_library(
    name = "lib_a",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    deps = [
        ":lib_b",  # A -> B (c)
    ],
    runtime_deps = [
        ":lib_e",  # A -> E (r)
    ],
)

java_library(
    name = "lib_b",
    srcs = ["src/main/java/com/depsfilter/B.java"],  
    deps = [":lib_c"], # B -> C (c)
)

java_library(
    name = "lib_c",
    srcs = ["src/main/java/com/depsfilter/C.java"],
    runtime_deps = [":lib_d"], # C -> D (r)
)

java_library(
    name = "lib_d",
    srcs = ["src/main/java/com/depsfilter/D.java"], 
)

java_library(
    name = "lib_e",
    srcs = ["src/main/java/com/depsfilter/E.java"],
    deps = [":lib_f"], # E -> F (c)
)

java_library(
    name = "lib_f",
    srcs = ["src/main/java/com/depsfilter/F.java"],
    deps = [":lib_c"], # F -> C (c)
)

java_library(
    name = "lib_g",
    srcs = ["src/main/java/com/depsfilter/G.java"],
    deps = [":lib_f"], # G -> F (c)
)

java_library(
    name = "lib_h",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":lib_g"], # H -> G (r)
)

java_library(
    name = "lib_i",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":lib_f"], # I -> F (c)
)

java_library(
    name = "lib_j",
    srcs = ["src/main/java/com/depsfilter/J.java"],
    deps = [":lib_b"], # J -> B (c)
)

# Test 1: No filtering
# deps_filter(
#     name = "filtered_deps",
#     deps = [":lib_a", ":lib_i"],
#     runtime_deps = [":lib_h", ":lib_j"],
# )
#  We can't test this because we can't compare base_lib with deps_filter without base_lib as a dep 

# Test 2: Exclude by labels and exclude_transitives = False
deps_filter(
    name = "filtered_deps_exclude_b_g",
    deps = [":lib_a", ":lib_i"],
    runtime_deps = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

filtered_deps_test(
    name = "deps_filter_exclude_b_g_test",
    filtered = ":filtered_deps_exclude_b_g",
)

# Test 3: Exclude by labels and exclude_transitives = True
deps_filter(
    name = "filtered_deps_exclude_b_g_exclude_transitive",
    deps = [":lib_a", ":lib_i"],
    runtime_deps = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
    exclude_transitives = True,
)

filtered_deps_exclude_transitive_test(
    name = "deps_filter_exclude_b_g_exclude_transitive_test",
    filtered = ":filtered_deps_exclude_b_g_exclude_transitive",
)

# Test 4: Test for path-based exclusions
deps_filter(
    name = "path_based_filtered_deps",
    deps = [":lib_a", ":lib_i"],
    runtime_deps = [":lib_h", ":lib_j"],
    deps_exclude_paths = ["lib_b", "lib_f"],
)

path_based_exclusions_test(
    name = "deps_filter_path_based_exclusions_test",
    filtered = ":path_based_filtered_deps",
)

# Test 5: Interface vs Implementation JARs
deps_filter(
    name = "interface_impl_filtered_deps",
    deps = [":lib_a", ":lib_i"],
    runtime_deps = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

interface_implementation_jars_test(
    name = "deps_filter_interface_impl_test",
    filtered = ":interface_impl_filtered_deps",
)

# Test 6: Multiple exclusions with exclude_transitives=True
deps_filter(
    name = "multiple_exclusions_filtered_deps_1",
    deps = [":lib_a", ":lib_i"],
    runtime_deps = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b"],
    deps_exclude_paths = ["lib_g"],
    exclude_transitives = True,
)

multiple_exclusions_with_transitive_test(
    name = "multiple_exclusions_with_transitive_test",
    filtered = ":multiple_exclusions_filtered_deps_1",
)

# Test 7: Multiple exclusions with exclude_transitives=False
deps_filter(
    name = "multiple_exclusions_filtered_deps_2",
    deps = [":lib_a", ":lib_i"],
    runtime_deps = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b"],
    deps_exclude_paths = ["lib_g"],
    exclude_transitives = False,
)

multiple_exclusions_without_transitive_test(
    name = "multiple_exclusions_without_transitive_test",
    filtered = ":multiple_exclusions_filtered_deps_2",
)

# Test 8: Empty exclusion lists
deps_filter(
    name = "empty_exclusions_filtered_deps",
    deps = [":lib_a", ":lib_i"],
    runtime_deps = [":lib_h", ":lib_j"],
    deps_exclude_paths = [],
    deps_exclude_labels = [],
)

empty_exclusion_lists_test(
    name = "deps_filter_empty_exclusions_test",
    filtered = ":empty_exclusions_filtered_deps",
)

# Test 9: Multiple paths handling
deps_filter(
    name = "multiple_paths_filtered_deps",
    deps = [":lib_a", ":lib_i"],
    runtime_deps = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

multiple_paths_test(
    name = "deps_filter_multiple_paths_test",
    filtered = ":multiple_paths_filtered_deps",
)

test_deps = ["@unmanaged_deps_filter//:junit_junit",
    "@unmanaged_deps_filter//:org_assertj_assertj_core",
]

# Java test targets
java_test(
    name = "DepsFilterEmptyExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterEmptyExclusionsTest.java"
        ],
    deps = [":empty_exclusions_filtered_deps"] + test_deps,
)

java_test(
    name = "DepsFilterFilteredDepsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterFilteredDepsTest.java"
    ],
    deps = [":filtered_deps_exclude_b_g"] + test_deps,
)

java_test(
    name = "DepsFilterExcludeTransitiveTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterExcludeTransitiveTest.java"
    ],
    deps = [":filtered_deps_exclude_b_g_exclude_transitive"] + test_deps,
)

java_test(
    name = "DepsFilterPathBasedExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterPathBasedExclusionsTest.java"
    ],
    deps = [":path_based_filtered_deps"] + test_deps,
)

java_test(
    name = "DepsFilterInterfaceImplementationTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterInterfaceImplementationTest.java"
    ],
    deps = [":interface_impl_filtered_deps"] + test_deps,
)

java_test(
    name = "DepsFilterMultipleExclusionsWithTransitiveTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterMultipleExclusionsWithTransitiveTest.java"
    ],
    deps = [":multiple_exclusions_filtered_deps_1"] + test_deps,
)

java_test(
    name = "DepsFilterMultipleExclusionsWithoutTransitiveTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterMultipleExclusionsWithoutTransitiveTest.java"
    ],
    deps = [":multiple_exclusions_filtered_deps_2"] + test_deps,
)

java_test(
    name = "DepsFilterMultiplePathsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterMultiplePathsTest.java"
    ],
    deps = [":multiple_paths_filtered_deps"] + test_deps,
)


# load("//tools/common/bazel/deps_filter:deps_filter.bzl", "deps_filter")
# deps_filter(
#     name = "flattened_filtered_deps",
#     deps = [":filtered_deps"],
# )

# deps_filter(
#     name = "flattened_java_libary",
#     deps = [":lib_a"],
    # runtime_deps = [":lib_g"],
# )


toolchain(
    name = "unittest_toolchain",
    toolchain_type = "@bazel_skylib//toolchains/unittest:toolchain_type",
    toolchain = "@bazel_skylib//toolchains/unittest:toolchain",
)

