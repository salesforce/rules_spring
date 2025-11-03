package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterCaseSensitivePatternMatchingTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testCaseSensitivePatternMatching() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());
        
        Set<String> excludedPatterns = Set.of("SPRING", "Jackson", "HIBERNATE");
        
        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForPathExclusionsFiltered(
            excludedPatterns, false);
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime/DepsFilterCaseSensitivePatternMatchingTest.jar");

        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 