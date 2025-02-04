## SpringBoot Jar CLI

In addition to the Bazel rule, this package also contains a CLI for inspecting Spring Boot jars after they have been built.
This can be useful when troubleshooting behavior differences over time due to changing dependencies.
The CLI works on any executable Spring Boot jar, regardless of whether it was built with Bazel, Maven, or Gradle.


### Running the CLI

If you are importing rules_spring into your Bazel workspace, you can access the tool by a pattern like this:

```
bazel run @rules_spring//springboot:springboot_cli [args]
```

Otherwise, if you have Bazel, you can run it from this repository:

```
bazel run //springboot:springboot_cli [args]
```

For non-Bazel users, a built jar will periodically be added to this directory as _springboot-cli.jar_.

```
jar -jar springboot-cli.jar [args]
```

### Inspector

Inspector is used for any operation involving a single Spring Boot jar.

#### Inspector Index

The _index_ operation iterates through the Spring Boot jar and creates an index of the contained files.
The index is written to file, and the output can be customized to meet the requirements of your analysis work.
This operation can be useful when trying to investigate issues with dependencies in the application.

If you are building your Spring Boot application with Bazel, this operation is similar in some ways to
  what can be obtained from Bazel Query.
Bazel Query will output the set of libraries that are dependencies.
The _index_ is more detailed though in that it can output exact file sizes and is run on the final
  Spring Boot jar.
If you are using *rules_spring* features like *deps_exclude_labels* and *deps_exclude_paths*, the Bazel Query output will be incorrect.

Usage examples:
```
# do the default index operation
bazel run @rules_spring//springboot:springboot_cli inspector index /opt/bazelws/bazel-bin/services/ordering/ordering.jar /tmp/output.txt

# customize the report output; this only writes out the jar files found (L) and will also write the file size of each jar file (Z)
bazel run @rules_spring//springboot:springboot_cli inspector index /opt/bazelws/bazel-bin/services/ordering/ordering.jar /tmp/output.txt --report LZ
```

The customizable report output options are implemented in *SpringBootIndexReporter* which is the best place to look for documentation.
This class is pretty simple, so the code serves as the documentation.
