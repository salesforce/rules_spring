#
# Copyright (c) 2017-9, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

# load our Spring Boot rule
load("//tools/springboot:springboot.bzl", "springboot")

# dependencies from other packages in the workspace
lib_deps = [
  "//samples/helloworld/libs/lib1",
  "//samples/helloworld/libs/lib2",
]

filegroup(
    name = "dupe_class_allowlist",
    srcs = glob([
        "helloworld_dupeclass_allowlist.txt",
    ]),
)

# create our deps list for Spring Boot
springboot_deps = [
    "//tools/springboot/import_bundles:springboot_required_deps",
    "//tools/springboot/import_bundles:springboot_jetty_starter_deps",
    "//tools/springboot/import_bundles:springboot_web_starter_deps",
]

# This Java library contains the app code
java_library(
    name = "helloworld_lib",
    srcs = glob(["src/main/java/**/*.java"]),
    resources = glob(["src/main/resources/**"]),
    deps = springboot_deps + lib_deps,
)

# Build the app as a Spring Boot executable jar
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",

    # TO TEST THE DUPE CLASSES FEATURE: change this to fail_on_duplicate_classes = True
    # there is an intentionally duplicated class in lib1 and lib2
    fail_on_duplicate_classes = True,
    duplicate_class_allowlist = ":dupe_class_allowlist",

    java_library = ":helloworld_lib",
    deps = springboot_deps + lib_deps,
)
