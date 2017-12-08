## SpringBoot Rule

This implements a Bazel rule for packaging a Spring Boot application.

## How to Use:

This is a *BUILD* file code snippet of how to invoke the rule:

```
# Load our Spring Boot Rule
load("//tools/springboot:springboot.bzl",
        "springboot",
        "add_boot_jetty_starter",
        "add_boot_web_starter"
)

#
# Internal Application Dependencies (Bazel targets)
# For this example, assume that //samples/lib/some-internal-lib is a dependency. This is a
# library that is built in this Bazel workspace. Add it to the app_deps list as shown below.
# It might have a transitive dependency (e.g. //samples/lib/some-transitive-lib) but no worries,
# that will be brought into the deployable jar for you without having to list it explicitly.

# External Application Dependencies (aka Maven Jars, aka Nexus, aka Artifactory)
# The solution for external dependencies isn't as nice. You have to list each dep explicitly
# in the app_deps list, and make sure there is a corresponding entry in the WORKSPACE file.
# The springboot rule automatically adds standard Spring Boot compile time dependencies to
# the app_deps list, but the WORKSPACE file is maintained entirely by you. Look at the
# WORKSPACE.sample file provided in this Git repository for guidance.
# Note that transitive dependencies of each external dependency MUST be also explicitly listed
# both here in app_deps and in the WORKSPACE file.

app_deps = [
  "//samples/lib/some-internal-lib",
  "@commons_logging_commons_logging//jar",
]

# Convenience Methods for Adding Entire Starters
add_boot_jetty_starter(app_deps)
add_boot_web_starter(app_deps)

# Build the app
springboot(
    name = "spring-boot-sample-jetty",
    boot_app_class = "sample.jetty.SampleJettyApplication",
    deps = app_deps
)
```

The properties are as follows:

-  name:    name of your application; the convention is to use the same name as the enclosing folder (i.e. the Bazel package name)
-  boot_app_class:  the classname (java package+type) of the @SpringBootApplication class in your app
-  deps:  direct deps within the Bazel workspace, plus the full transitive closure of external dependencies (maven_jars in the *WORKSPACE* file)
-  resources (optional): list of resources to build into the jar; if not specified, default is ```glob(["src/main/resources/**/*"])```

## Upstream External Dependencies

This repository has an example [WORKSPACE.sample](../../WORKSPACE.sample) file that lists necessary and some optional Spring Boot dependencies.
These will come from a Nexus/Artifactory repository, or Maven Central.
Because the version of each dependency needs to be explicitly defined, it is left for you to review and add to your *WORKSPACE* file.
We have an internal tool for helping us build this list, and there is also [the Bazel Migration Tool](https://github.com/bazelbuild/migration-tooling)

## Build and Run

After installing the rule into your workspace at *tools/springboot*, you are ready to build.
Add the rule invocation to your Spring Boot application *BUILD* file as shown above.
You will then need to follow an iterative process, adding external dependencies to your *BUILD* and *WORKSPACE* files until it builds.
Once again, the open source [migration tool](https://github.com/bazelbuild/migration-tooling) can help you with this.

The build will run and create an executable jar file with suffix *_springboot.jar*.
Find it in the output directories, and then run it:

```
java -jar spring-boot-sample-jetty_springboot.jar
```

You might have to add additional runtime external dependencies to your *BUILD* file until it starts up cleanly.

## Internals

To understand how this rule works, start by reading the [springboot.bzl file](springboot.bzl).
