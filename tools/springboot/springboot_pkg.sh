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

RULEDIR=$(pwd)
SINGLEJAR_CMD=$(pwd)/$1
MAINCLASS=$2
JAVABASE=$3
APPJAR_NAME=$4
USE_BUILD_DEPENDENCY_ORDER=$5
OUTPUTJAR=$6
APPJAR=$7
MANIFEST=$8
#GITPROPSFILE=$9 (these assignments have to wait, see below)
#CLASSPATH_INDEX=$10
#FIRST_JAR_ARG=11

if [ $USE_BUILD_DEPENDENCY_ORDER = "True" ]; then
  USE_BUILD_DEPENDENCY_ORDER=true
else
USE_BUILD_DEPENDENCY_ORDER=false
fi

#The coverage variable is used to make sure that the correct files are picked in case bazel coverage is run with this springboot rule
COVERAGE=1

# When bazel coverage is run on packages the appcompile_rule returns an extra string
# "bazel-out/darwin-fastbuild/bin/projects/services/basic-rest-service/coverage_runtime_classpath/projects/services/basic-rest-service_app/runtime-classpath.txt"
# This is a workaround to ensure that the MANIFEST is picked correctly.
if [[ $MANIFEST = *"MANIFEST.MF" ]]; then
    GITPROPSFILE=$9
    CLASSPATH_INDEX=${10}
    FIRST_JAR_ARG=11
    COVERAGE=0
else
    # move these args down one slot, the code cov introduced something in the manifest slot
    MANIFEST=$9
    GITPROPSFILE=${10}
    CLASSPATH_INDEX=${11}
    FIRST_JAR_ARG=12
fi

# package name (not guaranteed to be globally unique)
PACKAGENAME=$(basename $APPJAR_NAME)

# generate a package working path sha (globally unique). this allows this rule to function correctly
# if sandboxing is disabled. the wrinkle is deriving the right shasum util
shasum_output=$(shasum -h 2>/dev/null) || true
if [[ $shasum_output = *"Usage"* ]]; then
   SHASUM_INSTALL_MSG="Hashing command line utility 'shasum' will be used"
   PACKAGESHA_RAW=$(echo "$OUTPUTJAR" | shasum )
else
   # linux command is sha1sum, assume that
   PACKAGESHA_RAW=$(echo "$OUTPUTJAR" | sha1sum )
   SHASUM_INSTALL_MSG="Hashing command line utility 'sha1sum' will be used"
fi
export PACKAGESHA=$(echo "$PACKAGESHA_RAW" | cut -d " " -f 1 )

# Build time telemetry
BUILD_DATE_TIME=$(date)
BUILD_TIME_START=$SECONDS

SPRINGBOOT_RULE_TMPDIR=${TMPDIR:-/tmp}/bazel
mkdir -p $SPRINGBOOT_RULE_TMPDIR

if [ -z "${DEBUG_SPRINGBOOT_RULE}" ]; then
    DEBUGFILE=/dev/null
else
    DEBUGDIR=$SPRINGBOOT_RULE_TMPDIR/debug/springboot
    mkdir -p $DEBUGDIR
    DEBUGFILENAME=$PACKAGENAME-$PACKAGESHA
    DEBUGFILE=$DEBUGDIR/$DEBUGFILENAME.log
    echo "SPRING BOOT DEBUG LOG: $DEBUGFILE"
fi
>$DEBUGFILE

# Write debug header
echo "" >> $DEBUGFILE
echo "*************************************************************************************" >> $DEBUGFILE
echo "Build time: $BUILD_DATE_TIME"  >> $DEBUGFILE
echo "SPRING BOOT PACKAGER FOR BAZEL" >> $DEBUGFILE
echo "  RULEDIR         $RULEDIR     (build working directory)" >> $DEBUGFILE
echo "  SINGLEJAR       $SINGLEJAR_CMD (path to the singlejar utility)" >> $DEBUGFILE
echo "  MAINCLASS       $MAINCLASS   (classname of the @SpringBootApplication class for the MANIFEST.MF file entry)" >> $DEBUGFILE
echo "  OUTPUTJAR       $OUTPUTJAR   (the executable JAR that will be built from this rule)" >> $DEBUGFILE
echo "  JAVABASE        $JAVABASE    (the path to the JDK2)" >> $DEBUGFILE
echo "  APPJAR          $APPJAR      (contains the .class files for the Spring Boot application)" >> $DEBUGFILE
echo "  APPJAR_NAME     $APPJAR_NAME (unused, is the appjar filename without the .jar extension)" >> $DEBUGFILE
echo "  MANIFEST        $MANIFEST    (the location of the generated MANIFEST.MF file)" >> $DEBUGFILE
echo "  CLASSPATH_INDEX $CLASSPATH_INDEX (the location of the classpath index file - optional)" >> $DEBUGFILE
echo "  DEPLIBS         (list of upstream transitive dependencies, these will be incorporated into the jar file in BOOT-INF/lib )" >> $DEBUGFILE

# compute path to jar utility
pushd . > /dev/null
cd $JAVABASE/bin
JAR_COMMAND=$(pwd)/jar
popd > /dev/null
echo "Jar command:" >> $DEBUGFILE
echo $JAR_COMMAND >> $DEBUGFILE

# log the list of dep jars we were given
i=$FIRST_JAR_ARG
while [ "$i" -le "$#" ]; do
  eval "lib=\${$i}"
  echo "     DEPLIB:      $lib" >> $DEBUGFILE
  i=$((i + 1))
done
echo "" >> $DEBUGFILE

echo $SHASUM_INSTALL_MSG >> $DEBUGFILE
echo "Unique identifier for this build: [$PACKAGESHA] computed from [$PACKAGESHA_RAW]" >> $DEBUGFILE

# Setup working directories. Working directory is unique to this package path (uses SHA of path)
# to tolerate non-sandboxed builds if so configured.
BASE_WORKING_DIR=$RULEDIR/$PACKAGESHA
WORKING_DIR=$BASE_WORKING_DIR/working
echo "DEBUG: packaging working directory $WORKING_DIR" >> $DEBUGFILE
mkdir -p $WORKING_DIR/BOOT-INF/lib
mkdir -p $WORKING_DIR/BOOT-INF/classes

# We need a unique scratch work area
TMP_WORKING_DIR=$BASE_WORKING_DIR/tmp
mkdir -p $TMP_WORKING_DIR

# Extract the compiled Boot application classes into BOOT-INF/classes
#    this must include the application's main class (annotated with @SpringBootApplication)
cd $WORKING_DIR/BOOT-INF/classes
$JAR_COMMAND -xf $RULEDIR/$APPJAR

# Copy all transitive upstream dependencies into BOOT-INF/lib
#   The dependencies are passed as arguments to the script, starting at index $FIRST_JAR_ARG
cd $WORKING_DIR

# Below we iterate over all deps and build a string that contains all jar paths,
# space separated
BOOT_INF_LIB_JARS=""

i=$FIRST_JAR_ARG
while [ "$i" -le "$#" ]; do
  eval "lib=\${$i}"
  libname=$(basename $lib)
  libdir=$(dirname $lib)
  echo "DEBUG: libname: $libname" >> $DEBUGFILE
  if [[ $libname == *jar ]]; then
    # we only want to process .jar files as libs
    if [[ $libname == *spring-boot-loader* ]]; then
      # if libname contains the string 'spring-boot-loader' then...
      # the Spring Boot Loader classes are special, they must be extracted at the root level /,
      #   not in BOOT-INF/lib/loader.jar nor BOOT-INF/classes/**/*.class
      # we only extract org/* since we don't want the toplevel META-INF files
      $JAR_COMMAND xf $RULEDIR/$lib org
    else
      # copy the jar into BOOT-INF/lib, being mindful to prevent name collisions by using subdirectories (see Issue #61)
      # the logic to truncate paths below doesnt need to be perfect, it just hopes to simplify the jar paths so they look better for most cases
      # for maven_install deps, the algorithm to correctly identify the end of the server path and the groupId is not defined
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
      BOOT_INF_LIB_JARS="${BOOT_INF_LIB_JARS} ${libdestpath}"
      cp -f $RULEDIR/$lib $libdestpath
    fi
  fi

  i=$((i + 1))
done

ELAPSED_TRANS=$(( $SECONDS - BUILD_TIME_START ))
echo "DEBUG: finished copying transitives into BOOT-INF/lib, elapsed time (seconds): $ELAPSED_TRANS" >> $DEBUGFILE

# Inject the Git properties into a properties file in the jar
# (the -f is needed when remote caching is used, as cached files come down as r-x and
#  if you rerun the build it needs to overwrite)
echo "DEBUG: adding git.properties" >> $DEBUGFILE
cat $RULEDIR/$GITPROPSFILE >> $DEBUGFILE
cp -f $RULEDIR/$GITPROPSFILE $WORKING_DIR/BOOT-INF/classes

# Inject the classpath index (unless it is the default empty.txt file). Requires Spring Boot version 2.3+
# https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html#executable-jar-war-index-files-classpath
if [[ ! $CLASSPATH_INDEX = *empty.txt ]]; then
  cp $RULEDIR/$CLASSPATH_INDEX $WORKING_DIR/BOOT-INF/classpath.idx
fi

# Create the output jar
cd $WORKING_DIR

# Write debug telemetry data
echo "DEBUG: Creating the JAR file $WORKING_DIR" >> $DEBUGFILE
echo "DEBUG: jar contents:" >> $DEBUGFILE
find . >> $DEBUGFILE
ELAPSED_PRE_JAR=$(( $SECONDS - BUILD_TIME_START ))
echo "DEBUG: elapsed time (seconds): $ELAPSED_PRE_JAR" >> $DEBUGFILE

# First use jar to create a correct jar file for Spring Boot
# Note that a critical part of this step is to pass option 0 into the jar command
# that tells jar not to compress the jar, only package it. Spring Boot does not
# allow the jar file to be compressed (it will fail at startup).
RAW_OUTPUT=$RULEDIR/${OUTPUTJAR}.raw
echo "DEBUG: Running jar command to produce $RAW_OUTPUT" >> $DEBUGFILE

# The current working directory now has exactly the structure we want to jar up
# HOWEVER, instead of running jar just once, we run jar multiple times to ensure
# that the jar entries are added in the required order to the jar:
# Spring Boot Loader -> BOOT-INF/classes -> BOOT-INF/lib
# A different order can create confusing classpath ordering issues when
# the uber jar is executed using java -jar

# Move BOOT-INF/classes and BOOT-INF/lib out of the way, into this tmp directory
TMP_BOOT_INF_DIR=$TMP_WORKING_DIR/boot_inf
# We need this directory to be clean (we'll re-create it below)
rm -rf $TMP_BOOT_INF_DIR

# Move BOOT-INF/classes
TMP_CLASSES_DIR=$TMP_BOOT_INF_DIR/classes
mkdir -p "${TMP_CLASSES_DIR}/BOOT-INF"
mv BOOT-INF/classes "${TMP_CLASSES_DIR}/BOOT-INF"
# Move BOOT-INF/lib
TMP_LIB_DIR=$TMP_BOOT_INF_DIR/lib
mkdir -p "${TMP_LIB_DIR}/BOOT-INF"
mv BOOT-INF/lib "${TMP_LIB_DIR}/BOOT-INF"

# Given the mv cmds above, we now jar everything EXCEPT BOOT-INF/classes and BOOT-INF/lib
$JAR_COMMAND -cfm0 $RAW_OUTPUT $RULEDIR/$MANIFEST .  2>&1 | tee -a $DEBUGFILE
# Now add BOOT-INF/classes
cd $TMP_CLASSES_DIR
$JAR_COMMAND -uf0 $RAW_OUTPUT .  2>&1 | tee -a $DEBUGFILE
cd $WORKING_DIR
# Finally add BOOT-INF/lib
cd $TMP_LIB_DIR
if [ "$USE_BUILD_DEPENDENCY_ORDER" == true ]; then
  # if this command fails due to the command line being too long, please see the docs
  # about setting use_build_dependency_order=False as a workaround
  $JAR_COMMAND -uf0 $RAW_OUTPUT $BOOT_INF_LIB_JARS  2>&1 | tee -a $DEBUGFILE
else
  $JAR_COMMAND -uf0 $RAW_OUTPUT .  2>&1 | tee -a $DEBUGFILE
fi
cd $WORKING_DIR


# Use Bazel's singlejar to re-jar it which normalizes timestamps as Jan 1 2010
# note that it does not use the MANIFEST from the jar file, which is a bummer
# so we have to respecify the manifest data
# TODO we should rewrite write_manfiest.sh to produce inputs compatible for singlejar (Issue #27)
SINGLEJAR_OPTIONS="--normalize --dont_change_compression" # add in --verbose for more details from command
SINGLEJAR_MAINCLASS="--main_class org.springframework.boot.loader.JarLauncher"
$SINGLEJAR_CMD $SINGLEJAR_OPTIONS $SINGLEJAR_MAINCLASS \
    --deploy_manifest_lines "Start-Class: $MAINCLASS" \
    --sources $RAW_OUTPUT \
    --output $RULEDIR/$OUTPUTJAR 2>&1 | tee -a $DEBUGFILE

if [ $? -ne 0 ]; then
  echo "ERROR: Failed creating the JAR file $WORKING_DIR." | tee -a $DEBUGFILE
fi

cd $RULEDIR

# Elapsed build time
BUILD_TIME_END=$SECONDS
BUILD_TIME_DURATION=$(( BUILD_TIME_END - BUILD_TIME_START ))
echo "DEBUG: SpringBoot packaging subrule elapsed time (seconds) for $PACKAGENAME: $BUILD_TIME_DURATION" >> $DEBUGFILE
