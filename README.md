## Salesforce Spring Boot Rule for Bazel

This WORKSPACE contains the Spring Boot rule for the [Bazel](https://bazel.build/) build system.
It enables Bazel to build Spring Boot applications and package them as an executable jar file.

The rule is contained in a directory that is designed to be copied into your WORKSPACE.
It has detailed documentation:
- [bazel-springboot-rule](tools/springboot): a Bazel extension to build Spring Boot applications
