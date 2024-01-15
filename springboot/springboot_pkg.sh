#!/bin/bash
#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

# This script outputs a proper Spring Boot executable jar.
# This script is callable from a Bazel build (via a genrule in springboot.bzl).
# It takes a standard Bazel java_binary output executable jar and 'springboot-ifies' it.
# See springboot.bzl to see how it is invoked from the build.
# You should not be trying to invoke this file directly from your BUILD file.

# Debugging? This script outputs a lot of useful debugging information under
# /tmp/bazel/debug/springboot for each Spring Boot app.

# fail on error (https://github.com/salesforce/rules_spring/issues/100)
set -e

ruledir=$(pwd)
singlejar_cmd=$(pwd)/$1
mainclass=$2
spring_boot_launcher_class=${3}
javabase=$4
appjar_name=$5
deps_starlark_order=$6
include_git_properties_file=$7
outputjar=$8
appjar=$9
manifest=${10}
gitpropsfile=${11}
deps_index_file=${12}
first_addin_arg=13

# converting starlark booleans to bash booleans
if [ $deps_starlark_order = "True" ]; then
  deps_starlark_order=true
else
  deps_starlark_order=false
fi

if [ $include_git_properties_file = "True" ]; then
  include_git_properties_file=true
else
  include_git_properties_file=false
fi

# package name (not guaranteed to be globally unique)
packagename=$(basename $appjar_name)

# generate a package working path sha (globally unique). this allows this rule to function correctly
# if sandboxing is disabled. the wrinkle is deriving the right shasum util
shasum_output=$(shasum -h 2>/dev/null) || true
if [[ $shasum_output = *"Usage"* ]]; then
   shasum_install_msg="Hashing command line utility 'shasum' will be used"
   packagesha_raw=$(echo "$outputjar" | shasum )
else
   # linux command is sha1sum, assume that
   packagesha_raw=$(echo "$outputjar" | sha1sum )
   shasum_install_msg="Hashing command line utility 'sha1sum' will be used"
fi
export packagesha=$(echo "$packagesha_raw" | cut -d " " -f 1 )

# Build time telemetry
build_date_time=$(date)
build_time_start=$SECONDS

springboot_rule_tmpdir=${tmpdir:-/tmp}/bazel
mkdir -p $springboot_rule_tmpdir

if [ -z "${debug_springboot_rule}" ]; then
    debugfile=/dev/null
else
    debugdir=$springboot_rule_tmpdir/debug/springboot
    mkdir -p $debugdir
    debugfileName=$packagename-$packagesha
    debugfile=$debugdir/${debugfileName}.log
    echo "SPRING BOOT DEBUG LOG: $debugfile"
fi
>$debugfile

# Write debug header
echo "" >> $debugfile
echo "*************************************************************************************" >> $debugfile
echo "Build time: $build_date_time"  >> $debugfile
echo "SPRING BOOT PACKAGER FOR BAZEL" >> $debugfile
echo "  ruledir         $ruledir     (build working directory)" >> $debugfile
echo "  singlejar       $singlejar_cmd (path to the singlejar utility)" >> $debugfile
echo "  mainclass       $mainclass   (classname of the @SpringBootApplication class for the manifest.MF file entry)" >> $debugfile
echo "  bootloader      $spring_boot_launcher_class   (classname of the Spring Boot Loader to use)" >> $debugfile
echo "  outputjar       $outputjar   (the executable JAR that will be built from this rule)" >> $debugfile
echo "  javabase        $javabase    (the path to the JDK2)" >> $debugfile
echo "  appjar          $appjar      (contains the .class files for the Spring Boot application)" >> $debugfile
echo "  appjar_name     $appjar_name (unused, is the appjar filename without the .jar extension)" >> $debugfile
echo "  manifest        $manifest    (the location of the generated manifest.MF file)" >> $debugfile
echo "  deps_index_file $deps_index_file (the location of the classpath index file - optional)" >> $debugfile
echo "  deplibs         (list of upstream transitive dependencies, these will be incorporated into the jar file in BOOT-INF/lib )" >> $debugfile
echo "  gitpropsfile    $gitpropsfile (the location of the generated git.properties file)" >> $debugfile
echo "*************************************************************************************" >> $debugfile

# compute path to jar utility
pushd . > /dev/null
cd $javabase/bin
jar_command=$(pwd)/jar
popd > /dev/null
echo "Jar command:" >> $debugfile
echo $jar_command >> $debugfile

echo $shasum_install_msg >> $debugfile
echo "Unique identifier for this build: [$packagesha] computed from [$packagesha_raw]" >> $debugfile

# Setup working directories. Working directory is unique to this package path (uses SHA of path)
# to tolerate non-sandboxed builds if so configured.
base_working_dir=$ruledir/$packagesha
working_dir=$base_working_dir/working
echo "DEBUG: packaging working directory $working_dir" >> $debugfile
mkdir -p $working_dir/BOOT-INF/lib
mkdir -p $working_dir/BOOT-INF/classes

# We need a unique scratch work area
TMP_working_dir=$base_working_dir/tmp
mkdir -p $TMP_working_dir

# Addins is the feature to add files to the root of the springboot jar
# The addins are listed in order as args, until the addin_end.txt file marks the end 
i=$first_addin_arg
while [ "$i" -le "$#" ]; do
  eval "addin=\${$i}"
  echo "     ADDINt: $addin" >> $debugfile
  if [[ $addin == *addin_end.txt ]]; then
    i=$((i + 1))
    echo "     ADDIN end found: $addin" >> $debugfile
    break
  fi
  echo "     ADDIN: $addin" >> $debugfile
  cp $addin $working_dir
  i=$((i + 1))
done
first_jar_arg=$i
echo "" >> $debugfile

# log the list of dep jars we were given
i=$first_jar_arg
while [ "$i" -le "$#" ]; do
  eval "lib=\${$i}"
  echo "     DEPLIB:      $lib" >> $debugfile
  i=$((i + 1))
done
echo "" >> $debugfile

# Extract the compiled Boot application classes into BOOT-INF/classes
#    this must include the application's main class (annotated with @SpringBootApplication)
cd $working_dir/BOOT-INF/classes
$jar_command -xf $ruledir/$appjar

# Copy all transitive upstream dependencies into BOOT-INF/lib
#   The dependencies are passed as arguments to the script, starting at index $first_jar_arg
cd $working_dir

# Below we iterate over all deps and build a string that contains all jar paths,
# space separated
boot_inf_lib_jars=""

i=$first_jar_arg
while [ "$i" -le "$#" ]; do
  eval "lib=\${$i}"
  libname=$(basename $lib)
  libdir=$(dirname $lib)
  echo "DEBUG: libname: $libname" >> $debugfile
  if [[ $libname == *jar ]]; then
    # we only want to process .jar files as libs
    if [[ $libname == *spring-boot-loader* ]] || [[ $libname == *spring_boot_loader* ]]; then
      # if libname contains the string 'spring-boot-loader' then...
      # the Spring Boot Loader classes are special, they must be extracted at the root level /,
      #   not in BOOT-INF/lib/loader.jar nor BOOT-INF/classes/**/*.class
      # we only extract org/* since we don't want the toplevel META-INF files
      $jar_command xf $ruledir/$lib org META-INF/services
    else
      # copy the jar into BOOT-INF/lib, being mindful to prevent name collisions by using subdirectories (see Issue #61)
      # the logic to truncate paths below doesnt need to be perfect, it just hopes to simplify the jar paths so they look better for most cases
      # for maven_install deps, the algorithm to correctly identify the end of the server path and the groupId is not defined
      #
      # a note on duplicate artifacts:
      # if the same dep (same gav) is brought in multiple times by different
      # maven_install rules, we do not end up with multiple copies of the same
      # jar. our logic handles this case because of how we truncate the paths
      # below: both (identical) jars will get copied into the same location,
      # the 2nd one overwriting the first one, and therefore we end of with
      # only a single jar in the final assembly, as desired
      # example: 2 maven_install rules bring in spring-boot-starter-jetty:
      # "maven" rule: external/maven/v1/https/repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-jetty/2.4.1/spring-boot-starter-jetty-2.4.1.jar
      # "spring_boot_starter_jetty" rule: external/spring_boot_starter_jetty/v1/https/repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-jetty/2.4.1/spring-boot-starter-jetty-2.4.1.jar
      # the relative destpath we compute below starts after "maven2"
      #
      # related to above, a note on duplicate jar entries:
      # if the jar cmd is called with the same path more than once, for example:
      # jar -cf foo.jar a/b/c.txt d/e/f.txt a/b/c.txt, the first path "wins",
      # subsequent duplicate paths are ignored. so for the example above, the
      # jar will have entries: a/b/c.txt, d/e/f.txt
      # this "first one wins" behavior is also what we want when duplicate
      # dependencies are encountered
      if [[ ${libdir} == *external*maven2* ]]; then
        # this is a maven_install jar probably from maven central
        # libdir:      bazel-out/darwin-fastbuild/bin/external/maven/v1/https/repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-logging/2.2.1.RELEASE/spring-boot-starter-logging-2.2.1.RELEASE.jar
        # libdestdir:  BOOT-INF/lib/org/springframework/boot/spring-boot-starter-logging/2.2.1.RELEASE/spring-boot-starter-logging-2.2.1.RELEASE.jar
        libdestdir="BOOT-INF/lib/${libdir#*maven2}"
      elif [[ ${libdir} == *external*public* ]]; then
        # this is a maven_install jar probably from Sonatype Nexus
        # libdir:      bazel-out/darwin-fastbuild/bin/external/maven/v1/https/ournexus.acme.com/nexus/content/groups/public/org/springframework/boot/spring-boot-starter-logging/2.2.1.RELEASE/spring-boot-starter-logging-2.2.1.RELEASE.jar
        # libdestdir:  BOOT-INF/lib/org/springframework/boot/spring-boot-starter-logging/2.2.1.RELEASE/spring-boot-starter-logging-2.2.1.RELEASE.jar
        libdestdir="BOOT-INF/lib/${libdir#*public}"
      elif [[ ${libdir} == bazel-out* ]]; then
        # this is an internally built jar from the workspace, use the Bazel package name as the path to prevent name collisions
        # libdir:      bazel-out/darwin-fastbuild/bin/projects/libs/acme/blue_lib/liblue_lib.jar
        # libdestdir:  BOOT-INF/lib/projects/libs/acme/blue_lib/liblue_lib.jar
        libdestdir="BOOT-INF/lib/${libdir#*bin}"
      else
        # something else, just copy into BOOT-INF/lib using the full path as it exists
        # this works fine, but you will see some Bazel internal output dirs as part of the path in the jar
        libdestdir="BOOT-INF/lib/${libdir}"
      fi
      mkdir -p ${libdestdir}
      libdestpath=${libdestdir}/$libname
      boot_inf_lib_jars="${boot_inf_lib_jars} ${libdestpath}"
      cp -f $ruledir/$lib $libdestpath
    fi
  fi

  i=$((i + 1))
done

elapsed_trans=$(( $SECONDS - build_time_start ))
echo "DEBUG: finished copying transitives into BOOT-INF/lib, elapsed time (seconds): $elapsed_trans" >> $debugfile

# Inject the Git properties into a properties file in the jar
# (the -f is needed when remote caching is used, as cached files come down as r-x and
#  if you rerun the build it needs to overwrite)
if [[ "$include_git_properties_file" == true ]]; then
  echo "DEBUG: adding git.properties" >> $debugfile
  cat $ruledir/$gitpropsfile >> $debugfile
  cp -f $ruledir/$gitpropsfile $working_dir/BOOT-INF/classes
fi

# Inject the classpath index (unless it is the default empty.txt file). Requires Spring Boot version 2.3+
# https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html#executable-jar-war-index-files-classpath
if [[ ! $deps_index_file = *empty.txt ]]; then
  cp $ruledir/$deps_index_file $working_dir/BOOT-INF/classpath.idx
fi

# Create the output jar
cd $working_dir

# Write debug telemetry data
echo "DEBUG: Creating the JAR file $working_dir" >> $debugfile
echo "DEBUG: jar contents:" >> $debugfile
find . >> $debugfile
elapsed_pre_jar=$(( $SECONDS - build_time_start ))
echo "DEBUG: elapsed time (seconds): $elapsed_pre_jar" >> $debugfile

# First use jar to create a correct jar file for Spring Boot
# Note that a critical part of this step is to pass option 0 into the jar command
# that tells jar not to compress the jar, only package it. Spring Boot does not
# allow the jar file to be compressed (it will fail at startup).
raw_output_jar=$ruledir/${outputjar}.raw
echo "DEBUG: Running jar command to produce $raw_output_jar" >> $debugfile

# The current working directory now has exactly the structure we want to jar up
# HOWEVER, instead of running jar just once, we run jar multiple times to ensure
# that the jar entries are added in the required order to the jar:
# Spring Boot Loader -> BOOT-INF/classes -> BOOT-INF/lib
# A different order can create confusing classpath ordering issues when
# the uber jar is executed using java -jar

# Move BOOT-INF/classes and BOOT-INF/lib out of the way, into this tmp directory
tmp_boot_inf_dir=$TMP_working_dir/boot_inf
# We need this directory to be clean (we'll re-create it below)
rm -rf $tmp_boot_inf_dir

# Move BOOT-INF/classes
tmp_classes_dir=$tmp_boot_inf_dir/classes
mkdir -p "${tmp_classes_dir}/BOOT-INF"
mv BOOT-INF/classes "${tmp_classes_dir}/BOOT-INF"
# Move BOOT-INF/lib
tmp_lib_dir=$tmp_boot_inf_dir/lib
mkdir -p "${tmp_lib_dir}/BOOT-INF"
mv BOOT-INF/lib "${tmp_lib_dir}/BOOT-INF"

# Given the mv cmds above, we now jar everything EXCEPT BOOT-INF/classes and BOOT-INF/lib
$jar_command -cfm0 $raw_output_jar $ruledir/$manifest .  2>&1 | tee -a $debugfile
# Now add BOOT-INF/classes
cd $tmp_classes_dir
$jar_command -uf0 $raw_output_jar .  2>&1 | tee -a $debugfile
cd $working_dir
# Finally add BOOT-INF/lib
cd $tmp_lib_dir
if [ "$deps_starlark_order" == true ]; then
  # if this command fails due to the command line being too long, please see the docs
  # about setting deps_starlark_order=False as a workaround
  $jar_command -uf0 $raw_output_jar $boot_inf_lib_jars  2>&1 | tee -a $debugfile
else
  $jar_command -uf0 $raw_output_jar .  2>&1 | tee -a $debugfile
fi
cd $working_dir


# Use Bazel's singlejar to re-jar it which normalizes timestamps as Jan 1 2010
# note that it does not use the manifest from the jar file, which is a bummer
# so we have to respecify the manifest data
# TODO we should rewrite write_manfiest.sh to produce inputs compatible for singlejar (Issue #27)
singlejar_options="--normalize --dont_change_compression" # add in --verbose for more details from command
singlejar_mainclass="--main_class $spring_boot_launcher_class"
$singlejar_cmd $singlejar_options $singlejar_mainclass \
    --deploy_manifest_lines "Start-Class: $mainclass" \
    --sources $raw_output_jar \
    --output $ruledir/$outputjar 2>&1 | tee -a $debugfile

if [ $? -ne 0 ]; then
  echo "ERROR: Failed creating the JAR file $working_dir." | tee -a $debugfile
fi

cd $ruledir

# Elapsed build time
build_time_end=$SECONDS
build_time_duration=$(( build_time_end - build_time_start ))
echo "DEBUG: SpringBoot packaging subrule elapsed time (seconds) for $packagename: $build_time_duration" >> $debugfile
