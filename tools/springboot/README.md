## SpringBoot Rule

This implements a Bazel rule for packaging a Spring Boot application as an executable jar file.
The output of this rule is a jar file that can be copied to production environments and run.

## How to Use:

### Add the rule to your WORKSPACE

There are two approaches to doing this.
We recommend the first.

**Copy the rule into your workspace**
We recommend this approach because this rule is not currently setup well for the second approach.
On [our roadmap](https://github.com/salesforce/bazel-springboot-rule/projects/2) we have work items to upgrade this rule to use more modern packaging idioms.
Until that is done, copying in the bits you need and customizing it is probably the best way to go.
Make sure to review the [buildstamp](../buildstamp) documentation as well.
We recommend copying it into location *//tools/springboot* but you are free to change this if you like.

Once it is copied in, add this to your WORKSPACE:
```
local_repository(
    name = "bazel_springboot_rule",
    path = "tools/springboot",
)
```

**Reference an official release**
This copies a pre-built version of this rule into your workspace.
It may or may not work for you, as it does not allow you to customize it.

```
http_archive(
    name = "bazel_springboot_rule",
    sha256 = "a193ff7d502d153a1ed74bfe0cf8c1c1abad6dddc8b28cb57afa9d99e287949d",
    urls = [
        "https://github.com/salesforce/bazel-springboot-rule/releases/download/1.0.0/bazel-springboot-rule-1.0.0.zip",
    ],
)
```

### Create your BUILD file

This is a *BUILD* file code snippet of how to invoke the rule:

```
# load our Spring Boot rule
load("//tools/springboot:springboot.bzl", "springboot",)

# create our deps list for Spring Boot, we have some convenience targets for this
springboot_deps = [
  "//tools/springboot/import_bundles:springboot_required_deps",
  "//tools/springboot/import_bundles:springboot_jetty_starter_deps",
  "//tools/springboot/import_bundles:springboot_web_starter_deps",
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

## Build and Run

After installing the rule into your workspace at *tools/springboot*, you are ready to build.
Add the rule invocation to your Spring Boot application *BUILD* file as shown above.
```
# Build
bazel build //samples/helloworld
# Run
bazel run //samples/helloworld
# Run with arguments
bazel run //samples/helloworld red green blue
```

In production environments, you will likely not have Bazel installed nor the Bazel workspace files.
This is the primary use case for the executable jar file.
The build will create the executable jar file in the *bazel-bin* directory.
Run the jar file locally using *java* like so:
```
java -jar bazel-bin/samples/helloworld/helloworld.jar
```

The executable jar file is ready to be copied to your production environment.


## In Depth

### Manage External Dependencies in your WORKSPACE

This repository has an example [WORKSPACE](../../external_deps.bzl) file that lists necessary and some optional Spring Boot dependencies.
These will come from a Nexus/Artifactory repository, or Maven Central.
Because the version of each dependency needs to be explicitly defined, it is left for you to review and add to your *WORKSPACE* file.
You will then need to follow an iterative process, adding external dependencies to your *BUILD* and *WORKSPACE* files until it builds and runs.

### Convenience Import Bundles

The [//tools/springboot/import_bundles](import_bundles) package contains some example bundles of imports.
There are bundles for the Spring Boot framework, as well as bundles for the various starters.
The ones provided in this repository are just examples.


### Build Stamping of the Spring Boot jar

Spring Boot has a nice feature that can display Git coordinates for your built service in the
  [/actuator/info](https://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-features.html#production-ready-endpoints) webadmin endpoint.
If you are interested in this feature, it is supported by this *springboot* rule.
However, to avoid breaking Bazel remote caching, we generally have this feature disabled for most builds.
See the [//tools/buildstamp](../buildstamp) package for more details on how to enable and disable it.

### Exclude list

The Spring Boot rule will copy the transitive closure of all Java jar deps into the Spring Boot executable jar.
This is normally what you want.
But sometimes you have a transitive dependency that causes problems when included in your Spring Boot jar, but
  you don't have the control to remove it from your dependency graph.

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

### Duplicate Classes Detection

Spring Boot jars normally aggregate a great number of dependency jars, many from outside the Bazel
  build (external Maven-built jars).
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

But sometimes you have transitives that are out of your control that bring in duplicate classes.
If you cannot use the *exclude* attribute as shown above, there is another solution.
To ignore certain jars from the dupe checker, create a text file in the same directory
  as the BUILD file.
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
filegroup(
    name = "dupe_class_allowlist",
    srcs = glob([
        "my_dupeclass_allowlist.txt",
    ]),
)

springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    fail_on_duplicate_classes = True,
    duplicate_class_allowlist = ":dupe_class_allowlist",
)
```

The dupe class checking feature requires Python3.
If you don't have Python3 available for your build, *fail_on_duplicate_classes* must be False.
See [the Captive Python documentation](../python_interpreter) for more information on how to configure Python3.

### Customizing Bazel Run

As shown above, you can launch the Spring Boot application directly from Bazel using the *bazel run* idiom:

```
bazel run //samples/helloworld
```

But you may wish to customize the launch with JVM arguments.
There are two mechanisms that are supported for this - *jvm_flags* and *JAVA_OPTS*.
They are injected into the command line launcher like this:

```
java [jvm_flags] [JAVA_OPTS] -jar [springboot jar]
```

The attribute *jvm_flags* is for cases in which you always want the flags to apply when the application is launched from Bazel.
It is specified as an attribute on the springboot rule invocation:

```
springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
    jvm_flags = "-Dcustomprop=gold",
)
```

The environment variable JAVA_OPTS is useful when a developer wants to make a local override.
It is set in your shell before launching the application:

```
export JAVA_OPTS='-Dcustomprop=silver'
bazel run //samples/helloworld
```

### Other Rule Attributes

The Spring Boot rule supports other attributes for use in the BUILD file:

- *visibility*: standard
- *tags*: standard
- *data*: behaves like the same attribute for *java_binary*
- *deps*: will add additional jar files into the Spring Boot jar in addition to what is transitively used by the *java_library*

### Debugging the Rule Execution

If the environment variable `DEBUG_SPRINGBOOT_RULE` is set, the rule writes debug output to `$TMPDIR/bazel/debug/springboot`. If `$TMPDIR` is not defined, it defaults to `/tmp`.

In order to pass this environment variable to Bazel, use the `--action_env` argument:

```
bazel build //... --action_env=DEBUG_SPRINGBOOT_RULE=1
```

### Customizing the Spring Boot rule

To understand how this rule works, start by reading the [springboot.bzl file](springboot.bzl).
