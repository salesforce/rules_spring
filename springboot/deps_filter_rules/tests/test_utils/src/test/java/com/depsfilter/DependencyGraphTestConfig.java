package com.depsfilter;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

public class DependencyGraphTestConfig {
    
    private static DependencyGraphAnalyzer analyzer;
    private static boolean initialized = false;
    
    private static final List<String> STANDARD_DEPS = Arrays.asList(
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_data_jpa",
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_security",
        "@unmanaged_deps_filter//:com_fasterxml_jackson_core_jackson_databind",
        "@unmanaged_deps_filter//:org_hibernate_orm_hibernate_core",
        "@unmanaged_deps_filter//:jakarta_servlet_jsp_jakarta_servlet_jsp_api"
    );
    
    private static final List<String> STANDARD_RUNTIME_DEPS = Arrays.asList(
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_oauth2_client",
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_webflux",
        "@unmanaged_deps_filter//:org_springframework_boot_spring_boot_starter_actuator"
    );
    
    public static void initialize() {
        if (initialized) {
            return;
        }
        
        try {
            String graphOutput = Files.readString(Paths.get("springboot/deps_filter_rules/tests/test_utils/dependency_graph.txt"));
            analyzer = new DependencyGraphAnalyzer();
            analyzer.parseDependencyGraph(graphOutput);
            initialized = true;
        } catch (IOException e) {
            throw new RuntimeException("Failed to load dependency graph", e);
        }
    }
    
    public static DependencyGraphAnalyzer getAnalyzer() {
        if (!initialized) {
            initialize();
        }
        return analyzer;
    }
    
    public static Set<String> getExpectedJarsForNoFiltering() {
        return getAnalyzer().computeExpectedRuntimeJars(
            STANDARD_DEPS,
            STANDARD_RUNTIME_DEPS,
            Collections.emptySet(),
            Collections.emptySet(),
            false
        );
    }
    
    public static Set<String> getExpectedJarsForNoFilteringFiltered() {
        Set<String> all = getExpectedJarsForNoFiltering();
        Set<String> filtered = new HashSet<>();
        for (String jar : all) {
            if (!jar.endsWith("-sources.jar")) {
                filtered.add(jar);
            }
        }
        return filtered;
    }
    
    public static Set<String> getExpectedJarsForLabelExclusions(Set<String> excludedLabels, boolean excludeTransitives) {
        return getAnalyzer().computeExpectedRuntimeJars(
            STANDARD_DEPS,
            STANDARD_RUNTIME_DEPS,
            excludedLabels,
            Collections.emptySet(),
            excludeTransitives
        );
    }
    
    public static Set<String> getExpectedJarsForLabelExclusionsFiltered(Set<String> excludedLabels, boolean excludeTransitives) {
        Set<String> all = getExpectedJarsForLabelExclusions(excludedLabels, excludeTransitives);
        Set<String> filtered = new HashSet<>();
        for (String jar : all) {
            if (!jar.endsWith("-sources.jar")) {
                filtered.add(jar);
            }
        }
        return filtered;
    }
    
    public static Set<String> getExpectedJarsForPathExclusions(Set<String> excludedPatterns, boolean excludeTransitives) {
        return getAnalyzer().computeExpectedRuntimeJars(
            STANDARD_DEPS,
            STANDARD_RUNTIME_DEPS,
            Collections.emptySet(),
            excludedPatterns,
            excludeTransitives
        );
    }
    
    public static Set<String> getExpectedJarsForPathExclusionsFiltered(Set<String> excludedPatterns, boolean excludeTransitives) {
        Set<String> all = getExpectedJarsForPathExclusions(excludedPatterns, excludeTransitives);
        Set<String> filtered = new HashSet<>();
        for (String jar : all) {
            if (!jar.endsWith("-sources.jar")) {
                filtered.add(jar);
            }
        }
        return filtered;
    }
    
    public static Set<String> getExpectedJarsForMultipleExclusions(
            Set<String> excludedLabels, 
            Set<String> excludedPatterns, 
            boolean excludeTransitives) {
        return getAnalyzer().computeExpectedRuntimeJars(
            STANDARD_DEPS,
            STANDARD_RUNTIME_DEPS,
            excludedLabels,
            excludedPatterns,
            excludeTransitives
        );
    }
    
    public static Set<String> getExpectedJarsForMultipleExclusionsFiltered(
            Set<String> excludedLabels, 
            Set<String> excludedPatterns, 
            boolean excludeTransitives) {
        Set<String> all = getExpectedJarsForMultipleExclusions(excludedLabels, excludedPatterns, excludeTransitives);
        Set<String> filtered = new HashSet<>();
        for (String jar : all) {
            if (!jar.endsWith("-sources.jar")) {
                filtered.add(jar);
            }
        }
        return filtered;
    }
    
    public static List<String> getStandardDeps() {
        return new ArrayList<>(STANDARD_DEPS);
    }
    
    public static List<String> getStandardRuntimeDeps() {
        return new ArrayList<>(STANDARD_RUNTIME_DEPS);
    }
    
    public static Set<String> getExpectedJarsForCustomDeps(
            List<String> depsLabels,
            List<String> runtimeDepsLabels,
            Set<String> excludedLabels,
            Set<String> excludedPatterns,
            boolean excludeTransitives) {
        return getAnalyzer().computeExpectedRuntimeJars(
            depsLabels,
            runtimeDepsLabels,
            excludedLabels,
            excludedPatterns,
            excludeTransitives
        );
    }
    
    public static Set<String> getExpectedJarsForCustomDepsFiltered(
            Set<String> depsLabels,
            Set<String> runtimeDepsLabels,
            Set<String> excludedLabels,
            Set<String> excludedPatterns,
            boolean excludeTransitives) {
        Set<String> all = getAnalyzer().computeExpectedRuntimeJars(
            new ArrayList<>(depsLabels),
            new ArrayList<>(runtimeDepsLabels),
            excludedLabels,
            excludedPatterns,
            excludeTransitives
        );
        Set<String> filtered = new HashSet<>();
        for (String jar : all) {
            if (!jar.endsWith("-sources.jar")) {
                filtered.add(jar);
            }
        }
        return filtered;
    }
} 