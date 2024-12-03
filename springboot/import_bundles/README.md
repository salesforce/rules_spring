## Import Bundles for Spring Boot Starters

This is a scheme for providing convenience bundles of dependencies for each open source Spring Boot starter.
*springboot_required_deps* is a convenience bundle that contains the core list that all Spring Boot apps need.
We used to maintain others, but have since removed all other bundles.

```starlark
deps = [
  "@rules_spring//springboot/import_bundles:springboot_required_deps",
]
```
