## SpringBoot Rule

This implements a Bazel rule for packaging a Spring Boot application.

## Example:

This is a code snippet of how to invoke the rule:

```
# Load our Spring Boot Rule
load("//tools/springboot:springboot.bzl",
        "springboot",
        "add_boot_jetty_starter",
        "add_boot_web_starter"
)

#
# Internal Dependencies
# For this example, notice that the red-lib is listed as a dependency. This is a library
# that is built in this Bazel workspace. It has a transitive dependency (blue-lib) that
# will be brought into the deployable jar for you, without having to list it explicitly.
#
# External Dependencies
# The springboot rule automatically adds standard Spring Boot compile time dependencies.
# These are declared in the WORKSPACE file as external maven_jar entries. Additional
# external dependencies should be listed as well. Remember that transitive dependencies
# need to be explicitly listed for external dependencies.
app_deps = [
  "@commons_logging_commons_logging//jar",
  "//samples/lib/red-lib",
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
-  deps:  direct deps within the Bazel workspace, plus the full transitive closure of external dependencies (maven_jars in the WORKSPACE file)
-  resources (optional): list of resources to build into the jar; if not specified, default is ```glob(["src/main/java/**/*.java"])```

## Internals

Start by reading the [springboot.bzl file](springboot.bzl).
