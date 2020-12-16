## Excluding and Suppressing Unwanted Classes

Spring Boot jars normally aggregate a great number of dependency jars, many from outside the Bazel
  build (external Maven-built jars).
The Spring Boot rule will copy the transitive closure of all Java jar deps into the Spring Boot executable jar.
This is normally what you want.

But sometimes you have a transitive dependency that causes problems when included in your Spring Boot jar, but
  you don't have the control to remove it from your dependency graph.
This can cause problems such as:
- multiple jars have the same class, but at different versions
- an unwanted class carries a Spring annotation such that the class gets instantiated at startup

The Spring Boot rule has a set of strategies and features for dealing with this situation, which unfortunately
  is somewhat common.


### Duplicate Classes Detection

We have had cases where multiple jars brought in the same class, but at different versions.
These problems are difficult to diagnose.

There is a feature on the *springboot* rule that will fail the build if duplicate classes are detected.
It is disabled by default, but can be enabled with an attribute:

```
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    fail_on_duplicate_classes = True,
)
```

It will scan all inner jars file, and fail the build if:
- the same class (package + classname) is found in more than one inner jar, AND...
- the MD5 hash of the classfile bytes differ

The dupe class checking feature requires Python3.
If you don't have Python3 available for your build, *fail_on_duplicate_classes* must be False.
See [the Captive Python documentation](../python_interpreter) for more information on how to configure Python3.

But sometimes you have transitives that are out of your control that bring in duplicate classes.
To ignore certain jars from the dupe checker, create a text file in the same directory as the BUILD file.
Add a jar filename on each line like this:

```
# write the filename of the jar file that should be excluded from dupe detection
jakarta.annotation-api-1.3.5.jar
spring-jcl-5.2.1.RELEASE.jar
libfoo1.jar
libfoo2.jar
```

and then follow this pattern in the BUILD file:

```
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    fail_on_duplicate_classes = True,
    duplicate_class_allowlist = "my_dupeclass_allowlist.txt",
)
```

:boom: The allowlist feature is meant to be a short term workaround.
It allows the dupe class checker to succeed when there are duplicate classes, but it is masking a real problem.
We recommend that you employ the *Exclude List* or *Classpath Index* features to actually fix the underlying issue.


### Exclude List

An exclude list can be passed to the Spring Boot rule which will prevent that dependency from being copied into the jar.
It is used like this:

```
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    exclude = [
      "@maven//:com_google_protobuf_protobuf_java",
      "//protos/third-party/google/protobuf:any_java_proto",
    ],
)
```

### Classpath Index

Another approach for suppressing unwanted classes is to establish a particular classpath order with a *classpath index*.
The classpath index is a [Spring Boot feature]() (starting with Spring Boot 2.3) that allows you to
  instruct the Spring Boot loader to load one jar before another.
This can be used to load the preferred classes first, which will occlude the unwanted classes loaded later.

The feature is explained in the Spring Boot documentation:
- [Spring Boot Classpath Index](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html#executable-jar-war-index-files-classpath)

The Spring Boot rule exposes the *classpath_index* attribute.
Pass in the name of the file that has the jars listed as per the Spring Boot documentation:

```
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",

    # if you have conflicting classes in dependency jar files, you can define the order in which the jars are loaded-jar-war-index-files-classpath
    classpath_index = "helloworld_classpath.idx",
)
```
