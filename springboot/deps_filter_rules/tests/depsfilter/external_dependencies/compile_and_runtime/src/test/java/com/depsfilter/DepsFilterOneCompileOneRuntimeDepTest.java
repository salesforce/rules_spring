package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterOneCompileOneRuntimeDepTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testOneCompileOneRuntimeDep() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());

        Set<String> depsLabels = Set.of("@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa");
        Set<String> runtimeDepsLabels = Set.of("@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client");
        Set<String> excludedLabels = Set.of();
        Set<String> excludedPatterns = Set.of();
        boolean excludeTransitives = false;

        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForCustomDepsFiltered(
            depsLabels, runtimeDepsLabels, excludedLabels, excludedPatterns, excludeTransitives);
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime/DepsFilterOneCompileOneRuntimeDepTest.jar");

        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 