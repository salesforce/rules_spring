#!/bin/bash
set -e

# This script is invoked by generate-build-info.bzl, which is in turn invoked by
# the BUILD file. Consult those files for usage info.

# This script implants build data into the Spring Boot app, which is then
# accessible by autowiring the org.springframework.boot.info.BuildProperties bean.
# See SampleAutoConfiguration.java for an example usage of BuildProperties.

buildpropsfile=$1

# These must be set by the bazel command that launches the app.
# bazel run --action_env=BUILD_NUMBER=998 --action_env=BUILD_TAG=green examples/demoapp

echo "build.number=$BUILD_NUMBER" >> $buildpropsfile
echo "build.tag=$BUILD_TAG" >> $buildpropsfile