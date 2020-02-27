#
# Copyright (c) 2017-9, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#
workspace(name = "bazel_springboot_rule")

# Nexus/Artifactory
maven_server(
   name = "default",
   url = "https://repo.maven.apache.org/maven2",
)

load("//:external_deps.bzl", "external_maven_jars")
external_maven_jars()