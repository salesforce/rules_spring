#
# Copyright (c) 2020, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

deps = [
    "@org_slf4j_slf4j_api//jar",
]

test_deps = [
    "@junit_junit",
    "@org_hamcrest_hamcrest_core//jar",
    "@org_springframework_boot_spring_boot_test//jar",
    "@org_springframework_spring_test//jar",
]

java_library(
    name = "lib2",
    srcs = glob(["src/main/java/**/*.java"]),
    resources = glob(["src/main/resources/**"]),
    visibility = ["//visibility:public"],
    deps = deps,
)
