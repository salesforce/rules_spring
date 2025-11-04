package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.Test;

public class TransitiveDepsFilterCaseB {

    private List<String> testDeps;
    private List<String> depsList;
    private List<String> transitivesOfFirstDep;
    private List<String> transitivesOfSecondDep;

    @Test
    public void testTransitivesExclusion() {
        /*
            This test is for the 'deps_filter_disable_transitives' rule
            Corresponds to the 'filtered_deps_disable_transitives_case_B' rule in the BUILD file:
    
            deps_filter_disable_transitives(
                name = "filtered_deps_disable_transitives_case_B",
                deps = [
                    "@maven//:org_springframework_spring_jdbc",
                    "@maven//:org_springframework_spring_web",
                ],
                deps_to_exclude_transitives = [
                    "@maven//:org_springframework_spring_web",
                ],
                testonly = True,
            )

            This test verifies:
            - Build-time deps include "@maven//:org_springframework_spring_jdbc", its transitive deps, and
              "@maven//:org_springframework_spring_web"
            - Excluded deps include transitive deps of @maven//:org_springframework_spring_web, except those that are
              transitive deps of @maven//:org_springframework_spring_jdbc"

            This is validated by checking the available deps in the code.
        */

        initialTestSetup();
        List<String> expectedExcludedTransitives = getExcludedTransitives();
        List<String> expectedNonExcludedTransitives = getNonExcludedTransitives();
        List<String> availableDeps = computeClasspathDependencies();

        // Ensure that all expected excluded deps are not present in available deps.
        for (String excludedTransitive : expectedExcludedTransitives) {
            assertThat(availableDeps).doesNotContain(excludedTransitive);
        }

        // Ensure that all direct deps are present in available deps.
        for (String dep : depsList) {
            assertThat(availableDeps).contains(dep);
        }

        // Ensure that transitive deps of deps not specified in deps_to_exclude_transitives are present in available
        // deps.
        for (String nonExcludedTransitive : expectedNonExcludedTransitives) {
            assertThat(availableDeps).contains(nonExcludedTransitive);
        }

        // Ensure that combined list of  testDeps, depsList, expectedExcludedTransitives, and
        // expectedNonExcludedTransitives is equal to combined list of availableDeps, and
        // expectedExcludedTransitives.
        List<String> expectedCombinedDepsList = new ArrayList<>();
        List<String> actualCombinedDepsList = new ArrayList<>();
        expectedCombinedDepsList.addAll(testDeps);
        expectedCombinedDepsList.addAll(depsList);
        expectedCombinedDepsList.addAll(expectedNonExcludedTransitives);
        expectedCombinedDepsList.addAll(expectedExcludedTransitives);

        actualCombinedDepsList.addAll(availableDeps);
        actualCombinedDepsList.addAll(expectedExcludedTransitives);

        assertThat(actualCombinedDepsList)
            .containsExactlyInAnyOrderElementsOf(expectedCombinedDepsList);
    }

    private List<String> getExcludedTransitives() {
        // All transitive deps of specified deps in the exclusion list should be excluded,
        // except those that are also transitive deps of deps not in exclusion list
        // or the direct deps themselves
        List<String> expectedExcludedTransitives = new ArrayList<>();
        for (String transitive : transitivesOfFirstDep) {
            if ((!transitivesOfSecondDep.contains(transitive))
                && (!depsList.contains(transitive))) {
                expectedExcludedTransitives.add(transitive);
            }
        }
        return expectedExcludedTransitives;
    }

    private List<String> getNonExcludedTransitives() {
        // Transitive deps of direct deps that are not specified in the exclusion list
        List<String> expectedNonExcludedTransitives = new ArrayList<>();
        for (String transitive : transitivesOfSecondDep) {
            expectedNonExcludedTransitives.add(transitive);
        }
        return expectedNonExcludedTransitives;
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
        testDeps = List.of("springboot/deps_filter_rules_legacy/TransitiveDepsFilterCaseB.jar",
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

        transitivesOfFirstDep = List.of(
            "rules_jvm_external~~maven~maven/io/micrometer/micrometer-observation/1.13"
            + ".6/processed_micrometer-observation-1.13.6.jar",
            "rules_jvm_external~~maven~maven/io/micrometer/micrometer-commons/1.13.6/processed_micrometer-commons-1"
            + ".13.6.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-beans/6.1.14/processed_spring-beans-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-core/6.1.14/processed_spring-core-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-jcl/6.1.14/processed_spring-jcl-6.1.14.jar"
        );

        transitivesOfSecondDep = List.of(
            "rules_jvm_external~~maven~maven/org/springframework/spring-beans/6.1.14/processed_spring-beans-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-core/6.1.14/processed_spring-core-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-jcl/6.1.14/processed_spring-jcl-6.1.14.jar",
            "rules_jvm_external~~maven~maven/org/springframework/spring-tx/6.1.14/processed_spring-tx-6.1.14.jar"
        );
    }
}
