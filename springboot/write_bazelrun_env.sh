#!/bin/bash
#
# Copyright (c) 2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

# This file is used to generate the environment variables used by the
# default_bazelrun_script.sh for launching Spring Boot applications with
# bazel run, as in 'bazel run //examples/helloworld'

set -e

RULE_NAME=${1}
SPRINGBOOTJAR_FILENAME=${2}
LABEL_PATH=${3}
OUTPUTFILE_PATH=${4}
DO_BACKGROUND=${5}
FIRST_JVMFLAG_ARG=6

#echo "Generating 'bazel run' env to $OUTPUTFILE_PATH"

JVM_FLAGS=""
i=$FIRST_JVMFLAG_ARG
while [ "$i" -le "$#" ]; do
  eval "FLAG=\${$i}"
  JVM_FLAGS="$JVM_FLAGS $FLAG"
  i=$((i + 1))
done

echo "export RULE_NAME=$RULE_NAME" > $OUTPUTFILE_PATH
echo "export LABEL_PATH=$LABEL_PATH" >> $OUTPUTFILE_PATH
echo "export SPRINGBOOTJAR_FILENAME=$SPRINGBOOTJAR_FILENAME" >> $OUTPUTFILE_PATH
echo "export DO_BACKGROUND=$DO_BACKGROUND" >> $OUTPUTFILE_PATH
echo "export JVM_FLAGS=\"$JVM_FLAGS\"" >> $OUTPUTFILE_PATH
