## Springboot() Attributes

This doc explains conventions and reference for the rule attributes.

### Standard Spring Boot Dependencies

The [@rules_spring//springboot/import_bundles](import_bundles) package contains an
    example list of core set of Spring Boot dependencies.
We recommend starting with this list, and then creating your own lists that fit your needs.


### Pattern of Repo-Wide Defaults

Do you want to provide a default value for an attribute, across all _springboot()_ invocations in your repo?
There is a pattern for that.
This is just standard Bazel, nothing specific to *rules_spring*.

First, create a Bazel file somewhere in your repo, with a function like this:
```
def mycompany_springboot(**kwargs):

    # OVERRIDE: The rules_spring default list is [], which is too strict for mycompany,
    #   open up some modules if the caller does not override it.
    if kwargs.get("bazelrun_addopens") == None:
        kwargs["bazelrun_addopens"] = [        
            "java.base/java.base=ALL-UNNAMED",
            "java.base/java.io=ALL-UNNAMED",
            "java.base/java.math=ALL-UNNAMED",
        ]

    # And then delegate to the default impl
    springboot(**kwargs)
```

And then use your function in your BUILD file like:
```
load("//tools/mycompany:myutils.bzl", "mycompany_springboot",

mycompany_springboot(
    name = "myapp",
    java_library = ":base_lib",
    boot_app_class = "com.mycompany.MyApp",
)
```


### Attribute Reference

| Name  | Description | Default Value | Doc Link |
| :-------------: | :-------------: | :-------------: | :-------------: |
| name |  **Required**. The name of the Spring Boot application. Typically this is set the same as the package name.   Ex: *helloworld*.   |  none | |
| java_library |  **Required**. The built jar, identified by the name of the java_library rule, that contains the   Spring Boot application.   |  none | |
| boot_app_class |  **Required**. The fully qualified name of the class annotated with @SpringBootApplication.   Ex: *com.sample.SampleMain*   |  none | |
| boot_launcher_class |  Optional. Allows you to switch to the new *org.springframework.boot.loader.launch.JarLauncher* introduced in Boot 3.2.0. Defaults to the old launcher.   |  *org.springframework.boot.loader.JarLauncher* | [details](../README.md#upgrading-to-spring-boot-3) |
| include_git_properties_file |  If *True*, will include a git.properties file with build details in the resulting jar.   |  <code>True</code> | [details](README.md#build-stamping-of-the-spring-boot-jar) |
| addins |  Uncommon option to add additional files to the root of the springboot jar. For example, a license file. Pass an array of files from the package.   |  <code>[]</code> | |
| jartools_toolchains | Optional. Toolchain for running build tools like singlejar | <code>["@bazel_tools//tools/jdk:current_host_java_runtime"]</code> | see [Issue 250](https://github.com/salesforce/rules_spring/issues/250) |
| **Dependencies** | | | |
| deps |  Optional. An additional set of Java dependencies to add to the executable. Normally all dependencies are set on the *java_library*.   |  <code>None</code> | |
| deps_exclude_labels | Optional. A list of jar labels that will be omitted from the final packaging step. This is a manual option for eliminating a problematic dependency that cannot be eliminated upstream. Ex: *["@maven//:commons_cli_commons_cli"]*. |  <code>None</code> | [details](unwanted_classes.md) |
| deps_exclude | Deprecated. Use deps_exclude_labels instead. Functions the same as deps_exclude_labels but retained for backward compatibility. |  <code>None</code> | |  <code>None</code> | |
| deps_exclude_paths |  Optional. This attribute provides a list of partial paths that will be omitted   from the final packaging step if the string is contained within the dep filename. This is a more raw method than deps_exclude_labels for eliminating a problematic dependency/file that cannot be eliminated upstream.   Ex: [*jackson-databind-*].   |  <code>None</code> | [details](unwanted_classes.md) |
| deps_banned| Optional. A list of strings to match against the jar filenames in the transitive graph of dependencies for this springboot app. If any of these strings is found within any jar name, the rule will fail. This is useful for detecting jars that should never go to production. The list of dependencies is obtained after the deps_exclude_labels and deps_exclude_paths processing has run. | <code>[ "junit", "mockito" ]</code> | [details](unwanted_classes.md) |
| dupeclassescheck_enable |  If *True*, will analyze the list of dependencies looking for any class that appears more than   once, but with a different hash. This indicates that your dependency tree has conflicting libraries.   |  <code>False</code> | [details](unwanted_classes.md) |
| dupeclassescheck_ignorelist |  Optional. When using the duplicate class check, this attribute provides a file   that contains a list of libraries excluded from the analysis. Ex: *dupeclass_libs.txt*   |  <code>None</code> | [details](unwanted_classes.md) |
| deps_index_file |  Optional. Uses Spring Boot's index to define classpath order. This feature is not commonly used, as the application must be extracted from the jar   file for it to work. Ex: *my_classpath_index.idx*   |  <code>None</code> | [classpath index feature](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html#executable-jar-war-index-files-classpath) |
| deps_use_starlark_order |  When running the Spring Boot application from the executable jar file, setting this attribute to   *True* will use the classpath order as expressed by the order of deps in the BUILD file. Otherwise it is random order.   |  <code>True</code> | |
| **Bazel Run** | | | |
| bazelrun_java_toolchain |  Optional. When launching the application using 'bazel run', this attribute can identify the label of the Java toolchain used to launch the JVM. Ex: *//tools/jdk:my_default_toolchain*. See *default_java_toolchain* in the Bazel documentation.  |  <code>None</code> | [details](bazelrun.md) |
| bazelrun_script |  Optional. When launching the application using 'bazel run', a default launcher script is used.   This attribute can be used to provide a customized launcher script. Ex: *my_custom_script.sh*   |  <code>None</code> | [details](bazelrun.md) |
| bazelrun_jvm_flag_list |  Optional. An optional set of JVM flags to pass to the JVM at startup. Ex: *["-Dcustomprop=gold", "-DcustomProp2=silver*"]   |  <code>None</code> | [details](bazelrun.md) |
| bazelrun_env_flag_list | Optional. An optional set of OS environment variables to set before startup. Ex: *["PROP1", "PROP2=copper"] |  <code>None</code> | [details](bazelrun.md) |
| bazelrun_data |  Optional. Adds data files to target's runfiles. Behaves like the *data* attribute defined for *java_binary*. See *bazel run* docs for special behavior when application.properties files are listed here. |  <code>None</code> | [details](bazelrun.md) |
| bazelrun_background |  Optional. If True, the *bazel run* launcher will not block. The run command will return and process will remain running.   |  <code>False</code> | [details](bazelrun.md) |
| **Standard Attributes** | | | |
| tags |  Optional. Bazel standard attribute.   |  <code>[]</code> | |
| testonly |  Optional. Bazel standard attribute. Defaults to False.   |  <code>False</code> | |
| visibility |  Optional. Bazel standard attribute.   |  <code>None</code> | |
| **Javax -> Jakarta** | | | |
| javaxdetect_enable | If *True*, will analyze the list of dependencies looking for any class from javax.* package and fail the build if found. The lib is a candidate for migration to jakarta. | <code>False</code> | [details](javax.md) |
| javaxdetect_ignorelist | Optional. When using the javax detect check, this attribute provides a file that contains a list of libraries excluded from the analysis. Ex: *javaxdetect_ignorelist.txt* | <code>None</code> | [details](javax.md) |


The following attributes are deprecated and will be removed in a future release.
| Name  | Description |
| :-------------: | :-------------: | 
| exclude |  Deprecated synonym of *deps_exclude_labels* and *deps_exclude* |
| classpath_index |  Deprecated synonym of *deps_index_file* |
| use_build_dependency_order |  Deprecated synonym of *deps_use_starlark_order* |
| fail_on_duplicate_classes |  Deprecated synonym of *dupeclassescheck_enable* |
| duplicate_class_allowlist |  Deprecated synonym of *dupeclassescheck_ignorelist* |
| jvm_flags |  Deprecated form of *bazelrun_jvm_flag_list* |
| bazelrun_jvm_flags |  Deprecated form of *bazelrun_jvm_flag_list* |
| data |  Deprecated synonym of *bazelrun_data* |
