# Remote attach debugging of the demoapp executable jar

java -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=y -jar ../../bazel-bin/examples/demoapp/demoapp.jar
