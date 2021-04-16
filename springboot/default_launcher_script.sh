#!/bin/bash

set -e

# Launcher Script for launching a SpringBoot application with 'bazel run'

# The following environment variables will be set, and can be used for scripting:
#  LABEL_PATH=examples/helloworld
#  SPRINGBOOTJAR_FILENAME=helloworld.jar
#  JVM_FLAGS="-Dcustomprop=gold  -DcustomProp2=silver"

# soon we will use one of the jdk locations already known to Bazel, see Issue #16
if [ -z ${JAVA_HOME} ]; then
  java_cmd="$(which java)"
else
  java_cmd="${JAVA_HOME}/bin/java"
fi

if [ -z "${java_cmd}" ]; then
  echo "ERROR: no java found, either set JAVA_HOME or add the java executable to your PATH"
  exit 1
fi
echo "Using Java at ${java_cmd}"
${java_cmd} -version
echo ""

# java args
echo "Using JAVA_OPTS from the environment: ${JAVA_OPTS}"
echo "Using jvm_flags from the BUILD file: ${JVM_FLAGS}"

# main args
main_args="$@"

# spring boot jar; these are replaced by the springboot starlark code:
path=${LABEL_PATH}
jar=${SPRINGBOOTJAR_FILENAME}
echo "JAR FILE: ${path}/${jar}"

# assemble the command
# use exec so that we can pass signals to the underlying process (https://github.com/salesforce/rules_spring/issues/91)
cmd="exec ${java_cmd} ${JVM_FLAGS} ${JAVA_OPTS} -jar ${path}/${jar} ${main_args}"

echo "Running ${cmd}"
echo "In directory $(pwd)"
echo ""
echo "You can also run from the root of the repo:"
echo "java -jar bazel-bin/${path}/${jar}"
echo ""

${cmd}
