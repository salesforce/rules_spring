## Customizing Bazel Run

As shown in the [README](README.md), you can launch the Spring Boot application directly from Bazel using the *bazel run* idiom:

```bash
bazel run //examples/helloworld
```

But you may wish to customize the launch.
The *springboot* rule supports several features for customization.
Note that these features do **not** apply when running the application directly using ```java -jar [file]```.

### Launcher JVM

:warning: It is best to use the docs from the Git tag of the release of *rules_spring* you are using.
This section in particular has changed often, so please make sure you are looking at the correct version (tag)
of this doc for your chosen release.

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

Second, you can set the `JAVABIN` environment variable, set with the same convention as `BAZEL_RUN_JAVA`.
`JAVABIN` is also used by [Bazel's java_binary()](https://bazel.build/reference/be/java#java_binary), 
  so may be more convenient to use.

```
# note this is different than setting JAVA_HOME, it needs the path to the actual java executable
export JAVABIN=/opt/my_jdk/bin/java
```

Third, you can use the `bazelrun_java_toolchain` attribute on the `springboot` rule to pass the label 
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

Fourth, the default Java toolchain `@bazel_tools//tools/jdk:current_java_toolchain` will be used.

Summary of the precedence order:
1. environmental variable BAZEL_RUN_JAVA
1. environmental variable JAVABIN 
1. java executable from the custom java toolchain passed into the rule
1. java executable from the default java toolchain (default)
1. environmental variable JAVA_HOME (fallback, we only get here if there is a bug in the above logic)
1. as a last resort, use 'which java'

Additional usages of Bazel Java configuraiton, such as *runtime_java_version*, is perhaps desirable.
But due to variations of implementation across Bazel versions, and other complexities, it has
  not been implemented.
The [Java configured for Bazel Run Issue](https://github.com/salesforce/rules_spring/issues/16) 
  tracks thoughts and experiments with this feature. 

Alternatively, you can provide a custom launcher script (see below) that can tailor JVM selection as needed.
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

### External Configuration with application.properties

Spring Boot will load internal application.properties files, typically put in *src/main/resources* and
add to your *java_library* resources attribute.

But when launching with *bazel run*, you may also provide external application.properties files.
This is done via Bazel's [data dependencies](https://bazel.build/concepts/dependencies#data-dependencies) capability, surfaced in the *springboot* rule via the *bazelrun_data* attribute.

```
filegroup(
    name = "bazelrun_data_files",
    srcs = [
        "application.properties",
        "application-dev.properties",
        "config/application.properties",
    ],
)

springboot(
    ...
    bazelrun_data = [":bazelrun_data_files"],
)
```
The default launcher script will detect filenames with pattern _application*.properties_ as being 
  external configuration files, and configure them as additional configuration files for Spring Boot.

### External Configuration with Environment Variables

Spring Boot will read in [shell environment variables](https://docs.spring.io/spring-boot/reference/features/external-config.html) 
  as external configuration.
This technique can be used to set individual configuration properties.

This is surfaced in the *springboot* rule using the *bazelrun_env_flag_list* attribute, which is set as an array
  of environment variables.

```
springboot(
    ...
    bazelrun_env_flag_list = ["PROP1=blue", "PROP2=green"],
)
```

which could then be used in @Value annotations using lowercased names:

```
    @Value("${prop1:not found}")
    String prop1;
```

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

### Bazel Run Internals

If you need to modify your service launch via *bazel run* using the above options, it is sometimes helpful
  to understand how it all works.
There are three main components to it.

The biggest reveal is that *bazel run* is nothing more than a shell script invocation of a "wrapper script".
The springboot() rule writes that wrapper script, plus two other scripts to support launch.
In fact, you can invoke the wrapper script directly, which is useful when troubleshooting.

```
# Direct invocation
# Format: bazel-bin/relative-path/packagename/targetname
# The last element of the path is a file, named the same as your target name. 
# It is without a .sh suffix, even though it is a shell script file.
./bazel-bin/examples/demoapp/demoapp
```

The best way to learn is to inspect the script files.
The paths below are listed for the //examples/demoapp service.

- **wrapper script** (*bazel-bin/examples/demoapp/demoapp*): is mostly boiler plate; the contents are embedded directly into the [springboot.bzl](springboot.bzl) code - look for the *_bazelrun_script_template* variable. It coordinates the launch of the other two scripts.
- **env script** (*bazel-bin/examples/demoapp/demoapp_bazelrun_env.sh*): is written by the [write_bazelrun_env.sh](write_bazelrun_env.sh) script that is run by the springboot macro. Certain springboot() attributes allow you to add more variables to this file (e.g. *bazelrun_data* and *bazelrun_env_flag_list*).
- **launcher script** (*bazel-bin/examples/demoapp/demoapp.runfiles/_main/springboot/default_bazelrun_script.sh*): actually launches the springboot jar. The default launcher script is [default_bazelrun_script.sh](default_bazelrun_script.sh). This script can be completely replaced by using the *bazelrun_script* attribute to fully customize your service launch. 
