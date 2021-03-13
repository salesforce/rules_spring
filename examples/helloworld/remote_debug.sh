# Remote attach debugging of the helloworld executable jar

java -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=y -jar ../../bazel-bin/examples/helloworld/helloworld.jar
