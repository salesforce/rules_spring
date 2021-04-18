#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

# Spring Boot Packager
# (implemented by Salesforce)

# See the README.md file for detailed usage instructions.

exports_files([
    "springboot.bzl",
    "springboot_pkg.sh",
    "check_dupe_classes.py",
    "write_gitinfo_properties.sh",
    "write_manifest.sh",
    "write_bazelrun_env.sh",
    "default_bazelrun_script.sh",
    "dupe_class_jar_allowlist.txt",
    "empty.txt",
])

py_binary(
    name = "check_dupe_classes",
    srcs = [
        "check_dupe_classes.py",
    ],
    visibility = ["//visibility:public"],
)

py_test(
    name = "check_dupe_classes_test",
    size = "small",
    srcs = [
        "check_dupe_classes.py",
        "tests/check_dupe_classes_test.py",
    ],
    imports = ["."],
)

# Enable only when generating the doc, then disable again before releasing. We don't want to require
# users of the rule to configure stardoc in their workspace. You need to uncomment the WORKSPACE def
# for this before using.
#load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")
#stardoc(
#    name = "springboot-docs",
#    input = "springboot.bzl",
#    out = "springboot_doc.md",
#)
#
# After running, copy the generated file:
#  cp bazel-bin/springboot/springboot_doc.md springboot
