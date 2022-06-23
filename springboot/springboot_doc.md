<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#springboot"></a>

## springboot

<pre>
springboot(<a href="#springboot-name">name</a>, <a href="#springboot-java_library">java_library</a>, <a href="#springboot-boot_app_class">boot_app_class</a>, <a href="#springboot-deps">deps</a>, <a href="#springboot-deps_exclude">deps_exclude</a>, <a href="#springboot-deps_index_file">deps_index_file</a>,
           <a href="#springboot-deps_use_starlark_order">deps_use_starlark_order</a>, <a href="#springboot-dupeclassescheck_enable">dupeclassescheck_enable</a>, <a href="#springboot-dupeclassescheck_ignorelist">dupeclassescheck_ignorelist</a>,
           <a href="#springboot-bazelrun_script">bazelrun_script</a>, <a href="#springboot-bazelrun_jvm_flags">bazelrun_jvm_flags</a>, <a href="#springboot-bazelrun_data">bazelrun_data</a>, <a href="#springboot-bazelrun_background">bazelrun_background</a>, <a href="#springboot-tags">tags</a>, <a href="#springboot-testonly">testonly</a>, <a href="#springboot-visibility">visibility</a>,
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
| deps |  Optional. An additional set of Java dependencies to add to the executable.   Normally all dependencies are set on the *java_library*.   |  <code>None</code> |
| deps_exclude |  Optional. A list of jar labels that will be omitted from the final packaging step. This is a manual option for eliminating a problematic dependency that cannot be eliminated upstream.   Ex: *["@maven//:commons_cli_commons_cli"]*.   |  <code>None</code> |
| deps_exclude_paths |  Optional. This attribute provides a list of partial paths that will be omitted from the final packaging step if the string is contained within the dep filename. This is a more raw method than deps_exclude for eliminating a problematic dependency/file that cannot be eliminated upstream. Ex: [*jackson-databind-*].   |  <code>None</code> |
| deps_index_file |  Optional. Uses Spring Boot's   [classpath index feature](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html#executable-jar-war-index-files-classpath)   to define classpath order. This feature is not commonly used, as the application must be extracted from the jar   file for it to work. Ex: *my_classpath_index.idx*   |  <code>None</code> |
| deps_use_starlark_order |  When running the Spring Boot application from the executable jar file, setting this attribute to   *True* will use the classpath order as expressed by the order of deps in the BUILD file. Otherwise it is random order.   |  <code>True</code> |
| dupeclassescheck_enable |  If *True*, will analyze the list of dependencies looking for any class that appears more than   once, but with a different hash. This indicates that your dependency tree has conflicting libraries.   |  <code>False</code> |
| dupeclassescheck_ignorelist |  Optional. When using the duplicate class check, this attribute can provide a file   that contains a list of libraries excluded from the analysis. Ex: *dupeclass_libs.txt*   |  <code>None</code> |
| bazelrun_script |  Optional. When launching the application using 'bazel run', a default launcher script is used.   This attribute can be used to provide a customized launcher script. Ex: *my_custom_script.sh*   |  <code>None</code> |
| bazelrun_jvm_flags |  Optional. When launching the application using 'bazel run', an optional set of JVM flags   to pass to the JVM at startup. Ex: *-Dcustomprop=gold -DcustomProp2=silver*   |  <code>None</code> |
| bazelrun_data |  Uncommon option to add data files to runfiles. Behaves like the *data* attribute defined for *java_binary*.   |  <code>None</code> |
| bazelrun_background |  Optional. If True, the *bazel run* launcher will not block. The run command will return and process will remain running.   |  <code>False</code> |
| tags |  Optional. Bazel standard attribute.   |  <code>[]</code> |
| testonly |  Optional. Bazel standard attribute.   |  <code>False</code> |
| visibility |  Optional. Bazel standard attribute.   |  <code>None</code> |
| exclude |  Deprecated synonym of *deps_exclude*   |  <code>[]</code> |
| classpath_index |  Deprecated synonym of *deps_index_file*   |  <code>"@rules_spring//springboot:empty.txt"</code> |
| use_build_dependency_order |  Deprecated synonym of *deps_use_starlark_order*   |  <code>True</code> |
| fail_on_duplicate_classes |  Deprecated synonym of *dupeclassescheck_enable*   |  <code>False</code> |
| duplicate_class_allowlist |  Deprecated synonym of *dupeclassescheck_ignorelist*   |  <code>None</code> |
| jvm_flags |  Deprecated synonym of *bazelrun_jvm_flags*   |  <code>""</code> |
| data |  Deprecated synonym of *bazelrun_data*   |  <code>[]</code> |
