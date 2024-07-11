#
# Copyright (c) 2020-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

deps = [
    "@maven//:org_slf4j_slf4j_api",
]

test_deps = [
    "@maven//:junit_junit",
    "@maven//:org_hamcrest_hamcrest_core",
]

java_library(
    name = "lib1",
    srcs = glob(["src/main/java/**/*.java"]),
    resources = glob(["src/main/resources/**"]),
    visibility = ["//visibility:public"],
    deps = deps,
)

java_test(
   name = "HelloLib1Test",
   srcs = ["src/test/java/com/bazel/demo/HelloLib1Test.java"],
   deps = [ ":lib1" ] + test_deps,
)
