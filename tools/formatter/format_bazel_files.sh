#
# Copyright (c) 2019-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

echo "This script will format all repo BUILD and .bzl files according to style standards."
echo ""
echo "NOTE: It requires that you have Go installed.  https://golang.org/doc/install"
echo ""

if [ ! -f "WORKSPACE" ]; then
  echo "Please launch this script from the root of the repo."
  echo "  ./tools/formatter/format_bazel_files.sh"
  exit 1
fi

echo "Before running, we will check that you have a clean Git workspace."
echo "Do not mix functional changes together with formatting changes in the same PR."
echo "Press Enter to continue..."
read MR_BOJANGLES

git status

echo ""
echo "Is your Git workspace clean? Press Enter to continue, or ctrl-c to bail."
echo "In the next step, we will make sure you have 'buildifer' installed, which is the tool that does the formatting."
echo "Press Enter to continue..."
read TAMBOURINE_MAN

go get github.com/bazelbuild/buildtools/buildifier

echo ""
echo "If the previous step didn't emit any errors, we are ready to do the formatting."
echo "After the formatting is done, review the diffs and submit a PR."
echo "Press Enter to continue..."
read VANDALS_STOLE_THE_HANDLE

find . -name BUILD | xargs ~/go/bin/buildifier
find . -name BUILD.bazel | xargs ~/go/bin/buildifier

find . -name BUILD | xargs ~/go/bin/buildifier --lint=fix
find . -name BUILD.bazel | xargs ~/go/bin/buildifier --lint=fix

find . -name '*.bzl' | xargs ~/go/bin/buildifier


echo ""
echo "Now we will run the manual linter, which will show what issues remain in the files."
echo "They are informational and can be fixed manually if you wish."
echo "Press Enter to continue..."
read BLOWIN_IN_THE_WIND
find . -name BUILD | xargs ~/go/bin/buildifier --lint=warn
find . -name BUILD.bazel | xargs ~/go/bin/buildifier --lint=warn
find . -name '*.bzl' | xargs ~/go/bin/buildifier --lint=warn
