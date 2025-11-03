package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterNoFilteringTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testNoFiltering() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());
        
        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForNoFilteringFiltered();
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/DepsFilterNoFilteringTest.jar");
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/libno_filtering_test_lib.jar");
        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 