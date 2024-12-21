#!/bin/bash

# Copyright (c) 2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

set -e

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

# Picking the Java VM to run is a bit of an ordeal. We now default to using the
#   JVM from @bazel_tools//tools/jdk:current_java_toolchain. But you can override that.
#  1. honor any environmental variable BAZEL_RUN_JAVA (optional)
#  2. use the java executable from the java toolchain passed into the rule (default)
#  3. use non-hermetic JAVA_HOME (fallback, we only get here if there is a bug in the above logic)
#  4. as a last resort, use 'which java'

if [ -f "${BAZEL_RUN_JAVA}" ]; then
  echo "Selected the JVM using the BAZEL_RUN_JAVA environment variable."
  java_cmd=$BAZEL_RUN_JAVA
elif [ -f "$JAVA_TOOLCHAIN" ]; then
  echo "Selected the JVM using the Bazel Java toolchain: $JAVA_TOOLCHAIN_NAME"
  java_cmd=$JAVA_TOOLCHAIN
elif [ -d "${JAVA_HOME}" ]; then
  echo "Selected the JVM using the JAVA_HOME environment variable."
  java_cmd="${JAVA_HOME}/bin/java"
else
  echo "Selected the JVM by executing 'which java'"
  java_cmd="$(which java)"
fi

if [ -z "${java_cmd}" ]; then
  echo "ERROR: no java found. See the Bazel Run docs in rules_spring for details."
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
