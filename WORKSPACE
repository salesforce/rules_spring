#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#
workspace(name = "rules_spring")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

RULES_JVM_EXTERNAL_TAG = "3.3"
RULES_JVM_EXTERNAL_SHA = "d85951a92c0908c80bd8551002d66cb23c3434409c814179c0ff026b53544dab"

http_archive(
    name = "rules_jvm_external",
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    sha256 = RULES_JVM_EXTERNAL_SHA,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("//:repositories.bzl", "rules_spring_deps")
rules_spring_deps()

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


#
# STARDOC
#
# Enable only when generating the doc, then disable again before releasing. We don't want to require
# users of the rule to configure stardoc in their workspace. You need to uncomment the stardoc generation in
# //springboot/BUILD as well.

#git_repository(
#    name = "io_bazel_stardoc",
#    remote = "https://github.com/bazelbuild/stardoc.git",
#    tag = "0.4.0",
#)
#load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")
#stardoc_repositories()
