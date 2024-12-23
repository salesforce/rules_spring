## SpringBoot Rule

This implements a Bazel rule for packaging a Spring Boot application as an executable jar file from a Bazel build.
The output of this rule is a jar file that can be copied to production environments and run as an executable jar.

See the [top-level README](../README.md) for the stanza to add to your *MODULE.bazel* file to load the rule.
The *springboot* rule runs on modern versions of Bazel.
See the [.bazelversion](../.bazelversion) file to see which one is used for testing.

### Spring Boot 3 Upgrade?

:eyes: are you an existing rules_spring user upgrading to Spring Boot 3?
We [have some docs for that](https://github.com/salesforce/rules_spring/issues/230).

### Use the rule in your BUILD file

This is a *BUILD* file code snippet of how to invoke the rule:

```starlark
# load our Spring Boot rule
load("@rules_spring//springboot:springboot.bzl", "springboot",)

# create our deps list for Spring Boot
springboot_deps = [
  # the import bundle has some common defaults
  "@rules_spring//springboot/import_bundles:springboot_required_deps",
  # and add some others
  "@maven//:org_springframework_boot_spring_boot_starter_jetty",
  "@maven//:org_springframework_boot_spring_boot_starter_web",
  "@maven//:org_springframework_spring_webmvc",
]

# this Java library contains your service code
java_library(
    name = 'helloworld_lib',
    srcs = glob(["src/main/java/**/*.java"]),
    resources = glob(["src/main/resources/**"]),
    deps = springboot_deps + [
        "@maven//:green_lib", # red/green libs are fake, put each dep you need here
        "@maven//:red_lib",
    ],
)

# use the springboot rule to build the app as a Spring Boot executable jar
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
)
```

The required *springboot* rule attributes are as follows:

- *name*: name of your application; the convention is to use the same name as the enclosing folder (i.e. the Bazel package name)
- *boot_app_class*: the classname (java package+type) of the @SpringBootApplication class in your app
- *java_library*: the library containing your service code

There are many more attributes described below and in the [Springboot() Attribute doc](attributes.md).

## Build and Run

After installing the rule into your workspace, you are ready to build.
Add the rule invocation to your Spring Boot application *BUILD* file as shown above.
```bash
# Build
bazel build //examples/helloworld
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

The documentation below explains how to use (or links to subdocuments) all of the features supported by the _springboot_ rule.

### Rule Attributes Reference

For reference, the full list available attributes that support these features are documented 
  on the [attributes reference doc.](attributes.md).

### Manage External Dependencies in your MODULE.bazel

This repository has an example [MODULE.bazel](../../MODULE.bazel) file that lists necessary and some optional Spring Boot dependencies.
These will come from a Nexus/Artifactory repository, or Maven Central.
Because the version of each dependency needs to be explicitly managed, it is left for you to review and add to your *MODULE.bazel* file.

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


### Debugging the Rule Execution

If the environment variable `DEBUG_SPRINGBOOT_RULE` is set, the rule writes debug output to `$TMPDIR/bazel/debug/springboot`.
If `$TMPDIR` is not defined, it defaults to `/tmp`.
In order to pass this environment variable to Bazel, use the `--action_env` argument:

```bash
bazel build //... --action_env=DEBUG_SPRINGBOOT_RULE=1
```

### Writing Tests for your Spring Boot Application

This topic is covered in our dedicated [testing guide](testing_springboot.md).

### Customizing the Spring Boot rule

To understand how this rule works, start by reading the [springboot.bzl file](springboot.bzl).

### Springboot CLI

This package also contains a CLI for inspecting Spring Boot jars after they have been built.
This can be useful when troubleshooting behavior differences over time due to changing dependencies.
See [the CLI user guide](cli.md) for details.
