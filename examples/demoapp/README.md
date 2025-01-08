## Demo App Spring Boot Example


This example shows how to use many of the features of the Spring Boot rule for Bazel.

To build:

```bash
bazel build //examples/demoapp
```

To run:

```bash
bazel run //examples/demoapp

# or to see build data in the endpoint, run like this:
bazel run --action_env=BUILD_NUMBER=998 --action_env=BUILD_TAG=green examples/demoapp
```

Endpoints:
```
http://localhost:8080/
http://localhost:8080/actuator/configprops
http://localhost:8080/actuator/info
```

For full documentation of rules_spring, see the [//springboot](../../springboot) package documentation.
