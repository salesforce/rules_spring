package com.depsfilter;

import java.util.ArrayList;
import java.util.List;

/**
 * Helper class containing common functionality for deps filter tests.
 * Provides shared methods and data that can be used across multiple test classes.
 */
public class DepsFilterTestHelper {

    /**
     * Computes the available dependencies from the current classpath.
     * @return List of available dependencies with "../" prefix removed
     */
    public static List<String> computeClasspathDependencies() {
        String classpath = System.getProperty("java.class.path");
        String[] classpathEntries = classpath.split(System.getProperty("path.separator"));
        List<String> availableDeps = new ArrayList<>();
        for (String entry : classpathEntries) {
            availableDeps.add(entry.replace("../", ""));
        }
        return availableDeps;
    }

    /**
     * Returns the test dependencies required to run the tests.
     * These are the dependencies specified in the test target.
     * @return List of test dependencies
     */
    public static List<String> getTestDeps() {
        return List.of(
            "rules_jvm_external~~maven~unmanaged_deps_filter/junit/junit/4.13.2/processed_junit-4.13.2.jar",
            "rules_jvm_external~~maven~unmanaged_deps_filter/org/hamcrest/hamcrest-core/1.3/processed_hamcrest-core-1.3.jar",
            "rules_jvm_external~~maven~unmanaged_deps_filter/org/assertj/assertj-core/3.26.0/processed_assertj-core-3.26.0.jar",
            "rules_jvm_external~~maven~unmanaged_deps_filter/net/bytebuddy/byte-buddy/1.14.16/processed_byte-buddy-1.14.16.jar",
            "rules_java~~toolchains~remote_java_tools/java_tools/Runner_deploy.jar"
        );
    }

    /**
     * Returns the runtime dependencies before exclusions.
     * These are the base runtime dependencies that would be available before any filtering.
     * @return List of runtime dependencies before exclusions
     */
    public static List<String> getRuntimeDepsListBeforeExclusions() {
        return new ArrayList<>(List.of(
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_a.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_b.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_c.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_d.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_e.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_f.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_g.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_h.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_i.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_j.jar"
        ));
    }

    /**
     * Creates a complete list of runtime dependencies including test dependencies.
     * This combines the base runtime dependencies with test dependencies.
     * @return Complete list of runtime dependencies including test dependencies
     */
    public static List<String> getCompleteRuntimeDepsList() {
        List<String> completeList = new ArrayList<>(getRuntimeDepsListBeforeExclusions());
        completeList.addAll(getTestDeps());
        return completeList;
    }
} 