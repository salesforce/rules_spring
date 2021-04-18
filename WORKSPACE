#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#
workspace(name = "rules_spring_examples_kotlin")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


# MAVEN DEPS
RULES_JVM_EXTERNAL_TAG = "3.3"
RULES_JVM_EXTERNAL_SHA = "d85951a92c0908c80bd8551002d66cb23c3434409c814179c0ff026b53544dab"

http_archive(
    name = "rules_jvm_external",
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    sha256 = RULES_JVM_EXTERNAL_SHA,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

# SPRING BOOT
http_archive(
    name = "rules_spring",
    sha256 = "7d4f12748df340397559decd8348289a6f85ae32dae344545b6d08ad036a9cfe",
    urls = [
        "https://github.com/salesforce/rules_spring/releases/download/2.0.0/rules-spring-2.0.0.zip",
    ],
)

load("//:repositories.bzl", "rules_spring_deps")
rules_spring_deps()

load("@maven//:defs.bzl", "pinned_maven_install")
pinned_maven_install()



#
# KOTLIN
#
rules_kotlin_version = "v1.5.0-alpha-3"
rules_kotlin_sha = "eeae65f973b70896e474c57aa7681e444d7a5446d9ec0a59bb88c59fc263ff62"
http_archive(
    name = "io_bazel_rules_kotlin",
    sha256 = rules_kotlin_sha,
    type = "tgz",
    urls = [
        "https://github.com/bazelbuild/rules_kotlin/releases/download/%s/rules_kotlin_release.tgz" % rules_kotlin_version,
    ],
)

KOTLIN_VERSION = "1.4.20"
KOTLINC_RELEASE_SHA = "11db93a4d6789e3406c7f60b9f267eba26d6483dcd771eff9f85bb7e9837011f"
KOTLINC_RELEASE = {
    "urls": [
        "https://github.com/JetBrains/kotlin/releases/download/v{v}/kotlin-compiler-{v}.zip".format(v = KOTLIN_VERSION),
    ],
    "sha256": KOTLINC_RELEASE_SHA,
}
load("@io_bazel_rules_kotlin//kotlin:kotlin.bzl", "kotlin_repositories")
kotlin_repositories(compiler_release = KOTLINC_RELEASE)
register_toolchains("//examples/kotlin:kotlin_toolchain")

#
# CAPTIVE PYTHON
#
# Install a specific version of python to be used by the Bazel build with the invocation below.
# Before this will work, you need to follow the instructions in //tools/python_interpreter.

#register_toolchains(
#    "//tools/python_interpreter:captive_python_toolchain",
#)
