#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#
workspace(name = "bazel_springboot_rule")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

RULES_JVM_EXTERNAL_TAG = "3.3"
RULES_JVM_EXTERNAL_SHA = "d85951a92c0908c80bd8551002d66cb23c3434409c814179c0ff026b53544dab"

http_archive(
    name = "rules_jvm_external",
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    sha256 = RULES_JVM_EXTERNAL_SHA,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("//:external_deps.bzl", "external_maven_jars")
external_maven_jars()

load("@maven//:defs.bzl", "pinned_maven_install")
pinned_maven_install()

load("@spring_boot_starter_jetty//:defs.bzl", pinned_spring_boot_starter_jetty_install = "pinned_maven_install")
pinned_spring_boot_starter_jetty_install()

#
# CAPTIVE PYTHON
#
# Install a specific version of python to be used by the Bazel build with the invocation below.
# Before this will work, you need to follow the instructions in //tools/python_interpreter.

#register_toolchains(
#    "//tools/python_interpreter:captive_python_toolchain",
#)
