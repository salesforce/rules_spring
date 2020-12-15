#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

# List of standard imports bundles that tend to be used together in Spring Boot.

# HISTORY
# In the early days, with maven_jar, we needed to explicitly identify all dependencies
# so this package was created to help curate the repetitive lists across many Spring Boot services.
# But now with maven_install, transitives are managed so this isn't as useful.

# SUPPORT
# We will maintain the springboot_required_deps bundle, but otherwise please stop
# using these targets.

java_import(
    name = "springboot_required_deps",
    jars = [],
    visibility = ["//visibility:public"],
    exports = [
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

# DEPRECATED

# deprecated
java_import(
    name = "springboot_jetty_starter_deps",
    jars = [],
    visibility = ["//visibility:public"],
    exports = [
        "@maven//:org_springframework_boot_spring_boot_starter_jetty",
    ],
)

# deprecated
java_import(
    name = "springboot_web_starter_deps",
    jars = [],
    visibility = ["//visibility:public"],
    exports = [
        "@maven//:org_springframework_boot_spring_boot_starter_web",
        "@maven//:org_springframework_spring_webmvc",
    ],
)

# deprecated
java_import(
    name = "springboot_logging_deps",
    jars = [],
    visibility = ["//visibility:public"],
    exports = [
    ],
)

# deprecated
java_import(
    name = "springboot_jackson_deps",
    jars = [],
    visibility = ["//visibility:public"],
    exports = [
    ],
)
