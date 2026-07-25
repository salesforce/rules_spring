load("@rules_java//java:defs.bzl", "java_library")
load("//springboot/deps_filter_rules:deps_filter.bzl", "deps_filter")
load(
    "//springboot/deps_filter_rules/tests/depsfilter/internal_dependencies/runtime_only:runtime_only_test.bzl",
    "empty_exclusion_lists_test",
    "filtered_deps_exclude_transitive_test",
    "filtered_deps_test",
    "interface_implementation_jars_test",
    "multiple_exclusions_with_transitive_test",
    "multiple_exclusions_without_transitive_test",
    "multiple_paths_test",
    "no_filtering_test",
    "path_based_exclusions_test",
)

# Dependency Graph Structure:

#      base_lib
#       /   \
#     A      G
#    / \    /
#   B   E  /
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
    runtime_deps = [":lib_c"],  # B -> C
)

java_library(
    name = "lib_c",
    srcs = ["src/main/java/com/depsfilter/C.java"],
    runtime_deps = [":lib_d"],  # B -> D
)

java_library(
    name = "lib_d",
    srcs = ["src/main/java/com/depsfilter/D.java"],
)

java_library(
    name = "lib_e",
    srcs = ["src/main/java/com/depsfilter/E.java"],
    runtime_deps = [":lib_f"],  # E -> F
)

java_library(
    name = "lib_f",
    srcs = ["src/main/java/com/depsfilter/F.java"],
    runtime_deps = [":lib_c"],  # F -> C
)

java_library(
    name = "lib_g",
    srcs = ["src/main/java/com/depsfilter/G.java"],
    runtime_deps = [":lib_f"],  # G -> F path
)

# Consumer library that uses the filtered dependencies
java_library(
    name = "base_lib",
    srcs = ["src/main/java/com/depsfilter/H.java"],
    runtime_deps = [
        ":lib_a",
        ":lib_g",
    ],
)

# Test 1: No filtering
deps_filter(
    name = "filtered_deps",
    deps = [":base_lib"],
)

no_filtering_test(
    name = "deps_filter_no_filtering_test",
    deps_filter = ":filtered_deps",  # deps_filter with no exclusions
    java_library = ":base_lib",
)

# Test 2: Exclude by labels and exclude_transitives = False
deps_filter(
    name = "filtered_deps_exclude_b_g",
    deps_exclude_labels = [
        ":lib_b",
        ":lib_g",
    ],
    runtime_deps = [":base_lib"],
)

filtered_deps_test(
    name = "deps_filter_exclude_b_g_test",
    filtered = ":filtered_deps_exclude_b_g",
)

# Test 3: Exclude by labels and exclude_transitives = True
deps_filter(
    name = "filtered_deps_exclude_b_g_exclude_transitive",
    deps_exclude_labels = [
        ":lib_b",
        ":lib_g",
    ],
    exclude_transitives = True,
    runtime_deps = [":base_lib"],
)

filtered_deps_exclude_transitive_test(
    name = "deps_filter_exclude_b_g_exclude_transitive_test",
    filtered = ":filtered_deps_exclude_b_g_exclude_transitive",
)

# Test 4: Test for path-based exclusions
deps_filter(
    name = "path_based_filtered_deps",
    deps_exclude_paths = [
        "lib_b",
        "lib_f",
    ],
    runtime_deps = [":base_lib"],
)

path_based_exclusions_test(
    name = "deps_filter_path_based_exclusions_test",
    filtered = ":path_based_filtered_deps",
)

# Test 5: Interface vs Implementation JARs
deps_filter(
    name = "interface_impl_filtered_deps",
    deps_exclude_labels = [
        ":lib_b",
        ":lib_g",
    ],
    runtime_deps = [":base_lib"],
)

interface_implementation_jars_test(
    name = "deps_filter_interface_impl_test",
    filtered = ":interface_impl_filtered_deps",
)

# Test 6: Multiple exclusions with exclude_transitives=True
deps_filter(
    name = "multiple_exclusions_filtered_deps_1",
    deps_exclude_labels = [":lib_b"],
    deps_exclude_paths = ["lib_g"],
    exclude_transitives = True,
    runtime_deps = [":base_lib"],
)

multiple_exclusions_with_transitive_test(
    name = "multiple_exclusions_with_transitive_test",
    filtered = ":multiple_exclusions_filtered_deps_1",
)

# Test 7: Multiple exclusions with exclude_transitives=False
deps_filter(
    name = "multiple_exclusions_filtered_deps_2",
    deps_exclude_labels = [":lib_b"],
    deps_exclude_paths = ["lib_g"],
    exclude_transitives = False,
    runtime_deps = [":base_lib"],
)

multiple_exclusions_without_transitive_test(
    name = "multiple_exclusions_without_transitive_test",
    filtered = ":multiple_exclusions_filtered_deps_2",
)

# Test 8: Empty exclusion lists
deps_filter(
    name = "empty_exclusions_filtered_deps",
    deps_exclude_labels = [],
    deps_exclude_paths = [],
    runtime_deps = [":base_lib"],
)

empty_exclusion_lists_test(
    name = "deps_filter_empty_exclusions_test",
    filtered = ":empty_exclusions_filtered_deps",
)

# Test 9: Multiple paths handling
deps_filter(
    name = "multiple_paths_filtered_deps",
    deps_exclude_labels = [
        ":lib_b",
        ":lib_g",
    ],
    runtime_deps = [":base_lib"],
)

multiple_paths_test(
    name = "deps_filter_multiple_paths_test",
    filtered = ":multiple_paths_filtered_deps",
)

toolchain(
    name = "unittest_toolchain",
    toolchain = "@bazel_skylib//toolchains/unittest:toolchain",
    toolchain_type = "@bazel_skylib//toolchains/unittest:toolchain_type",
)
