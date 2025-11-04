package com.depsfilter;

import java.util.ArrayList;
import java.util.List;

public class DepsFilterTestHelper {

    public static List<String> computeClasspathDependencies() {
        String classpath = System.getProperty("java.class.path");
        String[] classpathEntries = classpath.split(System.getProperty("path.separator"));
        List<String> availableDeps = new ArrayList<>();
        for (String entry : classpathEntries) {
            availableDeps.add(entry.replace("../", ""));
        }
        return availableDeps;
    }

    public static List<String> getTestDeps() {
        return List.of(
            "rules_jvm_external~~maven~unmanaged_deps_filter/junit/junit/4.13.2/processed_junit-4.13.2.jar",
            "rules_jvm_external~~maven~unmanaged_deps_filter/org/hamcrest/hamcrest-core/1.3/processed_hamcrest-core-1.3.jar",
            "rules_jvm_external~~maven~unmanaged_deps_filter/org/assertj/assertj-core/3.26.0/processed_assertj-core-3.26.0.jar",
            "rules_jvm_external~~maven~unmanaged_deps_filter/net/bytebuddy/byte-buddy/1.14.16/processed_byte-buddy-1.14.16.jar",
            "rules_java~~toolchains~remote_java_tools/java_tools/Runner_deploy.jar",
            "springboot/deps_filter_rules/tests/test_utils/libtest_utils.jar"
        );
    }

} 