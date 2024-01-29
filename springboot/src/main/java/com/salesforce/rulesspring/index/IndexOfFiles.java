package com.salesforce.rulesspring.index;

import java.util.ArrayList;
import java.util.List;

/**
 * The index generated from inspecting a jar file.
 */
public class IndexOfFiles {
    
    // We have two types of index objects:
    // 1. index of the files directly inside the spring boot executable jar
    // 2. index of the contents of a jar file inside the spring boot executable jar (aka nested jar)
    protected boolean isNestedJarIndex = false;

    // either the path on disk to the executable jar (if this is an index of a spring boot jar),
    // or the relative path of the nested jar file inside the spring boot jar file
    protected String jarPath;
    
    // if this is an index of a jar file inside the executable jar (nested jar) this will point to the 
    // spring boot executable jar index
    protected IndexedFile parentIndex;
    
    // The lists of found files:
    protected List<IndexedFile> libraries = new ArrayList<>();
    protected List<IndexedFile> classes = new ArrayList<>();
    protected List<IndexedFile> resources = new ArrayList<>();
    
    public IndexOfFiles(String jarPath) {
        this.jarPath = jarPath;
    }

    public IndexOfFiles(IndexedFile parentIndex, String jarPath) {
        this.parentIndex = parentIndex;
        this.isNestedJarIndex = true;
        this.jarPath = jarPath;
    }

    public void addIndexEntry(IndexedFile indexEntry) {
        switch (indexEntry.type) {
        case LIBRARY:
            libraries.add(indexEntry);
            break;
        case CLASS:
            classes.add(indexEntry);
            break;
        case RESOURCE:
            resources.add(indexEntry);
            break;
        default:
            throw new IllegalStateException("Somebody added a new Index entry type, but forgot to build an index collection for it.");
        }
        
    }

    public String getJarPath() {
        return jarPath;
    }
    
    public IndexedFile getParentIndex() {
        return parentIndex;
    }
    
    public List<IndexedFile> getLibraries() {
        return libraries;
    }

    public List<IndexedFile> getClasses() {
        return classes;
    }

    public List<IndexedFile> getResources() {
        return resources;
    }
}
