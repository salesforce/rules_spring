package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterRuntimeDepsOnlyTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testRuntimeDepsOnly() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());

        Set<String> depsLabels = Set.of();
        Set<String> runtimeDepsLabels = Set.of(
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator"
        );
        Set<String> excludedLabels = Set.of();
        Set<String> excludedPatterns = Set.of();
        boolean excludeTransitives = false;

        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForCustomDepsFiltered(
            depsLabels, runtimeDepsLabels, excludedLabels, excludedPatterns, excludeTransitives);
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/DepsFilterRuntimeDepsOnlyTest.jar");
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/libruntime_deps_only_test_lib.jar");

        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 