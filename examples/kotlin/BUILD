#
# Copyright (c) 2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

load(
    "@io_bazel_rules_kotlin//kotlin:kotlin.bzl",
    "define_kt_toolchain",
    "kt_compiler_plugin",
    "kt_javac_options",
    "kt_jvm_library",
    "kt_kotlinc_options",
)

KOTLIN_LANGUAGE_LEVEL = "1.4"

kt_kotlinc_options(
    name = "kotlinc_options",
    x_allow_result_return_type = True,
    x_inline_classes = True,
    #    x_opt_in = ["kotlinx.coroutines.ExperimentalCoroutinesApi"]
)

kt_javac_options(
    name = "default_javac_options",
)

define_kt_toolchain(
    name = "kotlin_toolchain",
    api_version = KOTLIN_LANGUAGE_LEVEL,  # "1.1", "1.2", or "1.3"
    javac_options = ":default_javac_options",
    jvm_target = "1.8",  # "1.6", "1.8", "9", "10", "11", or "12",
    kotlinc_options = ":kotlinc_options",
    language_version = KOTLIN_LANGUAGE_LEVEL,  # "1.1", "1.2", or "1.3"
)

kt_compiler_plugin(
    name = "serialization_plugin",
    compile_phase = True,
    id = "org.jetbrains.kotlin.serialization",
    stubs_phase = True,
    visibility = ["//visibility:public"],
    deps = [
        "@com_github_jetbrains_kotlin//:kotlinx-serialization-compiler-plugin",
    ],
)

kt_jvm_library(
    name = "kotlin_serialization",
    srcs = [],
    exported_compiler_plugins = [":serialization_plugin"],
    visibility = ["//visibility:public"],
    exports = [
        "@maven//:org_jetbrains_kotlinx_kotlinx_serialization_core_jvm",
    ],
)

kt_compiler_plugin(
    name = "no_arg_plugin",
    compile_phase = True,
    id = "org.jetbrains.kotlin.noarg",
    options = {
        "preset": "jpa",
    },
    stubs_phase = True,
    visibility = ["//visibility:public"],
    deps = [
        "@com_github_jetbrains_kotlin//:noarg-compiler-plugin",
    ],
)

kt_compiler_plugin(
    name = "allopen_plugin",
    compile_phase = True,
    id = "org.jetbrains.kotlin.allopen",
    options = {
        "preset": "spring",
    },
    stubs_phase = True,
    visibility = ["//visibility:public"],
    deps = [
        "@com_github_jetbrains_kotlin//:allopen-compiler-plugin",
    ],
)
