#
# Copyright (c) 2017-9, salesforce.com, inc.
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
])

py_binary(
    name = "check_dupe_classes",
    data = ["dupe_class_jar_allowlist.txt"],
    srcs = [
        "check_dupe_classes.py",
    ],
)

py_test(
    name = "check_dupe_classes_test",
    size = "small",
    srcs = [
        "tests/check_dupe_classes_test.py",
        "check_dupe_classes.py",
    ],
    imports = ["."],
)
