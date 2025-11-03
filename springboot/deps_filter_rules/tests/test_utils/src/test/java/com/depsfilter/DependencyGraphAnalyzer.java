package com.depsfilter;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DependencyGraphAnalyzer {
    
    private final Map<String, Set<String>> dependencyGraph = new HashMap<>();
    private final Map<String, String> labelToRuntimeMapping = new HashMap<>();
    private final Set<String> allJarLabels = new HashSet<>();
    
    public void parseDependencyGraph(String graphOutput) {
        String[] lines = graphOutput.split("\n");
        
        for (String line : lines) {
            if (line.trim().isEmpty() || !line.contains("->")) {
                continue;
            }
            
            Pattern edgePattern = Pattern.compile("\"([^\"]+)\"\\s*->\\s*\"([^\"]+)\"");
            Matcher matcher = edgePattern.matcher(line);
            
            if (matcher.find()) {
                String from = matcher.group(1);
                String to = matcher.group(2);
                
                // Build complete graph - don't filter here
                dependencyGraph.computeIfAbsent(from, k -> new HashSet<>()).add(to);
                
                // Track JAR labels for mapping
                if (isJarLabel(from)) {
                    allJarLabels.add(from);
                }
                if (isJarLabel(to)) {
                    allJarLabels.add(to);
                }
            }
        }
        
        buildLabelToRuntimeMapping();
    }
    
    private boolean isJarLabel(String label) {
        return label.startsWith("@") && label.contains("//:") && label.endsWith(".jar");
    }
    
    private boolean isTargetLabel(String label) {
        return (label.startsWith("@spring//") || label.startsWith("@jakarta//")) && !label.contains(".jar");
    }
    
    private void buildLabelToRuntimeMapping() {
        for (String label : allJarLabels) {
            String runtimeName = convertLabelToRuntimeName(label);
            if (runtimeName != null) {
                labelToRuntimeMapping.put(label, runtimeName);
            }
        }
    }
    
    private String convertLabelToRuntimeName(String label) {
        if (!isJarLabel(label)) {
            return null;
        }
        
        String runtimePath = label.substring(1).replace("//:", "/");
        
        // Replace unmanaged_deps_filter/ with rules_jvm_external~~maven~unmanaged_deps_filter/
        runtimePath = runtimePath.replace("unmanaged_deps_filter/", "rules_jvm_external~~maven~unmanaged_deps_filter/");
        
        int lastSlash = runtimePath.lastIndexOf('/');
        if (lastSlash != -1) {
            String directory = runtimePath.substring(0, lastSlash + 1);
            String filename = runtimePath.substring(lastSlash + 1);
            return directory + "processed_" + filename;
        }
        
        return null;
    }
    
    public Set<String> computeExpectedRuntimeJars(
            List<String> depsLabels,
            List<String> runtimeDepsLabels,
            Set<String> excludedLabels,
            Set<String> excludedPatterns,
            boolean excludeTransitives) {
        
        Set<String> expectedJars = new HashSet<>();
        Set<String> excludedNodes = new HashSet<>();
        
        if (excludeTransitives) {
            // When excludeTransitives=true, exclude the labels and all their transitives
            for (String excludedLabel : excludedLabels) {
                excludedNodes.add(excludedLabel);
                excludedNodes.addAll(getTransitiveDependencies(excludedLabel));
            }
        } else {
            // When excludeTransitives=false, only exclude the specific labels, not their transitives
            excludedNodes.addAll(excludedLabels);
        }
        
        // Process compile dependencies
        for (String depLabel : depsLabels) {
            if (!excludedNodes.contains(depLabel)) {
                addDependencyAndTransitives(depLabel, expectedJars, excludedNodes, excludedPatterns, excludeTransitives);
            }
        }
        
        // Process runtime dependencies
        for (String runtimeDepLabel : runtimeDepsLabels) {
            if (!excludedNodes.contains(runtimeDepLabel)) {
                addDependencyAndTransitives(runtimeDepLabel, expectedJars, excludedNodes, excludedPatterns, excludeTransitives);
            }
        }
        
        // Final filtering: remove any excluded labels from the result
        Set<String> finalResult = new HashSet<>();
        
        // Build a set of JAR labels that should be excluded
        Set<String> excludedJarLabels = new HashSet<>();
        for (String excludedLabel : excludedLabels) {
            if (isJarLabel(excludedLabel)) {
                // Direct JAR label exclusion
                excludedJarLabels.add(excludedLabel);
            } else {
                // Target label exclusion - find all JAR labels reachable from this target
                Set<String> reachableJars = new HashSet<>();
                Set<String> visited = new HashSet<>();
                findReachableJarLabels(excludedLabel, reachableJars, visited);
                excludedJarLabels.addAll(reachableJars);
            }
        }
        
        for (String jar : expectedJars) {
            // Check if this JAR corresponds to an excluded JAR label
            boolean isExcluded = false;
            for (String excludedJarLabel : excludedJarLabels) {
                String runtimeName = labelToRuntimeMapping.get(excludedJarLabel);
                if (runtimeName != null && runtimeName.equals(jar)) {
                    isExcluded = true;
                    break;
                }
            }
            if (!isExcluded) {
                finalResult.add(jar);
            }
        }
        
        return finalResult;
    }
    
    private void addDependencyAndTransitives(
            String depLabel,
            Set<String> expectedJars,
            Set<String> excludedNodes,
            Set<String> excludedPatterns,
            boolean excludeTransitives) {
        
        // Add the direct dependency if it's not excluded
        if (!excludedNodes.contains(depLabel) && !isExcludedByPattern(depLabel, excludedPatterns)) {
            String runtimeName = labelToRuntimeMapping.get(depLabel);
            if (runtimeName != null) {
                expectedJars.add(runtimeName);
            }
        }
        
        // Add transitives, but respect exclusions
        Set<String> transitives = getTransitiveDependencies(depLabel);
        for (String transitive : transitives) {
            if (!excludedNodes.contains(transitive) && !isExcludedByPattern(transitive, excludedPatterns)) {
                String runtimeName = labelToRuntimeMapping.get(transitive);
                if (runtimeName != null) {
                    expectedJars.add(runtimeName);
                }
            }
        }
    }
    
    private Set<String> getTransitiveDependencies(String label) {
        Set<String> transitives = new HashSet<>();
        Set<String> visited = new HashSet<>();
        dfs(label, visited, transitives);
        return transitives;
    }
    
    private void dfs(String node, Set<String> transitives, Set<String> visited) {
        if (visited.contains(node)) {
            return;
        }
        visited.add(node);
        
        Set<String> neighbors = dependencyGraph.get(node);
        if (neighbors != null) {
            for (String neighbor : neighbors) {
                // Only add JAR labels to transitives, but traverse all paths
                if (isJarLabel(neighbor)) {
                    transitives.add(neighbor);
                }
                // Continue traversal regardless of node type
                dfs(neighbor, transitives, visited);
            }
        }
    }
    
    private boolean isExcludedByPattern(String label, Set<String> patterns) {
        String runtimeName = labelToRuntimeMapping.get(label);
        if (runtimeName == null) {
            return false;
        }
        
        for (String pattern : patterns) {
            if (runtimeName.contains(pattern)) {
                return true;
            }
        }
        return false;
    }
    
    public Map<String, String> getLabelToRuntimeMapping() {
        return new HashMap<>(labelToRuntimeMapping);
    }
    
    public Map<String, Set<String>> getDependencyGraph() {
        return new HashMap<>(dependencyGraph);
    }

    private void findReachableJarLabels(String node, Set<String> jarLabels, Set<String> visited) {
        if (visited.contains(node)) {
            return;
        }
        visited.add(node);
        
        // If this is a JAR label, add it to the result
        if (isJarLabel(node)) {
            jarLabels.add(node);
        }
        
        // Continue traversing to find all reachable JAR labels
        Set<String> neighbors = dependencyGraph.get(node);
        if (neighbors != null) {
            for (String neighbor : neighbors) {
                findReachableJarLabels(neighbor, jarLabels, visited);
            }
        }
    }
} 