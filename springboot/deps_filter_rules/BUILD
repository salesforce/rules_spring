load("//springboot/deps_filter_rules:deps_filter.bzl", "deps_filter")
load("//springboot/deps_filter_rules:deps_filter_disable_transitives.bzl", "deps_filter_disable_transitives")

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
    deps_exclude = [
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
    deps_exclude = [
       "@maven//:org_springframework_spring_web", # share transitives with spring-jdbc
    ],
    exclude_transitives = False,
    testonly = True,
)

deps_filter_disable_transitives(
    name = "Case_A",
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
    name = "Case_B",
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
    name = "Case_C",
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
    name = "Case_D",
    deps = [
        "@maven//:org_springframework_spring_jdbc",
        "@maven//:org_springframework_spring_web",
    ],
    testonly = True,
)

java_test(
    name = "CaseA",
    size = "small",
    srcs = ["src/test/java/com/salesforce/depsfilter/CaseA.java"],
    deps = [":Case_A"] + test_deps,
)

java_test(
    name = "CaseB",
    size = "small",
    srcs = ["src/test/java/com/salesforce/depsfilter/CaseB.java"],
    deps = [":Case_B"] + test_deps,
)

java_test(
    name = "CaseC",
    size = "small",
    srcs = ["src/test/java/com/salesforce/depsfilter/CaseC.java"],
    deps = [":Case_C"] + test_deps,
)

java_test(
    name = "CaseD",
    size = "small",
    srcs = ["src/test/java/com/salesforce/depsfilter/CaseD.java"],
    deps = [":Case_D"] + test_deps,
)


java_test(
    name = "DepsFilterRuleTransitivesExclusionTest",
    size = "small",
    srcs = ["src/test/java/com/salesforce/depsfilter/DepsFilterRuleTransitivesExclusionTest.java"],
    deps = [":filtered_test_deps_with_transitives_excluded"] + test_deps,
)

java_test(
    name = "DepsFilterRuleWithoutTransitivesExclusionTest",
    size = "small",
    srcs = ["src/test/java/com/salesforce/depsfilter/DepsFilterRuleWithoutTransitivesExclusionTest.java"],
    deps = [":filtered_test_deps_without_transitives_excluded"] + test_deps,
)
