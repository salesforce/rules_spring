## Jar Explode Debug Utility

Spring Boot jars typically contain hundreds of upstream dependency jars.
In cases where you have ClassNotFound errors or class version conflicts, it can be helpful to get a full searchable catalog of which classes are in the jar (or not).

Use this utility to extract the springboot jar, and the nested dependency jars, such that the .class files can be searched for and located.

```
# Example:  find out which jars contain the GrpcUtil class

$ ./jar_explode.sh ../../bazel-bin/examples/helloworld/heloworld.jar
$ cd /tmp/bazel/springbootexplode
$ find . -name GrpcUtil.class
```