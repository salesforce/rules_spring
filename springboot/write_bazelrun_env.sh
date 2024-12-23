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
start_varargs=6

if [ "$LABEL_PATH" == "root" ]; then
    # token that indicates that the target is in the root path, which for the
    # purposes of the label path, is empty string
    LABEL_PATH=""
fi

# start the output file with the fixed args
echo "export RULE_NAME=$RULE_NAME" > $OUTPUTFILE_PATH
echo "export LABEL_PATH=$LABEL_PATH" >> $OUTPUTFILE_PATH
echo "export SPRINGBOOTJAR_FILENAME=$SPRINGBOOTJAR_FILENAME" >> $OUTPUTFILE_PATH
echo "export DO_BACKGROUND=$DO_BACKGROUND" >> $OUTPUTFILE_PATH

# start processing of dynamic args, which will appear in this order:
# zero or more datafiles, zero or more jvm flags, zero or more env variables
DATAFILES=""
JVM_FLAGS=""
jvm_flags_started=0
envs_started=0
i=$start_varargs
while [ "$i" -le "$#" ]; do
  eval "arg=\${$i}"
  if [ "$arg" = "start_flags" ]; then
    jvm_flags_started=1
  elif [ "$arg" = "start_envs" ]; then
    envs_started=1
    jvm_flags_started=0
  else
    if [ $jvm_flags_started -eq 1 ]; then
      JVM_FLAGS="$JVM_FLAGS $arg"
    elif [ $envs_started -eq 1 ]; then
      echo "export $arg" >> $OUTPUTFILE_PATH
    else
      DATAFILES="${DATAFILES}$arg "
    fi
  fi
  i=$((i + 1))
done

echo "export DATAFILES=\"$DATAFILES\"" >> $OUTPUTFILE_PATH
echo "export JVM_FLAGS=\"$JVM_FLAGS\"" >> $OUTPUTFILE_PATH

if [ -f "$LABEL_PATH/application.properties" ]; then
    echo "export USE_EXTERNAL_CONFIG=true" >> $OUTPUTFILE_PATH
fi


# DEBUG output
#echo "Generating 'bazel run' env."
#echo "SPRINGBOOTJAR_FILENAME=$SPRINGBOOTJAR_FILENAME"
#echo "LABEL_PATH=$LABEL_PATH"
#echo "OUTPUTFILE_PATH=$OUTPUTFILE_PATH"
#echo "DO_BACKGROUND=$DO_BACKGROUND"
#echo "DATAFILES=$DATAFILES"
#echo "JVM_FLAGS=$JVM_FLAGS"
#echo "CURRENT DIR: $(pwd)"
#echo "LABEL_PATH: $LABEL_PATH"
