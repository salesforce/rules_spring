#!/usr/bin/env bash
#
# Copyright (c) 2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

if [ ! -f "WORKSPACE" ]; then
    echo "ERROR Please run this script from the workspace root."
    exit 1
fi

echo ""
echo "Before running this script, you must run a coverage job in Bazel."
echo "bazel coverage //examples/helloworld/..."

echo ""
echo "Press enter to continue..."
read GOFORIT1

echo "This script requires lcov to be installed (e.g. brew install lcov)"
echo "Your lcov version:"
lcov --version

echo ""
echo "Press enter to continue..."
read GOFORIT2

find bazel-testlogs/ -type f -name "coverage.dat" -not -empty -exec  genhtml -o coverage-reports {} +

echo ""
echo "Report generation complete."
echo "You can view the report by opening ./coverage-reports/index.html in a browser."
