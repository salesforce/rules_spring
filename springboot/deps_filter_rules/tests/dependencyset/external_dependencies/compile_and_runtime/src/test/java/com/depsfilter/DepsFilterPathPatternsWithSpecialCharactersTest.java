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
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/DepsFilterPathPatternsWithSpecialCharactersTest.jar");
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/libpath_patterns_with_special_characters_test_lib.jar");

        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 