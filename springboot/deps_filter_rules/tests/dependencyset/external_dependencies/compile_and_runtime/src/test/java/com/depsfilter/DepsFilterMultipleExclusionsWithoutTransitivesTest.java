package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterMultipleExclusionsWithoutTransitivesTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testMultipleExclusionsWithoutTransitives() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());
        
        Set<String> excludedLabels = Set.of(
            "@unmanaged_deps_filter//:io_micrometer_micrometer_commons",
            "@unmanaged_deps_filter//:org_slf4j_jul_to_slf4j"
        );
        Set<String> excludedPatterns = Set.of("slf4j");
        
        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForMultipleExclusionsFiltered(
            excludedLabels, excludedPatterns, true);
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/DepsFilterMultipleExclusionsWithoutTransitivesTest.jar");
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/libmultiple_exclusions_without_exclude_transitives_test_lib.jar");

        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 