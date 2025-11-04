package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.BeforeClass;
import org.junit.Test;

public class DepsFilterCompileDepsOnlyTest {

    @BeforeClass
    public static void setUp() {
        DependencyGraphTestConfig.initialize();
    }

    @Test
    public void testCompileDepsOnly() {
        Set<String> availableDeps = Set.copyOf(DepsFilterTestHelper.computeClasspathDependencies());

        Set<String> depsLabels = Set.of(
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
            "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
            "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
            "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
            "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api"
        );
        Set<String> runtimeDepsLabels = Set.of();
        Set<String> excludedLabels = Set.of();
        Set<String> excludedPatterns = Set.of();
        boolean excludeTransitives = false;

        Set<String> expectedRuntimeDeps = DependencyGraphTestConfig.getExpectedJarsForCustomDepsFiltered(
            depsLabels, runtimeDepsLabels, excludedLabels, excludedPatterns, excludeTransitives);
        expectedRuntimeDeps.addAll(DepsFilterTestHelper.getTestDeps());
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/DepsFilterCompileDepsOnlyTest.jar");
        expectedRuntimeDeps.add("springboot/deps_filter_rules/tests/dependencyset/external_dependencies/compile_and_runtime/libcompile_deps_only_test_lib.jar");
        
        assertThat(availableDeps).isEqualTo(expectedRuntimeDeps);
    }
} 