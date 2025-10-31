load("//springboot/deps_filter_rules_legacy:deps_filter.bzl", "deps_filter")
load("//springboot/deps_filter_rules_legacy:deps_filter_disable_transitives.bzl", "deps_filter_disable_transitives")

deps = [
    "@maven//:org_springframework_spring_jdbc",
    "@maven//:org_springframework_spring_web",
]

test_deps = [
    "@maven//:junit_junit",
    "@maven//:org_assertj_assertj_core",
]

deps_filter(
    name = "filtered_test_deps_with_transitives_excluded",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    deps_exclude_labels = [
        "@maven//:org_springframework_spring_web", # share transitives with spring-jdbc
    ],
    exclude_transitives = True,
    testonly = True,
)

deps_filter(
    name = "filtered_test_deps_without_transitives_excluded",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    deps_exclude_labels = [
       "@maven//:org_springframework_spring_web", # share transitives with spring-jdbc
    ],
    exclude_transitives = False,
    testonly = True,
)

deps_filter_disable_transitives(
    name = "filtered_deps_disable_transitives_case_A",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    deps_to_exclude_transitives = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    testonly = True,
)

deps_filter_disable_transitives(
    name = "filtered_deps_disable_transitives_case_B",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    deps_to_exclude_transitives = [
        # "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    testonly = True,
)

deps_filter_disable_transitives(
    name = "filtered_deps_disable_transitives_case_C",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    deps_to_exclude_transitives = [
        "@maven//:org_springframework_spring_jdbc",
        # "@maven//:org_springframework_spring_web",
    ],
    testonly = True,
)

deps_filter_disable_transitives(
    name = "filtered_deps_disable_transitives_case_D",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    testonly = True,
)

java_test(
    name = "TransitiveDepsFilterCaseA",
    size = "small",
    srcs = ["src/test/java/com/depsfilter/TransitiveDepsFilterCaseA.java"],
    deps = [":filtered_deps_disable_transitives_case_A"] + test_deps,
)

java_test(
    name = "TransitiveDepsFilterCaseB",
    size = "small",
    srcs = ["src/test/java/com/depsfilter/TransitiveDepsFilterCaseB.java"],
    deps = [":filtered_deps_disable_transitives_case_B"] + test_deps,
)

java_test(
    name = "TransitiveDepsFilterCaseC",
    size = "small",
    srcs = ["src/test/java/com/depsfilter/TransitiveDepsFilterCaseC.java"],
    deps = [":filtered_deps_disable_transitives_case_C"] + test_deps,
)

java_test(
    name = "TransitiveDepsFilterCaseD",
    size = "small",
    srcs = ["src/test/java/com/depsfilter/TransitiveDepsFilterCaseD.java"],
    deps = [":filtered_deps_disable_transitives_case_D"] + test_deps,
)


java_test(
    name = "DepsFilterWithTransitivesExclusionTest",
    size = "small",
    srcs = ["src/test/java/com/depsfilter/DepsFilterWithTransitivesExclusionTest.java"],
    deps = [":filtered_test_deps_with_transitives_excluded"] + test_deps,
)

java_test(
    name = "DepsFilterWithoutTransitivesExclusionTest",
    size = "small",
    srcs = ["src/test/java/com/depsfilter/DepsFilterWithoutTransitivesExclusionTest.java"],
    deps = [":filtered_test_deps_without_transitives_excluded"] + test_deps,
)
