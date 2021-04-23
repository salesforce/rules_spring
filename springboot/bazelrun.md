## Customizing Bazel Run

As shown in the [README](README.md), you can launch the Spring Boot application directly from Bazel using the *bazel run* idiom:

```bash
bazel run //examples/helloworld
```

But you may wish to customize the launch.
The *springboot* rule supports several features for customization.

### Java Startup Options

You may wish to customize the launch with JVM options.
There are two mechanisms that are supported for this - *bazelrun_jvm_flags* and *JAVA_OPTS*.
They are injected into the command line launcher like this:

```bash
java [bazelrun_jvm_flags] [JAVA_OPTS] -jar [springboot jar]
```

The *springboot* rule attribute *bazelrun_jvm_flags* is for cases in which you always want the options to apply when the application is launched from Bazel.
It is specified as an attribute on the *springboot* rule invocation:

```starlark
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    bazelrun_jvm_flags = "-Dcustomprop=gold",
)
```

The environment variable *JAVA_OPTS* is useful when a developer wants to make a local override.
It is set in your shell before launching the application:

```bash
export JAVA_OPTS='-Dcustomprop=silver'
bazel run //examples/helloworld
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


### Direct Invocation of the Launcher Script

This is currently broken, see [Issue 110](https://github.com/salesforce/rules_spring/issues/110).


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
