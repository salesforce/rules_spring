#!/bin/bash

# Copyright (c) 2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

set -e

# Custom Launcher Script for launching a SpringBoot application with 'bazel run'
# this is wired up in the springboot rule (the launcher_script attribute)

echo "USING A CUSTOM LAUNCHER SCRIPT AS A DEMO (see custom_launcher_script.sh)"

# Launcher Script for launching a SpringBoot application with 'bazel run'

# The following environment variables will be set by the springboot rule, and can
# be reliably used for scripting:
#  RULE_NAME=helloworld
#  LABEL_PATH=examples/helloworld/
#  SPRINGBOOTJAR_FILENAME=helloworld.jar
#  JVM_FLAGS="-Dcustomprop=gold  -DcustomProp2=silver"
#  DO_BACKGROUND=true/false   (if true, the caller is expecting the launcher not to block and return immediately)
#
# There are several other env variables set by Bazel. These should be stable between
# versions of Bazel because they are documented:
#  https://docs.bazel.build/versions/master/user-manual.html#run

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
echo "Using bazelrun_jvm_flags from the BUILD file: ${JVM_FLAGS}"

# main args
main_args="$@"

# spring boot jar; these are replaced by the springboot starlark code:
path=${LABEL_PATH}
jar=${SPRINGBOOTJAR_FILENAME}

# assemble the command
# use exec so that we can pass signals to the underlying process (https://github.com/salesforce/rules_spring/issues/91)
cmd="exec ${java_cmd} ${JVM_FLAGS} ${JAVA_OPTS} -jar ${path}${jar} ${main_args}"

echo "Running ${cmd}"
echo "In directory $(pwd)"
echo ""
echo "You can also run from the root of the repo:"
echo "java -jar bazel-bin/${path}${jar}"
echo ""

# DO_BACKGROUND is set to true if the bazelrun_background attribute on the springboot rule is set to True
# BAZELRUN_DO_BACKGROUND=true may be set by the user in the shell env prior to running bazel run
# If either is true, we will run the application in the background and return immediately
if [ "$DO_BACKGROUND" = true ] || [ "$BAZELRUN_DO_BACKGROUND" = true ]; then
  logfile=/tmp/${RULE_NAME}.log
  pidfile=/tmp/${RULE_NAME}.pid

  ${cmd} > $logfile 2>&1 &
  pid=$!
  echo $pid > $pidfile

  echo "Launched the Spring Boot application in the background..."
  echo "  BUILD rule 'bazelrun_background' attribute = [$DO_BACKGROUND]  Environment variable BAZELRUN_DO_BACKGROUND = [$BAZELRUN_DO_BACKGROUND]"
  echo "  Console log is being written to $logfile"
  echo "  Application process id [$pid] has been written to $pidfile"
  echo ""
else
  echo "Launching the Spring Boot application in the foreground..."
  echo ""
  ${cmd}
fi
