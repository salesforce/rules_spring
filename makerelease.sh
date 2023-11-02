#
# Copyright (c) 2017-2022, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

release_version=2.2.5

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

echo "RELEASE artifact built successfully: rules-spring-${release_version}.zip"
echo ""
echo "Remember to complete these tasks to make the official release:"
echo " 1. Create a new release on GitHub and upload the zip file to it. Look at previous releases and use the same doc conventions. Make sure you tag the release."
echo " 2. Compute the SHA256 for the zip file, for example: shasum -a 256 rules_spring-2.2.5.zip"
echo " 3. Update the http_archive stanza in the top level README.md to refer to the latest release."
echo " 4. Update the version in the MODULE.bazel file"
echo ""
echo "!!! Hey, did you see the task list above, that is work you need to do !!!"
read YESIDID
echo ""
echo "OK, go do those tasks now, please."
echo ""
