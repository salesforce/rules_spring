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
