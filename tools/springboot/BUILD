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
    "dupe_class_jar_allowlist.txt",
    "empty.txt",
])


# -------------------------------
# JAVA RULE IMPL

deps = [
  # do not add any upstream deps, as that creates a config impact on rule users;
  # implement everything from scratch
]

test_deps = [
    "@maven//:junit_junit",
    #"@maven//:org_mockito_mockito_core",
]

java_library(
    name = "springboot_rule_lib",
    srcs = glob(["src/main/java/**/*.java"]),
    javacopts = ["--release 8"],
    #resources = glob(["src/main/resources/**/*"]),
    visibility = ["//visibility:public"],
    deps = deps,
)

java_binary(
    name = "springboot",
    srcs = glob(["src/main/java/com/salesforce/bazel/springboot/SpringBootRuleMain.java"]),
    main_class = "com.salesforce.bazel.springboot.SpringBootRuleMain",
    javacopts = ["--release 8"],
    #resources = glob(["src/main/resources/**/*"]),
    visibility = ["//visibility:public"],
    deps = [":springboot_rule_lib"] + deps,
)

[java_test(
    name = name[:-len(".java")],
    size = "medium",
    srcs = [name],
    deps = [":springboot_rule_lib"] + deps + test_deps,
) for name in glob(["src/test/java/**/*Test.java"])]


# -------------------------------
# LEGACY RULE IMPL (bash + python)

exports_files([
    "springboot_pkg.sh",
    "check_dupe_classes.py",
    "write_gitinfo_properties.sh",
    "write_manifest.sh",
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
