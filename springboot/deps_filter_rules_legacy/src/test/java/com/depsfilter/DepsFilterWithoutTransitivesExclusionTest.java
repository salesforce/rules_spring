package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.Test;

public class DepsFilterWithoutTransitivesExclusionTest {

    private List<String> testDeps;
    private List<String> depsList;
    private List<String> excludedDirectDeps;
    private List<String> nonexcludedDirectDeps;
    private List<String> transitivesOfExcludedDirectDeps;
    private List<String> transitivesOfNonExcludedDirectDeps;

    @Test
    public void testTransitivesExclusion() {
        /*
            Tests the 'deps_filter' rule with its 'exclude_transitives' attribute set to False.
            Corresponds to the 'filtered_test_deps_with_transitives_excluded' rule in the BUILD file:

            deps_filter(
                name = "filtered_test_deps_without_transitives_excluded",
                deps = [
                    "@maven//:org_springframework_spring_jdbc",
                    "@maven//:org_springframework_spring_web",
                ],
                deps_exclude_labels = [
                    "@maven//:org_springframework_spring_web", # share transitives with spring-jdbc
                ],
                exclude_transitives = False,
                testonly = True,
            )

            This test verifies:
            - Excluded deps include "@maven//:org_springframework_spring_web"
            - Build-time deps include "@maven//:org_springframework_spring_jdbc" and its transitive deps
              Build-time deps also include transitive deps of "@maven//:org_springframework_spring_web"

            This is validated by checking the available deps in the code.
        */

        initialTestSetup();
        List<String> allTransitivesDeps = getTransitiveDeps();
        List<String> availableDeps = computeClasspathDependencies();

        // Ensure that direct deps listed for exclusion are not present in the available deps.
        for (String excludedDep : excludedDirectDeps) {
            assertThat(availableDeps).doesNotContain(excludedDep);
        }

        // Ensure that non-excluded direct deps, their transitive deps, and the transitive deps of excluded deps are
        // present in the available deps.
        for (String nonExcludedDep : nonexcludedDirectDeps) {
            assertThat(availableDeps).contains(nonExcludedDep);
        }

        for (String transitive : transitivesOfExcludedDirectDeps) {
            assertThat(availableDeps).contains(transitive);
        }

        for (String transitive : transitivesOfNonExcludedDirectDeps) {
            assertThat(availableDeps).contains(transitive);
        }

        // Ensure that the combined list of testDeps, depsList, and allTransitivesDeps
        // is equal to the combined list of availableDeps, and excludedDirectDeps.
        List<String> expectedCombinedDepsList = new ArrayList<>();
        List<String> actualCombinedDepsList = new ArrayList<>();
        expectedCombinedDepsList.addAll(testDeps);
        expectedCombinedDepsList.addAll(depsList);
        expectedCombinedDepsList.addAll(allTransitivesDeps);

        actualCombinedDepsList.addAll(availableDeps);
        actualCombinedDepsList.addAll(excludedDirectDeps);

        assertThat(actualCombinedDepsList).containsExactlyInAnyOrderElementsOf(expectedCombinedDepsList);
    }

    private List<String> getTransitiveDeps() {
        // Compute transitive deps of both excluded and non-excluded deps
        Set<String> uniqueTransitivesSet = new HashSet<>();
        uniqueTransitivesSet.addAll(transitivesOfExcludedDirectDeps);
        uniqueTransitivesSet.addAll(transitivesOfNonExcludedDirectDeps);
        for (String directDependency : depsList) {
            uniqueTransitivesSet.remove(directDependency);
        }
        List<String> allTransitivesDeps = List.copyOf(uniqueTransitivesSet);
        return allTransitivesDeps;
    }

    private List<String> computeClasspathDependencies() {
        String classpath = System.getProperty("java.class.path");
        String[] classpathEntries = classpath.split(System.getProperty("path.separator"));
        List<String> availableDeps = new ArrayList<>();
        for (String entry : classpathEntries) {
            availableDeps.add(entry.replace("../", ""));
        }
        return availableDeps;
    }

    private void initialTestSetup() {
        // required to run the test - specified in the test target
        testDeps = List.of("springboot/deps_filter_rules_legacy/DepsFilterWithoutTransitivesExclusionTest.jar",
            "rules_jvm_external~~maven~maven/junit/junit/4.13.2/processed_junit-4.13.2.jar",
            "rules_jvm_external~~maven~maven/org/hamcrest/hamcrest-core/2.2/processed_hamcrest-core-2.2.jar",
            "rules_jvm_external~~maven~maven/org/hamcrest/hamcrest/2.2/processed_hamcrest-2.2.jar",
            "rules_jvm_external~~maven~maven/org/assertj/assertj-core/3.25.3/processed_assertj-core-3.25.3.jar",
            "rules_jvm_external~~maven~maven/net/bytebuddy/byte-buddy/1.14.12/processed_byte-buddy-1.14.12.jar",
            "rules_java~~toolchains~remote_java_tools/java_tools/Runner_deploy.jar"
        );

        // specified in the 'deps' attribute of 'deps_filter'
        depsList = List.of(
            "rules_jvm_external~~maven~maven/org/springframework/spring-jdbc/6.1.14/processed_spring-jdbc-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-web/6.1.14/processed_spring-web-6.1.14.jar"
        );

        // specified in the 'deps_exclude_labels' attribute of 'deps_filter'
        excludedDirectDeps = List.of(
            "rules_jvm_external~~maven~maven/org/springframework/spring-web/6.1.14/processed_spring-web-6.1.14.jar"
        );

        // deps that are not excluded = depsList - excludedDirectDeps
        nonexcludedDirectDeps = List.of(
            "rules_jvm_external~~maven~maven/org/springframework/spring-jdbc/6.1.14/processed_spring-jdbc-6.1.14.jar"
        );

        transitivesOfExcludedDirectDeps = List.of(
            "rules_jvm_external~~maven~maven/io/micrometer/micrometer-observation/1.13"
            + ".6/processed_micrometer-observation-1.13.6.jar",
            "rules_jvm_external~~maven~maven/io/micrometer/micrometer-commons/1.13.6/processed_micrometer-commons-1"
            + ".13.6.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-beans/6.1.14/processed_spring-beans-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-core/6.1.14/processed_spring-core-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-jcl/6.1.14/processed_spring-jcl-6.1.14.jar"
        );

        transitivesOfNonExcludedDirectDeps = List.of(
            "rules_jvm_external~~maven~maven/org/springframework/spring-beans/6.1.14/processed_spring-beans-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-core/6.1.14/processed_spring-core-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-jcl/6.1.14/processed_spring-jcl-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-tx/6.1.14/processed_spring-tx-6.1.14.jar"
        );
    }
}
