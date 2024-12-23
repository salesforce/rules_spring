## Implementing Tests for SpringBoot Applications in Bazel

Before reading this document, please read Spring Boot documentation on how to write Spring Boot tests in general.
Documents that explain the *SpringBootTest* annotation is what you should look for.

This document explains how to invoke those tests from your Bazel build.
Be sure to also look at the [example application](../../examples/helloworld) for actual test implementations.

The code snippets below assume you have a Spring Boot application with *BUILD* file as:
```starlark
java_library(
    name = "helloworld_lib",
    srcs = glob(["src/main/java/**/*.java"]),
    resources = glob(["src/main/resources/**"]),
    deps = ...redacted...,
)

springboot(
    name = "helloworld",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",
)
```

### Unit Tests

Your unit tests should operate against the *java_library* target, not the *springboot* target.
Because of this, unit tests are just standard Bazel Java.
Your *BUILD* file will have:

```starlark
test_deps = [
    "@maven//:junit_junit",
    "@maven//:org_hamcrest_hamcrest_core",
]

java_test(
   name = "SampleRestUnitTest",
   srcs = ["src/test/java/com/sample/SampleRestUnitTest.java"],
   deps = [ ":helloworld_lib" ] + test_deps,
)
```

### Functional Tests (starts an application context)

Functional tests need to invoke the Spring Boot machinery to start up the application with the Spring application context.
Functional tests should target the *java_library*, not the output of the *springboot* rule.
This may be unexpected as you may worry that your tests are not testing the artifact that will be promoted to production.
See the next *Integration Tests* section for another option.

Your functional test will have the standard Spring Boot annotations:

```java
@RunWith(SpringRunner.class)
@SpringBootTest(classes = SampleMain.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class SampleRestFuncTest {
   ...
```

with *BUILD* file

```starlark
springboottest_deps = [
    "@maven//:org_springframework_spring_beans",
    "@maven//:org_springframework_boot_spring_boot_test",
    "@maven//:org_springframework_spring_test",
]

java_test(
    name = "SampleRestFuncTest",
    srcs = ["src/test/java/com/sample/SampleRestFuncTest.java"],
    deps = [ ":helloworld_lib" ] + test_deps + springboottest_deps,
    resources = glob(["src/test/resources/**"]),
)
```

### Spring Boot Jar Tests and Integration Tests

Within Salesforce, almost all testing is done as Unit and Functional tests against the *java_library* jar.
But we also like to run a small number of final checks against the *springboot* deployable jar.
These tests, and all integration tests, are done within a Docker container.

We rely on external Bazel tools for this, and we don't offer anything of interest beyond what those tools provide.
We refer you to that documentation.

- [rules_oci](https://github.com/bazel-contrib/rules_oci)
- [testcontainers](https://www.testcontainers.org/)

### Code Coverage

Since Unit and Functional tests are run against the *java_library*, and not the *springboot* rule, code coverage is done with
  standard Bazel Java techniques.
We do provide a convenience script to show how to run *lcov* to generate the html report.
But none of this is specific to *springboot*.

```bash
bazel coverage //examples/helloworld/...
./tools/codecoverage/coverage-report.sh
```
