#!/bin/bash
#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

set -e

mainclass=$1
springbootlauncherclass=$2
manifestfile=$3
javabase=$4
found_spring_jar=0
# Looking for the springboot jar injected by springboot.bzl and extracting the version
for var in "$@"
do
  if [[ $var = *"spring-boot-"* ]] || [[ $var = *"spring_boot_"* ]]; then
    # determine the version of spring boot
    # this little area of the rule has had problems in the past; reconsider whether doing
    # this is worth it; and certainly carefully review prior issues here before making changes
    #   Issues: #130, #119, #111
    $javabase/bin/jar xf $var META-INF/MANIFEST.MF || continue
    spring_version=$(grep 'Implementation-Version' META-INF/MANIFEST.MF | cut -d : -f2 | tr -d '[:space:]')
    rm -rf META-INF

    # we do want to validate that the deps include spring boot, and this is a
    # convenient place to do it, but it is a little misplaced as we are
    # generating the manifest in this script
    found_spring_jar=1
    break
  fi
done

if [[ $found_spring_jar -ne 1 ]]; then
    echo "ERROR: //springboot/write_manifest.sh could not find the spring-boot jar"
    exit 1
fi

#get the java -version details
# todo this isn't the best value to use. it is the version that will be used by the jar tool
# to package the boot jar but not for compiling the code (java_toolchain)
java_string=$($javabase/bin/java -version 2>&1)

#get the first line of the version details and get the version
java_version=$(echo "$java_string" | head -n1 | cut -d ' ' -f 3 | awk '{print substr($0, 2, length($0)-2)}' )

echo "Manifest-Version: 1.0" > $manifestfile
echo "Created-By: Bazel" >> $manifestfile
echo "Built-By: Bazel" >> $manifestfile
echo "Main-Class: $springbootlauncherclass" >> $manifestfile
echo "Spring-Boot-Classes: BOOT-INF/classes/" >> $manifestfile
echo "Spring-Boot-Lib: BOOT-INF/lib/" >> $manifestfile
echo "Spring-Boot-Version: $spring_version" >> $manifestfile
echo "Build-Jdk: $java_version" >> $manifestfile
echo "Start-Class: $mainclass" >> $manifestfile
