package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterPathPatternsWithSpecialCharactersTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testPathPatternsWithSpecialCharacters() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());
        
        Set<String> excludedPatterns = Set.of("io.micrometer", "to-slf4j");
        
        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForPathExclusionsFiltered(
            excludedPatterns, true);
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime/DepsFilterPathPatternsWithSpecialCharactersTest.jar");

        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 