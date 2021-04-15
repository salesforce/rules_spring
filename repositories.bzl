#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

#
# SAMPLE LIST OF DEPENDENCIES
# You will need to curate this list as your project requires it.
# During migration, you can use the 'mvn dependency:list' command to help you.
#
# UPDATING THIS LIST
# After updating the list below, you need to regenerate the pinned target list:
#  bazel run @unpinned_maven//:pin

load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven")

repositories = [
    "https://repo1.maven.org/maven2",
]

def rules_spring_deps():
    maven_install(
        artifacts = [
            "org.slf4j:slf4j-api:1.7.30",
            "org.springframework.boot:spring-boot:2.4.4",
            "org.springframework.boot:spring-boot-actuator:2.4.4",
            "org.springframework.boot:spring-boot-actuator-autoconfigure:2.4.4",
            "org.springframework.boot:spring-boot-autoconfigure:2.4.4",
            "org.springframework.boot:spring-boot-configuration-processor:2.4.4",
            "org.springframework.boot:spring-boot-loader:2.4.4",
            "org.springframework.boot:spring-boot-starter:2.4.4",
            "org.springframework.boot:spring-boot-starter-actuator:2.4.4",
            "org.springframework.boot:spring-boot-starter-freemarker:2.4.4",
            "org.springframework.boot:spring-boot-starter-jdbc:2.4.4",
            "org.springframework.boot:spring-boot-starter-jetty:2.4.4",
            "org.springframework.boot:spring-boot-starter-logging:2.4.4",
            "org.springframework.boot:spring-boot-starter-security:2.4.4",
            "org.springframework.boot:spring-boot-starter-test:2.4.4",
            "org.springframework.boot:spring-boot-starter-web:2.4.4",
            "org.springframework.boot:spring-boot-test:2.4.4",
            "org.springframework.boot:spring-boot-test-autoconfigure:2.4.4",
            "org.springframework.boot:spring-boot-starter-thymeleaf:2.4.4",

            "org.springframework:spring-aop:5.3.5",
            "org.springframework:spring-aspects:5.3.5",
            "org.springframework:spring-beans:5.3.5",
            "org.springframework:spring-context:5.3.5",
            "org.springframework:spring-context-support:5.3.5",
            "org.springframework:spring-core:5.3.5",
            "org.springframework:spring-expression:5.3.5",
            "org.springframework:spring-jdbc:5.3.5",
            "org.springframework:spring-test:5.3.5",
            "org.springframework:spring-tx:5.3.5",
            "org.springframework:spring-web:5.3.5",
            "org.springframework:spring-webmvc:5.3.5",

            "junit:junit:4.13",
            "org.hamcrest:hamcrest-core:1.3",
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

    # this rule exists to test how the springboot rule handles duplicate
    # artifacts: org.springframework.boot:spring-boot-starter-jetty is also
    # brought in by the rule above
    maven_install(
        name = "spring_boot_starter_jetty",
        artifacts = [
            "org.springframework.boot:spring-boot-starter-jetty:2.4.4",
        ],
        repositories = repositories,
        fetch_sources = True,
        version_conflict_policy = "pinned",
        strict_visibility = True,
        generate_compat_repositories = False,
        maven_install_json = "@rules_spring//:spring_boot_starter_jetty_install.json",
        resolve_timeout = 1800,
    )
