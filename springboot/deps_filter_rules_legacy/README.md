## SpringBoot Deps Filters

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