## Detecting, Excluding and Suppressing Unwanted Classes

Spring Boot jars normally aggregate a great number of dependency jars, many from outside the Bazel
  build (external Maven-built jars).
The Spring Boot rule will copy the transitive closure of all Java jar deps into the [Spring Boot executable jar](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html).
This is normally what you want.

But sometimes you have a transitive dependency that causes problems when included in your Spring Boot jar, but
  you don't have the control to remove it from your dependency graph.
This can cause problems such as:
- multiple jars have the same class, but at different versions
- an unwanted class carries a Spring annotation such that the class gets instantiated at startup

These problems are difficult to diagnose.
The Spring Boot rule has a set of strategies and features for dealing with this situation, which unfortunately
  is somewhat common.


### Detecting Duplicate Classes

There is a feature on the *springboot* rule that will fail the build if duplicate classes are detected.
It is disabled by default, but can be enabled with an attribute:

```starlark
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    dupeclassescheck_enable = True,
)
```

It will scan all inner jars file, and fail the build if:
- the same class (package + classname) is found in more than one inner jar, AND...
- the MD5 hash of the classfile bytes differ

The dupe class checking feature requires Python3.
If you don't have Python3 available for your build, *dupeclassescheck_enable* must be False.
See [the Captive Python documentation](../python_interpreter) for more information on how to configure Python3.

*Advanced:* In some cases, you will have a classes that are duplicated and would normally fail this check - but you cannot remove them.
There is an [ignorelist](#duplicate-class-detection-ignorelist) feature that will ignore specific jars with duplicated classes.

### Removing Unwanted Classes by Removing a Dependency in the BUILD File

The best way to handle duplicate classes is to remove the dependency that brings in the unwanted class from the *java_library* rule.
This eliminates it from usage for the Spring Boot application.

### Removing Unwanted Classes with an Exclude List

In some cases you do not have the control to remove the dependency from the dependency graph.
An exclude list can be passed to the Spring Boot rule which will prevent that dependency from being copied into the jar.
This is the second best approach for handling unwanted classes.

It is used like this:

```starlark
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    deps_exclude = [
      "@maven//:com_google_protobuf_protobuf_java",
      "//protos/third-party/google/protobuf:any_java_proto",
    ],
)
```

### Suppressing Unwanted Classes with Classpath Ordering

In Java, the JVM will load classes from the classpath.
If multiple versions of the same class are in the classpath, the class version that is loaded first will 'win'.
Therefore, another way to suppress an old version of a class is to make sure the newer version is loaded first.

There are two ways to affect the ordering.

#### Classpath Ordering using the BUILD file

When the Spring Boot jar file is executed using `java -jar`, the runtime classpath order is based on the order of the jar entries written into the jar file.
The earlier entries will be loaded before the later entries.

The Spring Boot rule uses a specific order for writing the dependencies into the jar file:
  - Internal Spring Boot classes
  - Service classes (`srcs` of the `java_library` rule that the `springboot` rule references)
  - Dependencies (`deps` and `runtime_deps` of the `java_library` rule the `springboot` rule references)

The order of the dependencies is based on Bazel's `depset` order, which is strongly influenced by BUILD file order.
The earlier entries in the `deps` list will be loaded before the later entries.
However, note that transitive dependencies are traversed in depth first order.

What this means is you can choose which version of the class 'wins' by putting the dependency jar higher in the `deps` list in the BUILD file.
This order isn't guaranteed by Bazel, but seems to be reliable.

To view the order of dependencies written into the Spring Boot jar, use the command `jar -tvf {springboot jar}`.
The output of that command is faithful to the order of written entries.

#### Example

[lib1](../../examples/helloworld/libs/lib1) and [lib2](../../examples/helloworld/libs/lib2) have a duplicate class: [lib1's IntentionalDupedClass](../../examples/helloworld/libs/lib1/src/main/java/com/bazel/demo/IntentionalDupedClass.java) and [lib2's IntentionalDupedClass](../../examples/helloworld/libs/lib2/src/main/java/com/bazel/demo/IntentionalDupedClass.java).
In the example's [BUILD file](../../examples/helloworld/BUILD), if `lib1` appears before `lib2` in `deps`,
   you will see the following output when running `bazel run sample/helloworld`:
```
SampleMain:  Intentional duped class version: Hello LIB1!
```

In the BUILD file, if you move `lib2` in front of `lib1` and re-run, you will see:
```
SampleMain:  Intentional duped class version: Hello LIB2!
```

##### Disabling BUILD file classpath dependency ordering

The current implementation of this feature uses the `jar` command line utility.
Explicit jar entry ordering is implemented by specifying an explicit file list when running `jar`.  
Very large dependency sets may cause the jar command to exceed the system command line length limit.
This limitation will be addressed when [Issue 3](https://github.com/salesforce/rules_spring/issues/3) is resolved.
Until then, if you run into errors, you can disable this feature by setting the attribute `deps_use_starlark_order` to `False`.


#### Classpath Ordering with a Classpath Index

Another approach for defining a particular classpath order is with a *classpath index*.
The classpath index is a [Spring Boot feature](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html#executable-jar-war-index-files-classpath) (starting with Spring Boot 2.3) that allows you to
  instruct the Spring Boot loader to load one jar before another.
The feature is explained in the Spring Boot documentation:
- [Spring Boot Classpath Index](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html#executable-jar-war-index-files-classpath)

The Spring Boot rule exposes the *deps_index_file* attribute:

```starlark
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",

    # if you have conflicting classes in dependency jar files, you can define the order in which the jars are loaded
    deps_index_file = "helloworld_classpath.idx",
)
```

:fire: However, there is a major caveat with this Spring Boot feature.
It only works if you first explode the executable jar, and then invoke the *JarLauncher*:

```bash
$ jar -xf helloworld.jar
$ java org.springframework.boot.loader.JarLauncher
```

### Advanced Use Cases

#### Duplicate Class Detection Ignorelist

Sometimes you have transitives that are out of your control that bring in duplicate classes.
If you cannot use the *deps_exclude* attribute as shown above, you would normally be blocked from using the duplicate class checker.
It would always fail.

For this reason, the duplicate class detection feature supports an *ignorelist*.
The *ignorelist* instructs the checker to ignore certain jars from the dupe checker process.

To use this feature, create a text file in the same directory as the BUILD file (e.g. *my_ignorelist.txt*).
Add a jar filename on each line like this:

```
# write the filename of the jar files that should be excluded from dupe detection
jakarta.annotation-api-1.3.5.jar
spring-jcl-5.2.1.RELEASE.jar
libfoo1.jar
libfoo2.jar
```

and then follow this pattern in the BUILD file:

```starlark
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    dupeclassescheck_enable = True,
    dupeclassescheck_ignorelist = "my_allowlist.txt",
)
```

Note that you must list **both** jars in which the duplicate class exists in order for the duplicate to be ignored.
