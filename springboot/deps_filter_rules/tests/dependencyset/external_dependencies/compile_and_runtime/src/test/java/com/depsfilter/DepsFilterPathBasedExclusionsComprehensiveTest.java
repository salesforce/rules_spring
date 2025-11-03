package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterPathBasedExclusionsComprehensiveTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testPathBasedExclusionsComprehensive() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());
        
        Set<String> excludedPatterns = Set.of("micrometer", "slf4j", "logback");
        
        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForPathExclusionsFiltered(
            excludedPatterns, false);
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/DepsFilterPathBasedExclusionsComprehensiveTest.jar");
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/libpath_based_exclusions_comprehensive_test_lib.jar");

        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 