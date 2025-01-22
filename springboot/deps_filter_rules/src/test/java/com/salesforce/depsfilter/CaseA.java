package com.salesforce.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.Test;

public class CaseA {

    private List<String> testDeps;
    private List<String> depsList;
    private List<String> transitivesOfFirstDep;
    private List<String> transitivesOfSecondDep;

    @Test
    public void testTransitivesExclusion() {

    /*
    Case 1
    This test verifies the 'exclude_transitives' of 'deps_filter'.
    (exclude_transitives is set to True)

    It is corresponding to the 'filtered_test_deps_with_transitives_excluded' rule in BUILD file
    Please checkout the 'deps' and 'deps_exclude' attributes specified in the rule

    Deps: "@maven//:org_springframework_spring_jdbc" (required, included in 'deps') and
    "@maven//:org_springframework_spring_web" (excluded, listed in 'deps_exclude') share some
    transitive dependencies. All transitives of "@maven//:org_springframework_spring_web" must be
    excluded, except those that are also transitives of "@maven//:org_springframework_spring_jdbc"
    or other required dependencies.

    This test verifies:
    - Deps available at the build time are: "@maven//:org_springframework_spring_jdbc" and its transitives
    - Deps excluded at the build time are: "@maven//:org_springframework_spring_web" and its transitives except
    those
      that are also transitives of "@maven//:org_springframework_spring_jdbc"
    By checking them into the available deps in the code.
    */

        initialTestSetup();
        List<String> allTransitivesDeps = getTransitiveDeps();
        List<String> availableDeps = computeClasspathDependencies();

        // all transitives excluded
        for (String transitive : allTransitivesDeps) {
            assertThat(availableDeps).doesNotContain(transitive);
        }

        // Direct deps that are not excluded, along with their transitive dependencies,
        // and transitives of excluded deps must be present in the availableDeps
        for (String dep : depsList) {
            assertThat(availableDeps).contains(dep);
        }

        // testDeps + depsList = available deps
        List<String> expectedCombinedDepsList = new ArrayList<>();
        List<String> actualCombinedDepsList = new ArrayList<>();
        expectedCombinedDepsList.addAll(testDeps);
        expectedCombinedDepsList.addAll(depsList);

        actualCombinedDepsList.addAll(availableDeps);

        assertThat(actualCombinedDepsList).containsExactlyInAnyOrderElementsOf(expectedCombinedDepsList);
    }

    private List<String> getTransitiveDeps() {
        // Calculate transitives of both excluded and non-excluded deps
        Set<String> uniqueTransitivesSet = new HashSet<>();
        uniqueTransitivesSet.addAll(transitivesOfFirstDep);
        uniqueTransitivesSet.addAll(transitivesOfSecondDep);
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
        testDeps = List.of("springboot/deps_filter_rules/CaseA.jar",
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
