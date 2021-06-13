## KotlinApp Example

This is a very simple Spring Boot application written in Kotlin.
It is not intended to show how to write Spring Boot applications in Kotlin.
There is [Spring documentation](https://spring.io/guides/tutorials/spring-boot-kotlin/) that
  already does that.

This example is instead here to show how to build and run such an app in Bazel using *rules_spring*.

```
bazel build //...
bazel run //examples/kotlinapp
```

Once it is running, the following endpoints are available:

```
# SampleController
http://localhost:8080/

# SpringBoot Actuator
http://localhost:8080/actuator/configprops
```
