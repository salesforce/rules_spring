package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterSingleDepWithExclusionsTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testSingleDepWithExclusions() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());
        
        Set<String> depsLabels = Set.of("@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa");
        Set<String> runtimeDepsLabels = Set.of();
        Set<String> excludedLabels = Set.of("@unmanaged_deps_filter//:io_micrometer_micrometer_commons");
        Set<String> excludedPatterns = Set.of();
        
        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForCustomDepsFiltered(
            depsLabels, runtimeDepsLabels, excludedLabels, excludedPatterns, false);
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime/DepsFilterSingleDepWithExclusionsTest.jar");

        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 