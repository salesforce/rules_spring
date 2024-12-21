## Customizing Bazel Run

As shown in the [README](README.md), you can launch the Spring Boot application directly from Bazel using the *bazel run* idiom:

```bash
bazel run //examples/helloworld
```

But you may wish to customize the launch.
The *springboot* rule supports several features for customization.
Note that these features do **not** apply when running the application directly using ```java -jar [file]```.

### Launcher JVM

By default, the service will be started using the JVM from the current Java toolchain in your
  Bazel workspace - `@bazel_tools//tools/jdk:current_java_toolchain`
See the [Bazel Java docs](https://bazel.build/docs/bazel-and-java) on how toolchains are defined.
However, there are multiple ways to override this.

First, you can set the `BAZEL_RUN_JAVA` environment variable to the Java executable of your choice.
For example, this works well for local override when you want to quickly test your service on an alternate JVM.
This variable, when set, takes priority over the toolchain configurations.

```
# note this is different than setting JAVA_HOME, it needs the path to the actual java executable
export BAZEL_RUN_JAVA=/opt/my_jdk/bin/java
```

Second, you can use the `bazelrun_java_toolchain` attribute on the `springboot` rule to pass the label 
  of a specific Java toolchain defined in your Bazel workspace.
This is useful when your workspace has multiple Java toolchains, and you want the service to use an
  alternate one when launching with `bazel run`.
When set, the launcher will use the JVM from the toolchain.

```
springboot(
   ...
   bazelrun_java_toolchain = "//tools/jdk:my_other_toolchain",  
)
```

Finally, you can provide a custom launcher script (see below) that can tailor JVM selection as needed.
This is the most flexible option, but it may cause compatibility issues with newer versions of rules_spring.


### Java Startup Options

You may wish to customize the bazel run launcher with JVM options.
There are two mechanisms that are supported for this - *bazelrun_jvm_flags* and *JAVA_OPTS*.

The *springboot* rule attribute *bazelrun_jvm_flags* is for cases in which you always want the options to apply when the application is launched from Bazel.
It is specified as an attribute on the *springboot* rule invocation:

```starlark
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    bazelrun_jvm_flag_list = ["-Dcustomprop=gold", "-Dcustomprop2=silver"],
)
```

The environment variable *JAVA_OPTS* is useful when a developer wants to make a local override.
It is set in your shell before launching the application:

```bash
export JAVA_OPTS='-Dcustomprop3=bronze'
bazel run //examples/helloworld
```

Inside the bazel run launcher, these two options are injected into the command line launcher as if you had invoked the jar like this:

```bash
# internally, this is how bazelrun_jvm_flags and JAVA_OPTS are passed to java
java [bazelrun_jvm_flag_list] [JAVA_OPTS] -jar [springboot jar]
```

### Background the Application on Launch

By default, the *bazel run* command will block on the application.
Control will not return until the Spring Boot application has terminated.

For some use cases, this is not desirable.
You may want the *bazel run* command to return immediately, and leave the Spring Boot application running in the background.
This is common for integration testing, where you want to have a scripted flow such as:
- start the application
- run the integration tests
- stop the application

This is supported.
There are two mechanisms for signaling that the application should be started in the background:
- the *springboot* rule supports the optional *bazelrun_background* attribute, which can be set to *True*
- the user may set the environment variable *BAZELRUN_DO_BACKGROUND=true* in the shell prior to invoking *bazel run*

If either the attribute or environment variable are set to true, the application will be launched in the background and:
- the process id will be persisted to a file (/tmp/${rulename}.pid)
- stdout and stderr will be piped to a file (/tmp/${rulename}.log)

### Application Arguments

You may wish to pass arguments to your Spring Boot application.
These arguments are interpreted by your application as you like (see SampleMain.java for an example).
For most cases, you can just add them after the Bazel target, like this:

```bash
bazel run //examples/helloworld one two three=four
```

which would arrive in your main class as args \[one\] \[two\] \[three=four\].
But if you need to pass an argument that starts with '--' to Spring Boot or your application, you will need to follow this pattern
  (notice the extra -- in the command line):

```bash
bazel run //examples/helloworld -- --spring.config.location=/tmp/myconfig/
```

otherwise Bazel will try to consume the '--' argument for itself.


### Custom Launcher Script

If you need more customization, you may completely replace the *bazel run* launcher script for advanced use cases.
Make a copy of the [default_bazelrun_script.sh](default_bazelrun_script.sh) into your package,
  and make changes as necessary.
Then pass it via the *bazelrun_script* attribute, like this:

```starlark
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    bazelrun_script = "my_custom_bazelrun_script.sh",
)
```
