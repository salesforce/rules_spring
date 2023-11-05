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
load("//springboot:springboot.bzl", "springboot")

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
springboot(
    name = "demoapp",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":demoapp_lib",

    # DEPS ARE OPTIONAL HERE
    #  The springboot rule inherits all deps and runtime_deps from the java_library
    # deps = [],

    # TO TEST THE DUPE CLASSES FEATURE:
    #   There is an intentionally duplicated class in lib1 and lib2. Do this:
    #   1. set fail_on_duplicate_classes = True
    #   2. comment out lib1 or lib2 in demoapp_dupeclass_allowlist.txt
    #   Build should fail due to the duplicate class.
    dupeclassescheck_enable = True,
    dupeclassescheck_ignorelist = "demoapp_dupeclass_allowlist.txt",

    # BANNED DEPS
    # These are dependencies that you never want in your springboot jar.
    # This is used to detect mistakes in your transitive dependency graph. They
    # might be test jars, or compile time jars like lombok. The list of strings
    # is matched against the dependency jar filenames with a 'contains' match.
    deps_banned = ["junit", "mockito", "lombok"],

    # Specify optional JVM args to use when the application is launched with 'bazel run'
    bazelrun_jvm_flags = "-Dcustomprop=gold -DcustomProp2=silver",

    # data files can be made available in the working directory for when the app is launched with bazel run
    bazelrun_data = ["example_data.txt"],

    # run the application in the background (command returns immediately)
    #bazelrun_background = True,

    # you may choose to override the launcher script that is used when you invoke 'bazel run //examples/demoapp'
    bazelrun_script = "custom_bazelrun_script.sh",

    # if you have conflicting classes in dependency jar files, you can define the order in which the jars are loaded
    #  https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html#executable-jar-war-index-files-classpath
    deps_index_file = ":demoapp_classpath.idx",

    # sometimes packagers want to put certain files into the root of the springboot app jar
    # these addins will be copied into the root of the generated springboot jar
    addins = [":info.txt", ":author.txt"],
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
