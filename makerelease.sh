#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

release_version=2.1.4

# remove/relocate local build artifacts and tools
rm -rf bazel-*

tmpdir=/tmp/rules-spring-release
mkdir $tmpdir
mv tools/python_interpreter/bin $tmpdir
mv tools/python_interpreter/captive_python3 $tmpdir

rm -rf coverage-reports
rm -rf springboot/tests/__pycache__
rm -rf springboot/__pycache__

# jar up the code
jar -cvf rules-spring-${release_version}.zip *

# restore some of the local build tools
mv $tmpdir/bin tools/python_interpreter
mv $tmpdir/captive_python3 tools/python_interpreter

echo "RELEASE built: rules-spring-${release_version}.zip"
echo "Remember to update the http_archive stanza in the top level README.md"
