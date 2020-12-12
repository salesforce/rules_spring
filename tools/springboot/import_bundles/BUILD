#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

# List of standard imports bundles that tend to be used together in Spring Boot.
# Please create/curate new bundles and contribute back to the community. Thanks!

java_import(
    name = "springboot_required_deps",
    jars = [],
    visibility = ["//visibility:public"],
    exports = [
        "@maven//:javax_annotation_javax_annotation_api",
        "@maven//:javax_servlet_javax_servlet_api",
        "@maven//:org_springframework_boot_spring_boot",
        "@maven//:org_springframework_boot_spring_boot_actuator",
        "@maven//:org_springframework_boot_spring_boot_actuator_autoconfigure",
        "@maven//:org_springframework_boot_spring_boot_autoconfigure",
        "@maven//:org_springframework_boot_spring_boot_loader",
        "@maven//:org_springframework_boot_spring_boot_starter",
        "@maven//:org_springframework_boot_spring_boot_starter_logging",
        "@maven//:org_springframework_spring_aop",
        "@maven//:org_springframework_spring_beans",
        "@maven//:org_springframework_spring_context",
        "@maven//:org_springframework_spring_core",
        "@maven//:org_springframework_spring_expression",
        "@maven//:org_springframework_spring_web",
    ],
)

java_import(
    name = "springboot_jetty_starter_deps",
    jars = [],
    visibility = ["//visibility:public"],
    exports = [
        "@maven//:org_eclipse_jetty_jetty_http",
        "@maven//:org_eclipse_jetty_jetty_io",
        "@maven//:org_eclipse_jetty_jetty_security",
        "@maven//:org_eclipse_jetty_jetty_server",
        "@maven//:org_eclipse_jetty_jetty_servlet",
        "@maven//:org_eclipse_jetty_jetty_util",
        "@maven//:org_eclipse_jetty_jetty_webapp",
        "@maven//:org_springframework_boot_spring_boot_starter_jetty",
    ],
)

java_import(
    name = "springboot_web_starter_deps",
    jars = [],
    visibility = ["//visibility:public"],
    exports = [
        ":springboot_jackson_deps",
        ":springboot_logging_deps",
        "@maven//:org_eclipse_jetty_jetty_server",
        "@maven//:org_eclipse_jetty_jetty_servlet",
        "@maven//:org_eclipse_jetty_jetty_util",
        "@maven//:org_eclipse_jetty_jetty_webapp",
        "@maven//:org_springframework_boot_spring_boot_starter_web",
        "@maven//:org_springframework_spring_web",
        "@maven//:org_springframework_spring_webmvc",
    ],
)

java_import(
    name = "springboot_logging_deps",
    jars = [],
    visibility = ["//visibility:public"],
    exports = [
        "@maven//:ch_qos_logback_logback_classic",
        "@maven//:ch_qos_logback_logback_core",
        "@maven//:com_fasterxml_classmate",
        "@maven//:commons_logging_commons_logging",
        "@maven//:org_apache_logging_log4j_log4j_api",
        "@maven//:org_apache_logging_log4j_log4j_to_slf4j",
        "@maven//:org_jboss_logging_jboss_logging",
        "@maven//:org_slf4j_jul_to_slf4j",
        "@maven//:org_slf4j_slf4j_api",
    ],
)

java_import(
    name = "springboot_jackson_deps",
    jars = [],
    visibility = ["//visibility:public"],
    exports = [
        "@maven//:com_fasterxml_jackson_core_jackson_annotations",
        "@maven//:com_fasterxml_jackson_core_jackson_core",
        "@maven//:com_fasterxml_jackson_core_jackson_databind",
        "@maven//:com_fasterxml_jackson_datatype_jackson_datatype_jdk8",
        "@maven//:com_fasterxml_jackson_datatype_jackson_datatype_jsr310",
        "@maven//:com_fasterxml_jackson_module_jackson_module_parameter_names",
    ],
)
