#!/bin/bash

# This is a handy utility script to explode classes from the generated springboot jar
# into /tmp so you can do searches to find where a certain class is coming from.

# Example:  find out which jars contain the GrpcUtil class

# $ ./jar_explode.sh ../../bazel-bin/examples/helloworld/heloworld.jar
# $ cd /tmp/bazel/springbootexplode
# $ find . -name GrpcUtil.class

SPRINGBOOTJAR=$1
JAR=$(basename $1)

rm -rf /tmp/bazel/springbootexplode
mkdir -p /tmp/bazel/springbootexplode/extract
cp $1 /tmp/bazel/springbootexplode/extract

pushd .
cd /tmp/bazel/springbootexplode
BASEDIR=$(pwd)
cd extract

jar -xvf $JAR
cd BOOT-INF/lib

for f in $(find . -name '*.jar'); do
  jarname="$(basename -- $f)"
  echo "Processing $jarname file..";
  mkdir $BASEDIR/$jarname
  cp $f $BASEDIR/$jarname
  pushd .
  cd $BASEDIR/$jarname
  jar -xvf $jarname
  popd
done

echo "Extracted the springboot classes to $BASEDIR"

popd .