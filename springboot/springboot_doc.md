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


### Attrbute Reference

<pre>
springboot(<a href="#springboot-name">name</a>, <a href="#springboot-java_library">java_library</a>, <a href="#springboot-boot_app_class">boot_app_class</a>, <a href="#springboot-deps">deps</a>, <a href="#springboot-deps_exclude">deps_exclude</a>, <a href="#springboot-deps_exclude_paths">deps_exclude_paths</a>,
           <a href="#springboot-deps_index_file">deps_index_file</a>, <a href="#springboot-deps_use_starlark_order">deps_use_starlark_order</a>, <a href="#springboot-dupeclassescheck_enable">dupeclassescheck_enable</a>,
           <a href="#springboot-dupeclassescheck_ignorelist">dupeclassescheck_ignorelist</a>, <a href="#springboot-include_git_properties_file">include_git_properties_file</a>, <a href="#springboot-bazelrun_script">bazelrun_script</a>,
           <a href="#springboot-bazelrun_jvm_flags">bazelrun_jvm_flags</a>, <a href="#springboot-bazelrun_data">bazelrun_data</a>, <a href="#springboot-bazelrun_background">bazelrun_background</a>, <a href="#springboot-addins">addins</a>, <a href="#springboot-tags">tags</a>, <a href="#springboot-testonly">testonly</a>, <a href="#springboot-visibility">visibility</a>,
           <a href="#springboot-exclude">exclude</a>, <a href="#springboot-classpath_index">classpath_index</a>, <a href="#springboot-use_build_dependency_order">use_build_dependency_order</a>, <a href="#springboot-fail_on_duplicate_classes">fail_on_duplicate_classes</a>,
           <a href="#springboot-duplicate_class_allowlist">duplicate_class_allowlist</a>, <a href="#springboot-jvm_flags">jvm_flags</a>, <a href="#springboot-data">data</a>)
</pre>

Bazel rule for packaging an executable Spring Boot application.

Note that the rule README has more detailed usage instructions for each attribute.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  **Required**. The name of the Spring Boot application. Typically this is set the same as the package name.   Ex: *helloworld*.   |  none |
| java_library |  **Required**. The built jar, identified by the name of the java_library rule, that contains the   Spring Boot application.   |  none |
| boot_app_class |  **Required**. The fully qualified name of the class annotated with @SpringBootApplication.   Ex: *com.sample.SampleMain*   |  none |
| boot_launcher_class |  **Optional**. Allows you to switch to the new *org.springframework.boot.loader.launch.JarLauncher* introduced in Boot 3.2.0. Defaults to the old launcher.   |  *org.springframework.boot.loader.JarLauncher* |
| deps |  Optional. An additional set of Java dependencies to add to the executable.   Normally all dependencies are set on the *java_library*.   |  <code>None</code> |
| deps_banned| Optional. A list of strings to match against the jar filenames in the transitive graph of dependencies for this springboot app. If any of these strings is found within any jar name, the rule will fail. This is useful for detecting jars that should never go to production. The list of dependencies is obtained after the deps_exclude processing has run. | <code>[ "junit", "mockito" ]</code> |
| deps_exclude |  Optional. This attribute provides a list of partial paths that will be omitted   from the final packaging step if the string is contained within the dep filename. This is a more raw method   than deps_exclude for eliminating a problematic dependency/file that cannot be eliminated upstream.   Ex: [*jackson-databind-*].   |  <code>None</code> |
| deps_exclude_paths |  <p align="center"> - </p>   |  <code>None</code> |
| deps_index_file |  Optional. Uses Spring Boot's   [classpath index feature](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html#executable-jar-war-index-files-classpath)   to define classpath order. This feature is not commonly used, as the application must be extracted from the jar   file for it to work. Ex: *my_classpath_index.idx*   |  <code>None</code> |
| deps_use_starlark_order |  When running the Spring Boot application from the executable jar file, setting this attribute to   *True* will use the classpath order as expressed by the order of deps in the BUILD file. Otherwise it is random order.   |  <code>None</code> |
| dupeclassescheck_enable |  If *True*, will analyze the list of dependencies looking for any class that appears more than   once, but with a different hash. This indicates that your dependency tree has conflicting libraries.   |  <code>None</code> |
| dupeclassescheck_ignorelist |  Optional. When using the duplicate class check, this attribute provides a file   that contains a list of libraries excluded from the analysis. Ex: *dupeclass_libs.txt*   |  <code>None</code> |
| include_git_properties_file |  If *True*, will include a git.properties file in the resulting jar.   |  <code>True</code> |
| bazelrun_java_toolchain |  Optional. When launching the application using 'bazel run', this attribute can identify the label of the Java toolchain used to launch the JVM. Ex: *//tools/jdk:my_default_toolchain*. See *default_java_toolchain* in the Bazel documentation.  |  <code>None</code> |
| bazelrun_script |  Optional. When launching the application using 'bazel run', a default launcher script is used.   This attribute can be used to provide a customized launcher script. Ex: *my_custom_script.sh*   |  <code>None</code> |
| bazelrun_jvm_flags |  Optional. When launching the application using 'bazel run', an optional set of JVM flags   to pass to the JVM at startup. Ex: *-Dcustomprop=gold -DcustomProp2=silver*   |  <code>None</code> |
| bazelrun_data |  Uncommon option to add data files to runfiles. Behaves like the *data* attribute defined for *java_binary*.   |  <code>None</code> |
| bazelrun_background |  Optional. If True, the *bazel run* launcher will not block. The run command will return and process will remain running.   |  <code>False</code> |
| addins |  Uncommon option to add additional files to the root of the springboot jar. For example a license file. Pass an array of files from the package.   |  <code>[]</code> |
| tags |  Optional. Bazel standard attribute.   |  <code>[]</code> |
| testonly |  Optional. Bazel standard attribute. Defaults to False.   |  <code>False</code> |
| visibility |  Optional. Bazel standard attribute.   |  <code>None</code> |
| jartools_toolchains | Optional. Toolchains for running build tools like singlejar, override for obscure use cases. | <code>["@bazel_tools//tools/jdk:current_java_runtime"]</code> |
| exclude |  Deprecated synonym of *deps_exclude*   |  <code>[]</code> |
| classpath_index |  Deprecated synonym of *deps_index_file*   |  <code>"@rules_spring//springboot:empty.txt"</code> |
| use_build_dependency_order |  Deprecated synonym of *deps_use_starlark_order*   |  <code>True</code> |
| fail_on_duplicate_classes |  Deprecated synonym of *dupeclassescheck_enable*   |  <code>False</code> |
| duplicate_class_allowlist |  Deprecated synonym of *dupeclassescheck_ignorelist*   |  <code>None</code> |
| jvm_flags |  Deprecated synonym of *bazelrun_jvm_flags*   |  <code>""</code> |
| data |  Deprecated synonym of *bazelrun_data*   |  <code>[]</code> |
