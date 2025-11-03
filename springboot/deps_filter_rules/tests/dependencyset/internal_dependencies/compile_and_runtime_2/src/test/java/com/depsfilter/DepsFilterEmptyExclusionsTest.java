package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import org.junit.Test;

public class DepsFilterEmptyExclusionsTest {

    @Test
    public void testTransitivesExclusion() {
        /*
            Checkout _test_empty_exclusion_lists in compile_and_runtime_2/compile_and_runtime_test.bzl
        */
        // available deps at the runtime
        List<String> availableDeps = DepsFilterTestHelper.computeClasspathDependencies();
        
        // expected runtime deps
        List<String> expectedRuntimeDeps = new ArrayList<>(DepsFilterTestHelper.getRuntimeDepsListBeforeExclusions());
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());        
        // Add test-specific JAR file
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/DepsFilterEmptyExclusionsTest.jar");
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/internal_dependencies/compile_and_runtime_2/libempty_exclusion_lists_test_lib.jar");

        // Verify that availableDeps contains exactly the same elements as expectedRuntimeDeps in any order
        assertThat(availableDeps).containsExactlyInAnyOrderElementsOf(expectedRuntimeDeps);
    }
}
