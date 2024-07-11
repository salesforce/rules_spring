## SpringBoot Rule

This implements a Bazel rule for packaging a Spring Boot application as an executable jar file from a Bazel build.
The output of this rule is a jar file that can be copied to production environments and run as an executable jar.

See the [top-level README](../README.md) for the stanza to add to your *WORKSPACE* file to load the rule.
The *springboot* rule runs on any version of Bazel 1.2.1 or higher.

:eyes: are you an existing rules_spring user upgrading to Spring Boot 3?
Do you understand the *javax* -> *jakarta* migration requirements for that upgrade?
We have a short explainer, plus a new diagnostic feature, to help with that.
See our [Javax to Jakarta migration guide](javax.md) for details.

### Use the rule in your BUILD file

This is a *BUILD* file code snippet of how to invoke the rule:

```starlark
# load our Spring Boot rule
load("//springboot:springboot.bzl", "springboot",)

# create our deps list for Spring Boot, we have some convenience targets for this
springboot_deps = [
  "//springboot/import_bundles:springboot_required_deps",
  "@maven//:org_springframework_boot_spring_boot_starter_jetty",
  "@maven//:org_springframework_boot_spring_boot_starter_web",
  "@maven//:org_springframework_spring_webmvc",
]

# this Java library contains your service code
java_library(
    name = 'helloworld_lib',
    srcs = glob(["src/main/java/**/*.java"]),
    resources = glob(["src/main/resources/**"]),
    deps = springboot_deps,
)

# use the springboot rule to build the app as a Spring Boot executable jar
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
)
```

The required *springboot* rule attributes are as follows:

-  name:    name of your application; the convention is to use the same name as the enclosing folder (i.e. the Bazel package name)
-  boot_app_class:  the classname (java package+type) of the @SpringBootApplication class in your app
-  java_library: the library containing your service code
- dep:

There are many more attributes described below and in the [generated Stardoc](springboot_doc.md).

## Build and Run

After installing the rule into your workspace, you are ready to build.
Add the rule invocation to your Spring Boot application *BUILD* file as shown above.
```bash
# Build
bazel build //examples/demoapp
# Run
bazel run //examples/helloworld
# Run with arguments
bazel run //examples/helloworld red green blue
```

In production environments, you will likely not have Bazel installed nor the Bazel workspace files.
This is the primary use case for the executable jar file.
The build will create the executable jar file in the *bazel-bin* directory.
Run the jar file locally using *java* like so:
```bash
java -jar bazel-bin/examples/helloworld/helloworld.jar
```

The executable jar file is ready to be copied to your production environment or  
  embedded into [a Docker image in your build](https://github.com/salesforce/rules_spring/issues/94).


## In Depth

### Rule Attributes Reference

The documentation below explains how to use (or links to subdocuments) all of the features supported by the _springboot_ rule.
For reference, the full list attributes are documented in the [generated _springboot_ Stardoc file.](springboot_doc.md).

### Manage External Dependencies in your WORKSPACE

This repository has an example [WORKSPACE](../../WORKSPACE) file that lists necessary and some optional Spring Boot dependencies.
These will come from a Nexus/Artifactory repository, or Maven Central.
Because the version of each dependency needs to be explicitly managed, it is left for you to review and add to your *WORKSPACE* file.

### Convenience Import Bundles

The [//springboot/import_bundles](import_bundles) package contains a list of core set of Spring Boot dependencies.
We recommend starting with this list, and then creating your own bundles if it helps.

### Detecting, Excluding and Suppressing Unwanted Classes

The Spring Boot rule will copy the transitive closure of all Java jar deps into the Spring Boot executable jar.
This is normally what you want.

But sometimes you have a transitive dependency that causes problems when included in your Spring Boot jar, but
  you don't have the control to remove it from your dependency graph.
This can cause problems such as:
- multiple jars have the same class, but at different versions
- an unwanted class carries a Spring annotation such that the class gets instantiated at startup

The Spring Boot rule has a set of strategies and features for dealing with this situation, which unfortunately
  is somewhat common:
- [Detecting, Excluding and Suppressing Unwanted Classes](unwanted_classes.md) - dupe checking, excludes, classpath order, classpath index

### Build Stamping of the Spring Boot jar

Spring Boot has a nice feature that can display Git coordinates for your built service in the
  [/actuator/info](https://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-features.html#production-ready-endpoints) webadmin endpoint.
If you are interested in this feature, it is supported by this *springboot* rule.
However, to avoid breaking Bazel remote caching, we generally have this feature disabled for most builds.
See the [//tools/buildstamp](../buildstamp) package for more details on how to enable and disable it.


### Customizing Bazel Run

As shown above, the *springboot* rule has support for launching the application using *bazel run*.
There are many ways to customize the way the application is launched.
See the dedicated *bazel run* documentation for details:
- [Customizing Bazel Run](bazelrun.md)

### Other Rule Attributes

The Spring Boot rule supports other attributes for use in the BUILD file:

- *deps*: will add additional jar files into the Spring Boot jar in addition to what is transitively used by the *java_library*
- *deps_exclude*: see the Exclude feature explained [in this document](unwanted_classes.md)
- *deps_use_starlark_order*: see the Classpath Ordering feature explained in [this document](unwanted_classes.md)
- *bazelrun_jvm_flags*: set of JVM flags used when launching the application with *bazel run*
- *bazelrun_data*: behaves like the *data* attribute for *java_binary*


### Debugging the Rule Execution

If the environment variable `debug_springboot_rule` is set, the rule writes debug output to `$TMPDIR/bazel/debug/springboot`.
If `$TMPDIR` is not defined, it defaults to `/tmp`.
In order to pass this environment variable to Bazel, use the `--action_env` argument:

```bash
bazel build //... --action_env=debug_springboot_rule=1
```

### Writing Tests for your Spring Boot Application

This topic is covered in our dedicated [testing guide](testing_springboot.md).

### Customizing the Spring Boot rule

To understand how this rule works, start by reading the [springboot.bzl file](springboot.bzl).

### Springboot CLI

This package also contains a CLI for inspecting Spring Boot jars after they have been built.
This can be useful when troubleshooting behavior differences over time due to changing dependencies.
See [the CLI user guide](cli.md) for details.
