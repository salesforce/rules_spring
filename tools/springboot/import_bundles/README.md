## Import Bundles for Spring Boot Starters

This is a scheme for providing convenience bundles of dependencies for each
  open source Spring Boot starter.

In the early days of Bazel, the way to import a Maven dependency was with *maven_jar*.
With *maven_jar* we needed to explicitly identify all dependencies as it didn't follow transitive relationships.
This import bundles package was created to help curate the repetitive lists of bundles of dependencies across many Spring Boot services.

But now with *maven_install*, transitives are managed so this isn't as useful.
We will maintain the *springboot_required_deps* bundle, but otherwise please stop using these targets.

```starlark
deps = [
  "//tools/springboot/import_bundles:springboot_required_deps",
]
```
