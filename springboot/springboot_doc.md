<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#springboot"></a>

## springboot

<pre>
springboot(<a href="#springboot-name">name</a>, <a href="#springboot-java_library">java_library</a>, <a href="#springboot-boot_app_class">boot_app_class</a>, <a href="#springboot-deps">deps</a>, <a href="#springboot-fail_on_duplicate_classes">fail_on_duplicate_classes</a>,
           <a href="#springboot-duplicate_class_allowlist">duplicate_class_allowlist</a>, <a href="#springboot-exclude">exclude</a>, <a href="#springboot-classpath_index">classpath_index</a>, <a href="#springboot-use_build_dependency_order">use_build_dependency_order</a>,
           <a href="#springboot-launcher_script">launcher_script</a>, <a href="#springboot-jvm_flags">jvm_flags</a>, <a href="#springboot-tags">tags</a>, <a href="#springboot-visibility">visibility</a>, <a href="#springboot-data">data</a>)
</pre>

Bazel rule for packaging an executable Spring Boot application.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  The name of the Spring Boot application. Typically this is set the same as the package name.   |  none |
| java_library |  The built jar, identified by the name of the java_library rule, that contains the Spring Boot application.   |  none |
| boot_app_class |  The fully qualified name of the class annotation with @SpringBootApplication. E.g. com.sample.SampleMain   |  none |
| deps |  An optional set of Java dependencies to add to the executable. Normally all dependencies are set on the java_library.   |  <code>None</code> |
| fail_on_duplicate_classes |  If True, will analyze the list of dependencies looking for any class that appears more than   once, but with a different hash. This indicates that your dependency tree has conflicting libraries.   |  <code>False</code> |
| duplicate_class_allowlist |  When using the duplicate class check, this attribute can provide a file that contains a list of   libraries excluded from the analysis. E.g. 'dupeclass_libs.txt'   |  <code>None</code> |
| exclude |  A list of jar file labels that will be omitted from the final packaging step. This is a last resort option   for eliminating a problematic dependency that cannot be managed any other way. E.g. '@io_grpc_grpc_java//api:api'.   |  <code>[]</code> |
| classpath_index |  Uses Spring Boots classpath index feature to define classpath order. This feature is not commonly used, as   the application must be extracted from the jar file for it to work. E.g. 'classpath_index.idx'   |  <code>None</code> |
| use_build_dependency_order |  When running the Spring Boot application from the executable jar file, setting this attribute to   True will use the classpath order as expressed by the deps in the BUILD file. Otherwise it is random order.   |  <code>True</code> |
| launcher_script |  When launching the application using 'bazel run', a default launcher script is used. This attribute can be   used to provide a customized launcher script. E.g. 'custom_script.sh'   |  <code>None</code> |
| jvm_flags |  When launching the application using 'bazel run', an optional set of JVM flags to pass to the JVM at startup.   E.g. '-Dcustomprop=gold -DcustomProp2=silver'   |  <code>""</code> |
| tags |  Optional. Standard Bazel attribute.   |  <code>[]</code> |
| visibility |  Optional. Standard Bazel attribute.   |  <code>None</code> |
| data |  Uncommon option to add data files to runfiles. Behaves like the same attribute defined for java_binary.   |  <code>[]</code> |


