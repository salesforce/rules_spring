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

echo "STEP 1: update MODULE.bazel with version $release_version"
echo "You must do this manually, I will wait for you. After it is done, press Enter here."
read DOTHETHING


echo ""
echo "STEP 2: packaging the release zip file."
echo "I can do this all by myself...."
echo ""
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
echo ""
echo "STEP 3: release tasks"
echo " 0. commit and push the MODULE.bazel update you just did"
echo " 1. Create a new release on GitHub and upload the zip file to it. Look at previous releases and use the same doc conventions. Make sure you tag the release."
echo " 2. Update the bzlmod/http_archive stanzas in the top level README.md to refer to the latest release."
echo " 3. Test new release with the external demoapp repository: https://github.com/plaird/rules_spring_demoapp"
echo ""
echo "OK, go do those tasks now, please."
read DID_RELEASE
echo ""

echo ""
echo "STEP 4: BCR update tasks"
echo "OK, now you have to publish the release to the Bazel central registry."
echo "1. Activate your python virtual env (e.g. source ~/dev/bin/activate)"
echo "2. sync your BCR fork: git pull upstream main"
echo "3. run the add module script in your BCR fork: python3 tools/add_module.py"
echo "  Please enter the module name: rules_spring"
echo "  Please enter the module version: 2.6.2"
echo "  Please enter the compatibility level [default is 0]: 2"
echo "  Please enter the URL of the source archive: https://github.com/salesforce/rules_spring/releases/download/2.6.2/rules-spring-2.6.2.zip"
echo "  Please enter the strip_prefix value of the archive [default None]:" 
echo "  Do you want to add patch files? [y/N]: n"
echo "  Do you want to add a BUILD file? [y/N]: n"
echo "  Do you want to specify a MODULE.bazel file? [y/N]: y"
echo "  Please enter the MODULE.bazel file path: ../../rules_spring/MODULE.bazel"
echo "  Do you want to specify an existing presubmit.yml file? y"
echo "  Please enter the presubmit.yml file path: modules/rules_spring/2.6.0/presubmit.yml"
echo "4. git add modules"
echo "5. submit a PR to BCR"
echo ""

