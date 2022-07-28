package com.salesforce.rulesspring.index;

import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * Produces an index from the contents of a Spring Boot jar.
 */
public class SpringBootJarIndexer {

    protected File bootJarFile;
    
    public SpringBootJarIndexer(File jarFile) {
        this.bootJarFile = jarFile;
    }

    /**
     * Index the contents of the Spring Boot jar.
     * 
     * @param recursive if true, it will produce child indices of each nested jar inside the Spring Boot executable jar.
     */
    public IndexOfFiles indexJar(boolean recursive) throws IOException {
        IndexOfFiles index = new IndexOfFiles(bootJarFile.getAbsolutePath());
        try (ZipFile zipFile = new ZipFile(this.bootJarFile)) {
            
            Enumeration<? extends ZipEntry> entries = zipFile.entries();
            for (ZipEntry entry : Collections.list(entries)) {
                if (entry.isDirectory()) {
                    continue;
                }
                IndexedFile indexEntry = IndexedFile.parseZipEntry(null, entry);
                index.addIndexEntry(indexEntry);
                
                if (recursive && indexEntry.type.equals(IndexFileType.LIBRARY)) {
                    // TODO do the nested indexing
                    indexJar(indexEntry, entry);
                }
            }
        } 
        return index;
    }

    /**
     * Create a child index for a nested jar.
     */
    protected IndexOfFiles indexJar(IndexedFile parentLibrary, ZipEntry nestedJar) throws IOException {
        
        // TODO this needs to be reworked to open the jar from the ZipEntry
        
        IndexOfFiles index = new IndexOfFiles(bootJarFile.getAbsolutePath());
        try (ZipFile zipFile = new ZipFile(this.bootJarFile)) {
            
            Enumeration<? extends ZipEntry> entries = zipFile.entries();
            for (ZipEntry entry : Collections.list(entries)) {
                if (entry.isDirectory()) {
                    continue;
                }
                IndexedFile indexEntry = IndexedFile.parseZipEntry(parentLibrary, entry);
                index.addIndexEntry(indexEntry);
            }
        } 
        return index;
    }
}
