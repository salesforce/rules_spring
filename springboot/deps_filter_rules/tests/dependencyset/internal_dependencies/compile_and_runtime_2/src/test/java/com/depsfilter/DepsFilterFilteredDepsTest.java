package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import org.junit.Test;

public class DepsFilterFilteredDepsTest {

    @Test
    public void testFilteredDeps() {
        /*
            Checkout _test_filtered_deps in compile_and_runtime_2/compile_and_runtime_test.bzl
        */
        // available deps at the runtime
        List<String> availableDeps = DepsFilterTestHelper.computeClasspathDependencies();
        
        // expected runtime deps based on bzl file expected_transitive_runtime_jars
        List<String> expectedRuntimeDeps = new ArrayList<>(List.of(
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_a.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_c.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_d.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_e.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_f.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_h.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_i.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/liblib_j.jar",
            "springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/DepsFilterFilteredDepsTest.jar"
        ));
        
        // Add test dependencies
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/libexclude_b_g_test_lib.jar");

        // Verify that availableDeps contains exactly the same elements as expectedRuntimeDeps in any order
        assertThat(availableDeps).containsExactlyInAnyOrderElementsOf(expectedRuntimeDeps);
    }
} 