## Implementing Tests for SpringBoot Applications in Bazel

The code snippets below assume you have a Spring Boot application with *BUILD* file as:
```starlark
java_library(
    name = "demoapp_lib",
    srcs = glob(["src/main/java/**/*.java"]),
    resources = glob(["src/main/resources/**"]),
    deps = ...redacted...,
)

springbootjar(
    name = "demoapp",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":demoapp_lib",
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
   deps = [ ":demoapp_lib" ] + test_deps,
)
```

### Functional Tests (starts an application context)


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
    deps = [ ":demoapp_lib" ] + test_deps + springboottest_deps,
    resources = glob(["src/test/resources/**"]),
)
```
