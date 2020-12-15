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

def external_maven_jars():
    maven_install(
        artifacts = [
            "org.slf4j:jcl-over-slf4j:1.7.26",
            "org.slf4j:jul-to-slf4j:1.7.26",
            "org.slf4j:log4j-over-slf4j:1.7.26",
            "org.slf4j:slf4j-api:1.7.26",
            "org.springframework.boot:spring-boot:2.4.1",
            "org.springframework.boot:spring-boot-actuator:2.4.1",
            "org.springframework.boot:spring-boot-actuator-autoconfigure:2.4.1",
            "org.springframework.boot:spring-boot-autoconfigure:2.4.1",
            "org.springframework.boot:spring-boot-configuration-processor:2.4.1",
            "org.springframework.boot:spring-boot-loader:2.4.1",
            "org.springframework.boot:spring-boot-starter:2.4.1",
            "org.springframework.boot:spring-boot-starter-actuator:2.4.1",
            "org.springframework.boot:spring-boot-starter-freemarker:2.4.1",
            "org.springframework.boot:spring-boot-starter-jdbc:2.4.1",
            "org.springframework.boot:spring-boot-starter-jetty:2.4.1",
            "org.springframework.boot:spring-boot-starter-logging:2.4.1",
            "org.springframework.boot:spring-boot-starter-security:2.4.1",
            "org.springframework.boot:spring-boot-starter-test:2.4.1",
            "org.springframework.boot:spring-boot-starter-web:2.4.1",
            "org.springframework.boot:spring-boot-test:2.4.1",
            "org.springframework.boot:spring-boot-test-autoconfigure:2.4.1",
            "org.springframework.boot:spring-boot-starter-thymeleaf:2.4.1",

            "org.springframework:spring-web:5.3.2",
            "org.springframework:spring-webmvc:5.3.2",

            "com.fasterxml:classmate:1.5.1",
            "commons-logging:commons-logging:1.2",
            "org.jboss.logging:jboss-logging:3.4.1.Final",
        ],
        excluded_artifacts = [
            "org.springframework.boot:spring-boot-starter-tomcat",
        ],
        repositories = repositories,
        fetch_sources = True,
        version_conflict_policy = "pinned",
        strict_visibility = True,
        generate_compat_repositories = False,
        # comment the following line in once maven_install.json generation doesn't include user id
        maven_install_json = "@bazel_springboot_rule//:maven_install.json",
        resolve_timeout = 1800,
    )
