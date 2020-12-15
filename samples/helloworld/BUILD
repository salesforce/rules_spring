#
# Copyright (c) 2017-2021, salesforce.com, inc.
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

# service specific list of jars that we dont want to trigger errors for the
# dupe class checker (these jars have known dupe classes)
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
    "@maven//:org_springframework_spring_web",
    "@maven//:org_springframework_spring_webmvc",
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
    duplicate_class_allowlist = ":dupe_class_allowlist",

    # TO TEST THE DUPE CLASSES FEATURE:
    #   There is an intentionally duplicated class in lib1 and lib2. Do this:
    #   1. set fail_on_duplicate_classes = True
    #   2. comment out lib1 or lib2 in helloworld_dupeclass_allowlist.txt
    #   Build should fail due to the duplicate class.
    fail_on_duplicate_classes = True,
    java_library = ":helloworld_lib",

    # Specify optional JVM args to use when the application is launched with 'bazel run'
    jvm_flags = "-Dcustomprop=gold",

    # data files can be made available in the working directory for when the app is launched with bazel run
    data = ["example_data.txt"],
)
