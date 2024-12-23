#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

# Spring Boot Packager
# (implemented by Salesforce)

# See the README.md file for detailed usage instructions.

load("@rules_python//python:defs.bzl", "py_binary", "py_test")
load("@rules_license//rules:license.bzl", "license")

# Using a package wide default ensure that all targets are associated with the
# license.
package(
    default_applicable_licenses = [":license"],
    default_visibility = ["//visibility:public"],
)

exports_files([
    "springboot.bzl",
    "springboot_pkg.sh",
    "check_dupe_classes.py",
    "detect_javax_classes.py",
    "write_gitinfo_properties.sh",
    "write_manifest.sh",
    "write_bazelrun_env.sh",
    "default_bazelrun_script.sh",
    "dupe_class_jar_allowlist.txt",
    "empty.txt",
    "addin_end.txt",
])

license(
    name = "license",
    copyright_notice = "Copyright (c) 2017-2024, Salesforce",
    license_kinds = [
        "@rules_license//licenses/spdx:Apache-2.0",
    ],
    license_text = "//:LICENSE.txt",
    package_name = "@rules_spring//springboot",
    package_url = "https://github.com/salesforce/rules_spring",
    package_version = "2.4.2",
    visibility = ["//visibility:public"],
)

py_binary(
    name = "detect_javax_classes",
    srcs = [
        "detect_javax_classes.py",
    ],
    visibility = ["//visibility:public"],
)

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
    tags = ["manual"],
)

java_library(
    name = "springboot_lib",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [],
)

java_binary(
    name = "springboot_cli",
    runtime_deps = [":springboot_lib"],
    main_class = "com.salesforce.rulesspring.cli.SpringBootInspector",
)
