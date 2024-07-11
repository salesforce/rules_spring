#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

# NOTE:
#   This sample is embedded in the same workspace as the springboot rule. Therefore references
#   to local path "//springboot" work here. But you will need to change them to:
#   "@rules_spring//springboot" when you consume the official release via http_archive.

# load our Spring Boot rule
load("//springboot:springbootjar.bzl", "springbootjar")

# dependencies from other packages in the workspace
lib_deps = [
    "//examples/demoapp/libs/lib1",
    "//examples/demoapp/libs/lib2",
]

# create our deps list for Spring Boot
springboot_deps = [
    "//springboot/import_bundles:springboot_required_deps",
    "@maven//:org_springframework_boot_spring_boot_starter_jetty",
    "@maven//:org_springframework_boot_spring_boot_starter_web",
    "@maven//:org_springframework_boot_spring_boot_loader_tools",
    "@maven//:org_springframework_spring_webmvc",

    "@maven//:javax_annotation_javax_annotation_api",

    # bring in same dep again as above, but through a different maven_install
    # rule: the springboot rule does not package duplicate deps, first one wins
    "@spring_boot_starter_jetty//:org_springframework_boot_spring_boot_starter_jetty",
]

# This Java library contains the app code
java_library(
    name = "demoapp_lib",
    srcs = glob(["src/main/java/**/*.java"]),
    resources = glob(["src/main/resources/**"]),
    deps = springboot_deps + lib_deps,
)

java_library(
    name = "rootclassloader_lib",
    srcs = glob(["src_root/main/java/**/*.java"]),
)

test_deps = [
    "@maven//:junit_junit",
    "@maven//:org_hamcrest_hamcrest_core",
]

java_test(
   name = "SampleRestUnitTest",
   srcs = ["src/test/java/com/sample/SampleRestUnitTest.java"],
   deps = [ ":demoapp_lib" ] + test_deps,
)

# Build the app as a Spring Boot executable jar
springbootjar(
    name = "demoapp",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":demoapp_lib",

    deps = [ ":rootclassloader_lib", ],
)

springboottest_deps = [
    "@maven//:org_springframework_spring_beans",
    "@maven//:org_springframework_boot_spring_boot_test",
    "@maven//:org_springframework_spring_test",
]

java_test(
    name = "SampleRestFuncTest",
    srcs = ["src/test/java/com/sample/SampleRestFuncTest.java"],
    deps = [ ":demoapp_lib" ] + test_deps + springboottest_deps,
    resources = glob(["src/test/resources/**"]),
)
