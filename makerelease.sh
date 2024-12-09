#
# Copyright (c) 2017-2024, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

release_version=2.4.1

echo "RELEASE: You are about to create a local zip file that contains the release bits."
echo "After it is created, there will be instructions on how to upload it to GitHub and create the release metadata."
echo ""
echo "Please enter the release version (e.g. 2.4.1):"
read release_version
echo ""
echo "You have entered $release_version, are you good with this version? Enter to continue, ctrl-c to abort."
read DOTHETHING

# remove/relocate local build artifacts and tools
rm -rf bazel-*

# move some dev directories out, so they don't get zipped up in the archive
tmpdir=/tmp/rules-spring-release
mkdir $tmpdir 2>/dev/null
mv examples $tmpdir 2>/dev/null

rm -rf coverage-reports
rm -rf springboot/tests/__pycache__
rm -rf springboot/__pycache__
rm *.zip

# jar up the code
release_zip=rules-spring-${release_version}.zip
jar -cvf $release_zip *

# restore the dev directories
mv $tmpdir/examples examples 2>/dev/null

rm -rf $tmpdir

sha256=$(shasum -a 256 $release_zip)

echo ""
echo "RELEASE artifact built successfully: rules-spring-${release_version}.zip"
echo "  SHA256 of the release artifact: $sha256"
echo ""
echo "Remember to complete these tasks to make the official release:"
echo " 1. Create a new release on GitHub and upload the zip file to it. Look at previous releases and use the same doc conventions. Make sure you tag the release."
echo " 2. Update the http_archive stanza in the top level README.md to refer to the latest release."
echo " 3. Update the version identifier in MODULE.bazel"
echo ""
echo "!!! Hey, did you see the task list above, that is work you need to do !!!"
read YESIDID
echo ""
echo "OK, go do those tasks now, please."
echo ""
