#
# Copyright (c) 2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

load("@io_bazel_rules_kotlin//kotlin:kotlin.bzl", "kt_jvm_library")
load("@rules_spring//springboot:springboot.bzl", "springboot")
#load("//tools/junit5:junit5.bzl", "kotlin_junit5_test")

# DEPENDENCIES
deps = [
    "@rules_spring//springboot/import_bundles:springboot_required_deps",
    "@maven//:org_springframework_boot_spring_boot_actuator",
    "@maven//:org_springframework_boot_spring_boot_starter_jetty",
    "@maven//:org_springframework_boot_spring_boot_starter_web",
    "@maven//:org_springframework_boot_spring_boot_loader_tools",
    "@maven//:org_springframework_spring_webmvc",

    "@maven//:javax_annotation_javax_annotation_api",

    #kotlin
    "@maven//:org_jetbrains_kotlinx_kotlinx_coroutines_core",
    "@maven//:org_jetbrains_kotlinx_kotlinx_coroutines_slf4j",
]

runtime_deps = [
    "@maven//:org_jetbrains_annotations",
    "@maven//:org_jetbrains_kotlin_kotlin_reflect",
    "@maven//:org_jetbrains_kotlin_kotlin_stdlib_common",
    "@maven//:org_jetbrains_kotlin_kotlin_stdlib",
    "@com_github_jetbrains_kotlin//:kotlin-stdlib",
    "@com_github_jetbrains_kotlin//:kotlin-stdlib-jdk7",
    "@com_github_jetbrains_kotlin//:kotlin-stdlib-jdk8",
]

#test_deps = [
#    "//tools/junit5:junit5_deps",
#    "@maven//:org_springframework_boot_spring_boot_starter_test",
#    "@maven//:org_jetbrains_kotlin_kotlin_test_junit",
#    "@maven//:org_jetbrains_kotlinx_kotlinx_coroutines_test",
#    "@maven//:org_assertj_assertj_core",
#    "@maven//:org_jetbrains_kotlin_kotlin_test_annotations_common",
#    "@maven//:org_jetbrains_kotlin_kotlin_test",
#    "@maven//:org_springframework_boot_spring_boot_test",
#    "@maven//:org_springframework_spring_test",
#    "@maven//:com_willowtreeapps_assertk_assertk_jvm",
#    "@maven//:org_awaitility_awaitility",
#    "@maven//:org_mockito_mockito_core",
#    "@maven//:org_objenesis_objenesis",
#    "@maven//:org_yaml_snakeyaml",
#    "@maven//:net_bytebuddy_byte_buddy",
#    "@maven//:net_bytebuddy_byte_buddy_agent",
#]

#LIBRARIES
java_library(
    name = "kotlinapp_javalib",
    srcs = glob(["src/main/java/**/*.java"]),
    resources = glob(["src/main/resources/**/*"]),
    runtime_deps = runtime_deps,
    deps = deps,
)

kt_jvm_library(
    name = "kotlinapp_lib",
    srcs = glob(["src/main/java/**/*.kt"]),
    plugins = [
        "//examples/kotlin:allopen_plugin",
        "//examples/kotlin:no_arg_plugin",
        "//examples/kotlin:serialization_plugin",
    ],
    resources = glob(["src/main/resources/**/*"]),
    runtime_deps = runtime_deps,
    deps = deps + [":kotlinapp_javalib"],
)

springboot(
    name = "kotlinapp",
    boot_app_class = "com.samples.SampleMainKt",
    fail_on_duplicate_classes = False,
    java_library = ":kotlinapp_lib",
    deps = deps + runtime_deps + [":kotlinapp_javalib"],
)

# TEST
#kotlin_junit5_test(
#    name = "tests",
#    size = "large",
#    srcs = glob([
#        "src/test/java/**/*.kt",
#        "src/test/java/**/*.java",
#    ]),
#    friends = [":kotlinapp_lib"],
#    plugins = [
#        "//examples/kotlin:allopen_plugin",
#        "//examples/kotlin:no_arg_plugin",
#        "//examples/kotlin:serialization_plugin",
#    ],
#    resources = glob(["src/*/resources/**"]),
#    tags = [
#        "exclusive",
#        "timings",
#    ],
#    test_package = "com.sample",
#    runtime_deps = runtime_deps,
#    deps = [":kotlinapp_lib"] + test_deps,
#)
