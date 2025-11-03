load("//springboot/deps_filter_rules:dependencyset.bzl", "dependencyset")
load(
    "//springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/runtime_only:runtime_only_test.bzl",
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

#      base_lib      
#         |
#  dependencyset("runtime_deps")
#       /   \  
#     A      I
#    / \    /
#   B   E  G
#   |   | /
#   |   F
#    \/
#    C
#    | 
#    D   
#

java_library(
    name = "lib_a",
    srcs = ["src/main/java/com/depsfilter/A.java"],
    runtime_deps = [
        ":lib_b",  # A -> B 
        ":lib_e",  # A -> E 
    ],
)

java_library(
    name = "lib_b",
    srcs = ["src/main/java/com/depsfilter/B.java"],  
    runtime_deps = [":lib_c"], # B -> C
)

java_library(
    name = "lib_c",
    srcs = ["src/main/java/com/depsfilter/C.java"],
    runtime_deps = [":lib_d"], # B -> D
)

java_library(
    name = "lib_d",
    srcs = ["src/main/java/com/depsfilter/D.java"], 
)

java_library(
    name = "lib_e",
    srcs = ["src/main/java/com/depsfilter/E.java"],
    runtime_deps = [":lib_f"], # E -> F
)

java_library(
    name = "lib_f",
    srcs = ["src/main/java/com/depsfilter/F.java"],
    runtime_deps = [":lib_c"], # F -> C
)

java_library(
    name = "lib_g",
    srcs = ["src/main/java/com/depsfilter/G.java"],
    runtime_deps = [":lib_f"], # G -> F path
)

java_library(
    name = "lib_i",
    srcs = ["src/main/java/com/depsfilter/I.java"],
    runtime_deps = [":lib_g"], # I -> G path
)

# Consumer library that uses the filtered dependencies
java_library(
    name = "base_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":lib_a", ":lib_i"],
)

# Test 1: No filtering
dependencyset(
    name = "runtime_deps_no_filtering",
    items = [":lib_a", ":lib_i"],
)

java_library(
    name = "runtime_no_filtering_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":runtime_deps_no_filtering"],
)

no_filtering_test(
    name = "deps_filter_no_filtering_test",
    java_library = ":base_lib",
    java_library_dependencyset = ":runtime_no_filtering_test_lib",
)

# Test 2: Exclude by labels and exclude_transitives = False
dependencyset(
    name = "runtime_deps_exclude_b_g",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

java_library(
    name = "runtime_exclude_b_g_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":runtime_deps_exclude_b_g"],
)

filtered_deps_test(
    name = "deps_filter_exclude_b_g_test",
    test_lib = ":runtime_exclude_b_g_test_lib",
)

# Test 3: Exclude by labels and exclude_transitives = True
dependencyset(
    name = "runtime_deps_exclude_b_g_transitives",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
    exclude_transitives = True,
)

java_library(
    name = "runtime_exclude_b_g_transitives_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":runtime_deps_exclude_b_g_transitives"],
)

filtered_deps_exclude_transitive_test(
    name = "deps_filter_exclude_b_g_exclude_transitive_test",
    test_lib = ":runtime_exclude_b_g_transitives_test_lib",
)

# Test 4: Test for path-based exclusions
dependencyset(
    name = "runtime_deps_exclude_paths",
    items = [":lib_a", ":lib_i"],
    deps_exclude_paths = ["lib_b", "lib_f"],
)

java_library(
    name = "runtime_exclude_paths_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":runtime_deps_exclude_paths"],
)

path_based_exclusions_test(
    name = "deps_filter_path_based_exclusions_test",
    test_lib = ":runtime_exclude_paths_test_lib",
)

# Test 5: Interface vs Implementation JARs
dependencyset(
    name = "runtime_deps_interface_impl_exclude_b_g",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

java_library(
    name = "runtime_interface_impl_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":runtime_deps_interface_impl_exclude_b_g"],
)

interface_implementation_jars_test(
    name = "deps_filter_interface_impl_test",
    test_lib = ":runtime_interface_impl_test_lib",
)

# Test 6: Multiple exclusions with exclude_transitives=True
dependencyset(
    name = "runtime_deps_multi_excl_transitives",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b"],
    deps_exclude_paths = ["lib_g"],
    exclude_transitives = True,
)

java_library(
    name = "runtime_multi_excl_transitives_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":runtime_deps_multi_excl_transitives"],
)

multiple_exclusions_with_transitive_test(
    name = "multiple_exclusions_with_transitive_test",
    test_lib = ":runtime_multi_excl_transitives_test_lib",
)

# Test 7: Multiple exclusions with exclude_transitives=False
dependencyset(
    name = "runtime_deps_multi_excl_no_transitives",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b"],
    deps_exclude_paths = ["lib_g"],
    exclude_transitives = False,
)

java_library(
    name = "runtime_multi_excl_no_transitives_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":runtime_deps_multi_excl_no_transitives"],
)

multiple_exclusions_without_transitive_test(
    name = "multiple_exclusions_without_transitive_test",
    test_lib = ":runtime_multi_excl_no_transitives_test_lib",
)

# Test 8: Empty exclusion lists
dependencyset(
    name = "runtime_deps_empty_exclusions",
    items = [":lib_a", ":lib_i"],
    deps_exclude_paths = [],
    deps_exclude_labels = [],
)

java_library(
    name = "runtime_empty_exclusions_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":runtime_deps_empty_exclusions"],
)

empty_exclusion_lists_test(
    name = "deps_filter_empty_exclusions_test",
    test_lib = ":runtime_empty_exclusions_test_lib",
)

# Test 9: Multiple paths handling
dependencyset(
    name = "runtime_deps_multiple_paths_exclude_b_g",
    items = [":lib_a", ":lib_i"],
    deps_exclude_labels = [":lib_b", ":lib_g"],
)

java_library(
    name = "runtime_multiple_paths_test_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [":runtime_deps_multiple_paths_exclude_b_g"],
)

multiple_paths_test(
    name = "deps_filter_multiple_paths_test",
    test_lib = ":runtime_multiple_paths_test_lib",
)


toolchain(
    name = "unittest_toolchain",
    toolchain_type = "@bazel_skylib//toolchains/unittest:toolchain_type",
    toolchain = "@bazel_skylib//toolchains/unittest:toolchain",
)
