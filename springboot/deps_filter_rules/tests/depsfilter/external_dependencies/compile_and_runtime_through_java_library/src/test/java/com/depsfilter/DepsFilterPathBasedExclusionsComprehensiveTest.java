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
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime_through_java_library/DepsFilterPathBasedExclusionsComprehensiveTest.jar");
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/depsfilter/external_dependencies/compile_and_runtime_through_java_library/libbase_lib_with_deps_and_runtime_deps.jar");

        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 