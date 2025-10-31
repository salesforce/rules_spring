package com.depsfilter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.Test;

public class TransitiveDepsFilterCaseD {

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
                name = "filtered_deps_disable_transitives_case_D",
                deps = [
                    "@maven//:org_springframework_spring_jdbc",
                    "@maven//:org_springframework_spring_web",
                ],
                testonly = True,
            )

            This test verifies:
            - Build-time deps include "@maven//:org_springframework_spring_jdbc" and
              "@maven//:org_springframework_spring_web", and their transitive deps
            - No deps are excluded
            This is validated by checking the available deps in the code.
        */

        initialTestSetup();
        List<String> allTransitivesDeps = getTransitiveDeps();
        List<String> availableDeps = computeClasspathDependencies();

        // Ensure that all transitive deps are included in available deps.
        for (String transitive : allTransitivesDeps) {
            assertThat(availableDeps).contains(transitive);
        }

        // Ensure that all direct deps are included in available deps.
        for (String dep : depsList) {
            assertThat(availableDeps).contains(dep);
        }

        // Ensure that combined list of testDeps, depsList, and allTransitivesDeps 
        // is equal to availableDeps
        List<String> expectedCombinedDepsList = new ArrayList<>();
        List<String> actualCombinedDepsList = new ArrayList<>();
        expectedCombinedDepsList.addAll(testDeps);
        expectedCombinedDepsList.addAll(depsList);
        expectedCombinedDepsList.addAll(allTransitivesDeps);

        actualCombinedDepsList.addAll(availableDeps);

        assertThat(actualCombinedDepsList).containsExactlyInAnyOrderElementsOf(expectedCombinedDepsList);
    }

    private List<String> getTransitiveDeps() {
        // Compute transitive deps of both excluded and non-excluded deps
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
        testDeps = List.of("springboot/deps_filter_rules_legacy/TransitiveDepsFilterCaseD.jar",
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
