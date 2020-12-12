#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

rm -rf bazel-*

TMPDIR=/tmp/bazel-springboot-rule-release
mkdir $TMPDIR
mv tools/python_interpreter/bin $TMPDIR
mv tools/python_interpreter/captive_python3 $TMPDIR

jar -cvf bazel-springboot-rule-1.0.7.zip *

mv $TMPDIR/bin tools/python_interpreter
mv $TMPDIR/captive_python3 tools/python_interpreter
