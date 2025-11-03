## SpringBoot Deps Filters

> **⚠️ Recommendation: Use `@deps_filter_rules/` instead of this legacy rule.** This rule is maintained for backward compatibility only.
>
> The legacy `deps_filter` rule has a drawback: it resolves transitive dependencies in the filtered output, which contrasts the Bazel’s standard model, where transitive dependencies are not automatically available for direct use. If a target uses a transitive dependency at compile time without explicitly declaring it, Bazel will throw an "indirect dependency" error and will recommend that as a direct dependency.
>
> The new `@deps_filter_rules/` filters out unwanted Java dependency JARs (by label or path pattern) while preserving the correct JavaInfo structure for Bazel builds, ensuring proper dependency declarations and avoiding indirect dependency issues.

This directory contains implementations of deps filters.
Deps filters are used to remove unwanted dependencies from the dependency graph of your springboot application.

The topic of unwanted classes and dependencies is explained in detail on this document:
- [Unwanted Classes and Dependencies](../unwanted_classes.md)

### deps_filter

This is the standard filter to use for excluding dependencies.
For each listed dependency, the dependency is excluded. 
Optionally, the transitives of each excluded dependency is also excluded.

See the full docs for more information:
- [deps_filter documentation](deps_filter.md)

### deps_filter_disable_transitives

This filter is similar to *deps_filter*, but does not exclude the listed dependencies.
It excludes the transitives of the listed dependencies.

See the full docs for more information:
- [deps_filter_disable_transitives documentation](deps_filter_disable_transitives.md)