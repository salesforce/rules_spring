package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterSingleRuntimeDepWithExclusionsBTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testSingleRuntimeDepWithExclusions() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());

        Set<String> depsLabels = Set.of();
        Set<String> runtimeDepsLabels = Set.of("@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client");
        Set<String> excludedLabels = Set.of();
        Set<String> excludedPatterns = Set.of("slf4j");
        boolean excludeTransitives = false;

        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForCustomDepsFiltered(
            depsLabels, runtimeDepsLabels, excludedLabels, excludedPatterns, excludeTransitives);
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime_through_java_library/DepsFilterSingleRuntimeDepWithExclusionsBTest.jar");
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime_through_java_library/libbase_lib_with_single_runtime_dep.jar");
        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 