#!/bin/bash
#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

set -e

mainclass=$1
manifestfile=$2
javabase=$3
found_spring_jar=0
# Looking for the springboot jar injected by springboot.bzl and extracting the version
for var in "$@"
do
  if [[ $var = *"spring-boot-"* ]] || [[ $var = *"spring_boot_"* ]]; then
    $javabase/bin/jar xf $var META-INF/MANIFEST.MF
    spring_version=$(grep 'Implementation-Version' META-INF/MANIFEST.MF | cut -d : -f2 | tr -d '[:space:]')
    rm -rf META-INF
    found_spring_jar=1
    break
  fi
done

if [[ $found_spring_jar -ne 1 ]]; then
    echo "ERROR: //springboot/write_manifest.sh could not find spring-boot jar"
    exit 1
fi

#get the java -version details
# todo this isn't the best value to use. it is the version that will be used by the jar tool
# to package the boot jar but not for compiling the code (java_toolchain)
java_string=$($javabase/bin/java -version 2>&1)

#get the first line of the version details and get the version
java_version=$(echo "$java_string" | head -n1 | cut -d ' ' -f 3 | rev | cut -c2- | rev | cut -c2- )

echo "Manifest-Version: 1.0" > $manifestfile
echo "Created-By: Bazel" >> $manifestfile
echo "Built-By: Bazel" >> $manifestfile
echo "Main-Class: org.springframework.boot.loader.JarLauncher" >> $manifestfile
echo "Spring-Boot-Classes: BOOT-INF/classes/" >> $manifestfile
echo "Spring-Boot-Lib: BOOT-INF/lib/" >> $manifestfile
echo "Spring-Boot-Version: $spring_version" >> $manifestfile
echo "Build-Jdk: $java_version" >> $manifestfile
echo "Start-Class: $mainclass" >> $manifestfile
