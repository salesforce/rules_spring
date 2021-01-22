#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

RELEASE_VERSION=1.1.1

rm -rf bazel-*

TMPDIR=/tmp/bazel-springboot-rule-release
mkdir $TMPDIR
mv tools/python_interpreter/bin $TMPDIR
mv tools/python_interpreter/captive_python3 $TMPDIR

rm -rf tools/springboot/tests/__pycache__
rm -rf tools/springboot/__pycache__

jar -cvf bazel-springboot-rule-${RELEASE_VERSION}.zip *

mv $TMPDIR/bin tools/python_interpreter
mv $TMPDIR/captive_python3 tools/python_interpreter

echo "RELEASE built: bazel-springboot-rule-${RELEASE_VERSION}.zip"
echo "Remember to update the http_archive stanza in the top level README.md"
