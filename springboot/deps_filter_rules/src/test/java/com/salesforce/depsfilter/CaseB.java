package com.salesforce.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.Test;

public class CaseB {

    private List<String> testDeps;
    private List<String> depsList;
    private List<String> transitivesOfFirstDep;
    private List<String> transitivesOfSecondDep;

    @Test
    public void testTransitivesExclusion() {

    /*
    This test verifies the 'exclude_transitives' of 'deps_filter'.
    (exclude_transitives is set to False)

    It is corresponding to the 'filtered_test_deps_with_transitives_excluded' rule in BUILD file
    Please checkout the 'deps' and 'deps_exclude' attributes specified in the rule

    Deps: "@maven//:org_springframework_spring_jdbc" (required, included in 'deps') and
    "@maven//:org_springframework_spring_web" (excluded, listed in 'deps_exclude') share some
    transitive dependencies. All transitives of "@maven//:org_springframework_spring_web" and
    "@maven//:org_springframework_spring_jdbc" must not be excluded (exclude_transitives is set to False).

    This test verifies:
    - Deps excluded at the build time are: "@maven//:org_springframework_spring_web"
    - Deps available at the build time are: "@maven//:org_springframework_spring_jdbc" and its transitives
      plus the transitives of "@maven//:org_springframework_spring_web"

    By checking them into the available deps in the code.
    */
        initialTestSetup();
        List<String> expectedExcludedTransitives = getExcludedTransitives();
        List<String> expectedNonExcludedTransitives = getNonExcludedTransitives();
        List<String> availableDeps = computeClasspathDependencies();

        // Direct deps excluded from the build, along with their transitives (which are not required by
        // other non-excluded deps), must not present in the availableDeps - this ensure only necessary
        // deps are available in the build
        
        
        for (String excludedTransitive : expectedExcludedTransitives) {
        assertThat(availableDeps).doesNotContain(excludedTransitive);
        }

        // Direct deps that are not excluded, along with their transitive dependencies,
        // must be present in the availableDeps
        for (String dep : depsList) {
            assertThat(availableDeps).contains(dep);
        }
        for (String nonExcludedTransitive : expectedNonExcludedTransitives) {
            assertThat(availableDeps).contains(nonExcludedTransitive);
        }

        // testDeps + depsList + expectedExcludedTransitives + expectedNonExcludedTransitives
        // must be equal to availableDeps + expectedExcludedTransitives
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
    // All transitive dependencies of excluded dependencies should be excluded,
    // except those that are also transitives of non-excluded dependencies
    // or the non-excluded dependencies themselves.
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
        // Transitives of non-excluded deps
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
        testDeps = List.of("springboot/deps_filter_rules/CaseB.jar",
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
            "rules_jvm_external~~maven~maven/io/micrometer/micrometer-observation/1.13.6/processed_micrometer-observation-1.13.6.jar",
            "rules_jvm_external~~maven~maven/io/micrometer/micrometer-commons/1.13.6/processed_micrometer-commons-1.13.6.jar",
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
