package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterEmptyExclusionsTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testTransitivesExclusion() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());

        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForNoFilteringFiltered();

        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime/DepsFilterEmptyExclusionsTest.jar");

        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
}
