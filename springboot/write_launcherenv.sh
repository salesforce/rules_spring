#!/bin/bash
#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

set -e

SPRINGBOOTJAR_FILENAME=${1}
LABEL_PATH=${2}
OUTPUTFILE_PATH=${3}
FIRST_JVMFLAG_ARG=4

#echo "Generating launcher env to $OUTPUTFILE_PATH"

JVM_FLAGS=""
i=$FIRST_JVMFLAG_ARG
while [ "$i" -le "$#" ]; do
  eval "FLAG=\${$i}"
  JVM_FLAGS="$JVM_FLAGS $FLAG"
  i=$((i + 1))
done

echo "export LABEL_PATH=$LABEL_PATH" > $OUTPUTFILE_PATH
echo "export SPRINGBOOTJAR_FILENAME=$SPRINGBOOTJAR_FILENAME" >> $OUTPUTFILE_PATH
echo "export JVM_FLAGS=\"$JVM_FLAGS\"" >> $OUTPUTFILE_PATH
