#
# Copyright (c) 2017-2024, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

#
# BRING YOUR OWN JAVA DEPENDENCIES
# rules_spring stays out of the game of Java dependency management for your applications.
# You will build your Spring Boot application code using standard Bazel Java rules before
# invoking the Spring Boot rule. The springboot rule takes a built java_library containing your
# Spring Boot application. Because of this, rules_spring does not need to populate
# Java dependencies into your WORKSPACE. This file is just here to build the examples.
#
#
# SAMPLE LIST OF DEPENDENCIES
# Below is a sample list of dependencies that are typically used for Spring Boot applications.
# You will need have a similar list in your WORKSPACE and curate this list as your project requires it.
# During migration from Maven, you can use the 'mvn dependency:list' command to help you.
#

load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven")

repositories = [
    "https://repo1.maven.org/maven2",
]

def rules_spring_example_deps():

    # Primary dependency list
    # After updating the sample list below, you need to regenerate the pinned target list:
    #  bazel run @unpinned_maven//:pin
    maven_install(
        artifacts = [
            "org.slf4j:slf4j-api:2.0.13",
            "org.springframework.boot:spring-boot:3.3.5",
            "org.springframework.boot:spring-boot-actuator:3.3.5",
            "org.springframework.boot:spring-boot-actuator-autoconfigure:3.3.5",
            "org.springframework.boot:spring-boot-autoconfigure:3.3.5",
            "org.springframework.boot:spring-boot-configuration-processor:3.3.5",
            "org.springframework.boot:spring-boot-loader:3.3.5",
            "org.springframework.boot:spring-boot-loader-tools:3.3.5",
            "org.springframework.boot:spring-boot-starter:3.3.5",
            "org.springframework.boot:spring-boot-starter-actuator:3.3.5",
            "org.springframework.boot:spring-boot-starter-freemarker:3.3.5",
            "org.springframework.boot:spring-boot-starter-jdbc:3.3.5",
            "org.springframework.boot:spring-boot-starter-jetty:3.3.5",
            "org.springframework.boot:spring-boot-starter-logging:3.3.5",
            "org.springframework.boot:spring-boot-starter-security:3.3.5",
            "org.springframework.boot:spring-boot-starter-test:3.3.5",
            "org.springframework.boot:spring-boot-starter-web:3.3.5",
            "org.springframework.boot:spring-boot-test:3.3.5",
            "org.springframework.boot:spring-boot-test-autoconfigure:3.3.5",
            "org.springframework.boot:spring-boot-starter-thymeleaf:3.3.5",

            "org.springframework:spring-aop:6.1.14",
            "org.springframework:spring-aspects:6.1.14",
            "org.springframework:spring-beans:6.1.14",
            "org.springframework:spring-context:6.1.14",
            "org.springframework:spring-context-support:6.1.14",
            "org.springframework:spring-core:6.1.14",
            "org.springframework:spring-expression:6.1.14",
            "org.springframework:spring-jdbc:6.1.14",
            "org.springframework:spring-test:6.1.14",
            "org.springframework:spring-tx:6.1.14",
            "org.springframework:spring-web:6.1.14",
            "org.springframework:spring-webmvc:6.1.14",

            # intentionally ancient version annotation-api; in demoapp we use
            # a filter to exclude this dependency
            "javax.annotation:javax.annotation-api:1.3.2",

            # test deps
            "junit:junit:4.13.2",
            "org.hamcrest:hamcrest-core:2.2",
        ],
        excluded_artifacts = [
            "org.springframework.boot:spring-boot-starter-tomcat",
        ],
        repositories = repositories,
        fetch_sources = True,
        version_conflict_policy = "pinned",
        strict_visibility = True,
        generate_compat_repositories = False,
        maven_install_json = "@rules_spring//:maven_install.json",
        resolve_timeout = 1800,
    )

    # Alternate dependency list
    # this rule exists to test how the springboot rule handles duplicate
    # artifacts: org.springframework.boot:spring-boot-starter-jetty is also
    # brought in by the rule above
    # to update: bazel run @unpinned_spring_boot_starter_jetty//:pin
    maven_install(
        name = "spring_boot_starter_jetty",
        artifacts = [
            "org.springframework.boot:spring-boot-starter-jetty:3.3.5",
        ],
        repositories = repositories,
        fetch_sources = True,
        version_conflict_policy = "pinned",
        strict_visibility = True,
        generate_compat_repositories = False,
        maven_install_json = "@rules_spring//:spring_boot_starter_jetty_install.json",
        resolve_timeout = 1800,
    )
