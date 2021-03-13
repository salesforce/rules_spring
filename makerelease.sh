#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

RELEASE_VERSION=2.0.0

rm -rf bazel-*

TMPDIR=/tmp/rules-spring-release
mkdir $TMPDIR
mv tools/python_interpreter/bin $TMPDIR
mv tools/python_interpreter/captive_python3 $TMPDIR

rm -rf springboot/tests/__pycache__
rm -rf springboot/__pycache__

jar -cvf rules-spring-${RELEASE_VERSION}.zip *

mv $TMPDIR/bin tools/python_interpreter
mv $TMPDIR/captive_python3 tools/python_interpreter

echo "RELEASE built: rules-spring-${RELEASE_VERSION}.zip"
echo "Remember to update the http_archive stanza in the top level README.md"
