#
# Copyright (c) 2017-2024, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

# NOTE:
#   This sample is embedded in the same workspace as the springboot rule. Therefore references
#   to local path "//springboot" work here. But you will need to change them to:
#   "@rules_spring//springboot" when you consume the official release via http_archive.

load("//springboot:springboot.bzl", "springboot")
load("//springboot:deps_filter_transitive.bzl", "deps_filter_transitive")
load("//tools/license:licenses_used.bzl", "licenses_used")

# dependencies from other packages in the workspace
deps = [
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

    # bring in same dep again as above, but through a different maven_install
    # rule: the springboot rule does not package duplicate deps, first one wins
    #"@spring_boot_starter_jetty//:org_springframework_boot_spring_boot_starter_jetty",
]

# Sometimes you have a transitive that you don't want. The unwanted_classes.md doc
# covers this case, and this snippet shows how to use it:
deps_filter_transitive(
    name = "filtered_deps",
    deps = springboot_deps + deps, # the input list
    deps_exclude = [
        # tomcat comes in transitively, but we want to use jetty
        "@maven//:org_apache_tomcat_embed_tomcat_embed_core",
        "@maven//:org_apache_tomcat_embed_tomcat_embed_el",
        "@maven//:org_apache_tomcat_embed_tomcat_embed_websocket",

        # just a demo of excluding a transitive
        "@maven//:javax_annotation_javax_annotation_api",
    ],
    exclude_transitives = True,
)

# This Java library contains the app code
java_library(
    name = "demoapp_lib",
    srcs = glob(["src/main/java/**/*.java"]),
    resources = glob(["src/main/resources/**"]),
    deps = [":filtered_deps"],
)

# This is just an example of having a dependency that you want only added to
# the springboot jar, not the java_library. This is rare.
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

filegroup(
    name = "bazelrun_data_files",
    srcs = [
        "application.properties",
        "application-dev.properties",
        "config/application.properties",
        "example_data.txt"
    ],
)

# Build the app as a Spring Boot executable jar
# To launch: bazel run //examples/demoapp
springboot(
    name = "demoapp",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":demoapp_lib",

    # SPRING BOOT 3
    # The launcher class changed in between Boot2 and Boot3, so we provide the
    # Boot3 launcher class here (the Boot2 one is the default)
    boot_launcher_class = 'org.springframework.boot.loader.launch.JarLauncher',

    # DEPS ARE OPTIONAL HERE
    #  The springboot rule inherits all deps and runtime_deps from the java_library()
    #  but this jar for uncommon reason is just added to the springboot rule.
    deps = [ ":rootclassloader_lib", ],

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
    bazelrun_jvm_flags = "-Dcustomprop=gold -DcustomProp2=silver", # old way
    bazelrun_jvm_flag_list = ["-Dcustomprop3=bronze", "-DcustomProp4=copper"], # new way
    # Specify optional environment variables to set when the application is launched with 'bazel run'
    bazelrun_env_flag_list = ["PROP1=blue", "PROP2=green"],

    # add JVM exports/opens for Java modularization
    bazelrun_addexports = [
        "java.base/java.base=ALL-UNNAMED",
        "java.base/java.io=ALL-UNNAMED",
        "java.base/java.nio=ALL-UNNAMED",
    ],
    bazelrun_addopens = [
        "java.base/java.util.concurrent=ALL-UNNAMED",
        "java.base/java.util.logging=ALL-UNNAMED",
    ],
    
    # data files can be made available in the working directory for when the app is launched with bazel run
    bazelrun_data = [":bazelrun_data_files"],

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

licenses_used(
    name = "demoapp_licenses",
    out = "demoapp_licenses.json",
    deps = [":demoapp"],
)

# Prove that we can have a second springboot() app in the same BUILD file.
#   https://github.com/salesforce/rules_spring/issues/139
# To launch: bazel run //examples/demoapp:demoapp-second
springboot(
    name = "demoapp-second",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":demoapp_lib",
    boot_launcher_class = 'org.springframework.boot.loader.launch.JarLauncher',
    deps = [ ":rootclassloader_lib", ],
)