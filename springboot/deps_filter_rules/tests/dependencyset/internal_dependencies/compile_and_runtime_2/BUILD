load("//springboot/deps_filter_rules:dependencyset.bzl", "dependencyset")
load(
    "//springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2:compile_and_runtime_test.bzl",
    "no_filtering_test",
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
#            test_lib       
#               |
#         dependencyset
#         /          \
#    ("deps")     ("runtime_deps")
#    /      \         /      \
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

test_deps = ["@unmanaged_deps_filter//:junit_junit",
    "@unmanaged_deps_filter//:org_assertj_assertj_core",
]

# Test 1: No filtering
dependencyset(
    name = "deps_no_filtering",
    items = [":lib_a", ":lib_i"],
)

dependencyset(
    name = "runtime_deps_no_filtering",
    items = [":lib_h", ":lib_j"],
)

java_library(
    name = "base_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":lib_a", ":lib_i"],
    runtime_deps = [":lib_h", ":lib_j"],
)

java_library(
    name = "no_filtering_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":deps_no_filtering"],
    runtime_deps = [":runtime_deps_no_filtering"],
)

no_filtering_test(
    name = "deps_filter_no_filtering_test",
    java_library = ":base_lib",
    java_library_dependencyset = ":no_filtering_test_lib",
)

# Test 2: Exclude by labels and exclude_transitives = False
dependencyset(
    name = "deps_exclude_b_g",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

dependencyset(
    name = "runtime_deps_exclude_b_g",
    items = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

java_library(
    name = "exclude_b_g_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":deps_exclude_b_g"],
    runtime_deps = [":runtime_deps_exclude_b_g"],
)

filtered_deps_test(
    name = "deps_filter_exclude_b_g_test",
    test_lib = ":exclude_b_g_test_lib",
)

java_test(
    name = "DepsFilterFilteredDepsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterFilteredDepsTest.java"
    ],
    deps = [":exclude_b_g_test_lib"] + test_deps,
)

# Test 3: Exclude by labels and exclude_transitives = True
dependencyset(
    name = "deps_exclude_b_g_transitives",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
    exclude_transitives = True,
)

dependencyset(
    name = "runtime_deps_exclude_b_g_transitives",
    items = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
    exclude_transitives = True,
)

java_library(
    name = "exclude_b_g_transitives_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":deps_exclude_b_g_transitives"],
    runtime_deps = [":runtime_deps_exclude_b_g_transitives"],
)

filtered_deps_exclude_transitive_test(
    name = "deps_filter_exclude_b_g_exclude_transitive_test",
    test_lib = ":exclude_b_g_transitives_test_lib",
)

java_test(
    name = "DepsFilterExcludeTransitiveTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterExcludeTransitiveTest.java"
    ],
    deps = [":exclude_b_g_transitives_test_lib"] + test_deps,
)

# Test 4: Test for path-based exclusions
dependencyset(
    name = "deps_exclude_paths",
    items = [":lib_a", ":lib_i"],
    deps_exclude_paths = ["lib_b", "lib_f"],
)

dependencyset(
    name = "runtime_deps_exclude_paths",
    items = [":lib_h", ":lib_j"],
    deps_exclude_paths = ["lib_b", "lib_f"],
)

java_library(
    name = "path_based_exclusions_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":deps_exclude_paths"],
    runtime_deps = [":runtime_deps_exclude_paths"],
)

path_based_exclusions_test(
    name = "deps_filter_path_based_exclusions_test",
    test_lib = ":path_based_exclusions_test_lib",
)

java_test(
    name = "DepsFilterPathBasedExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterPathBasedExclusionsTest.java"
    ],
    deps = [":path_based_exclusions_test_lib"] + test_deps,
)

# Test 5: Interface vs Implementation JARs
dependencyset(
    name = "deps_interface_impl_exclude_b_g",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

dependencyset(
    name = "runtime_deps_interface_impl_exclude_b_g",
    items = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

java_library(
    name = "interface_impl_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":deps_interface_impl_exclude_b_g"],
    runtime_deps = [":runtime_deps_interface_impl_exclude_b_g"],
)

interface_implementation_jars_test(
    name = "deps_filter_interface_impl_test",
    test_lib = ":interface_impl_test_lib",
)

java_test(
    name = "DepsFilterInterfaceImplementationTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterInterfaceImplementationTest.java"
    ],
    deps = [":interface_impl_test_lib"] + test_deps,
)

# Test 6: Multiple exclusions with exclude_transitives=True
dependencyset(
    name = "deps_multi_excl_transitives",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b"],
    deps_exclude_paths = ["lib_g"],
    exclude_transitives = True,
)

dependencyset(
    name = "runtime_deps_multi_excl_transitives",
    items = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b"],
    deps_exclude_paths = ["lib_g"],
    exclude_transitives = True,
)

java_library(
    name = "multiple_exclusions_with_transitive_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":deps_multi_excl_transitives"],
    runtime_deps = [":runtime_deps_multi_excl_transitives"],
)

multiple_exclusions_with_transitive_test(
    name = "multiple_exclusions_with_transitive_test",
    test_lib = ":multiple_exclusions_with_transitive_test_lib",
)

java_test(
    name = "DepsFilterMultipleExclusionsWithTransitiveTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterMultipleExclusionsWithTransitiveTest.java"
    ],
    deps = [":multiple_exclusions_with_transitive_test_lib"] + test_deps,
)

# Test 7: Multiple exclusions with exclude_transitives=False
dependencyset(
    name = "deps_multi_excl_no_transitives",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b"],
    deps_exclude_paths = ["lib_g"],
    exclude_transitives = False,
)

dependencyset(
    name = "runtime_deps_multi_excl_no_transitives",
    items = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b"],
    deps_exclude_paths = ["lib_g"],
    exclude_transitives = False,
)

java_library(
    name = "multiple_exclusions_without_transitive_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":deps_multi_excl_no_transitives"],
    runtime_deps = [":runtime_deps_multi_excl_no_transitives"],
)

multiple_exclusions_without_transitive_test(
    name = "multiple_exclusions_without_transitive_test",
    test_lib = ":multiple_exclusions_without_transitive_test_lib",
)

java_test(
    name = "DepsFilterMultipleExclusionsWithoutTransitiveTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterMultipleExclusionsWithoutTransitiveTest.java"
    ],
    deps = [":multiple_exclusions_without_transitive_test_lib"] + test_deps,
)

# Test 8: Empty exclusion lists
dependencyset(
    name = "deps_empty_exclusions",
    items = [":lib_a", ":lib_i"],
    deps_exclude_paths = [],
    deps_exclude_labels = [],
)

dependencyset(
    name = "runtime_deps_empty_exclusions",
    items = [":lib_h", ":lib_j"],
    deps_exclude_paths = [],
    deps_exclude_labels = [],
)

java_library(
    name = "empty_exclusion_lists_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":deps_empty_exclusions"],
    runtime_deps = [":runtime_deps_empty_exclusions"],
)

empty_exclusion_lists_test(
    name = "deps_filter_empty_exclusions_test",
    test_lib = ":empty_exclusion_lists_test_lib",
)

java_test(
    name = "DepsFilterEmptyExclusionsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterEmptyExclusionsTest.java"
        ],
    deps = [":empty_exclusion_lists_test_lib"] + test_deps,
)

# Test 9: Multiple paths handling
dependencyset(
    name = "deps_multiple_paths_exclude_b_g",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

dependencyset(
    name = "runtime_deps_multiple_paths_exclude_b_g",
    items = [":lib_h", ":lib_j"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

java_library(
    name = "multiple_paths_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    deps = [":deps_multiple_paths_exclude_b_g"],
    runtime_deps = [":runtime_deps_multiple_paths_exclude_b_g"],
)

multiple_paths_test(
    name = "deps_filter_multiple_paths_test",
    test_lib = ":multiple_paths_test_lib",
)

java_test(
    name = "DepsFilterMultiplePathsTest",
    size = "small",
    srcs = [
        "src/test/java/com/depsfilter/DepsFilterTestHelper.java",
        "src/test/java/com/depsfilter/DepsFilterMultiplePathsTest.java"
    ],
    deps = [":multiple_paths_test_lib"] + test_deps,
)

toolchain(
    name = "unittest_toolchain",
    toolchain_type = "@bazel_skylib//toolchains/unittest:toolchain_type",
    toolchain = "@bazel_skylib//toolchains/unittest:toolchain",
)

