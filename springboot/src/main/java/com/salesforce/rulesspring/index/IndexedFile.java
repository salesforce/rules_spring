package com.salesforce.rulesspring.index;

import java.nio.file.attribute.FileTime;
import java.util.Comparator;
import java.util.zip.ZipEntry;

/**
 * Represents a file found inside of a jar file.
 */
public class IndexedFile {
    // library (jar), class, or resource file
    protected IndexFileType type;
    
    // full path inside of the jar file
    protected String fullPath;
    
    // the filename, i.e. the last path element of the fullPath
    protected String filename;
    
    protected long sizeInBytes = 0;
    protected long createdTimeMillis = 0;
    protected long modifiedTimeMillis = 0;

    // if this index entry is for a file found in a nested jar inside of an outer jar, parentLibrary will
    // point to the index of the parent jar
    protected IndexedFile parentLibrary = null; 

    static IndexedFile parseZipEntry(IndexedFile parentLibrary, ZipEntry zipEntry) {
        IndexedFile indexEntry = new IndexedFile();
        indexEntry.fullPath = zipEntry.getName();
        indexEntry.filename = indexEntry.fullPath;
        
        String fp = indexEntry.fullPath;
        if (fp.contains("/")) {
            int lastSlash = fp.lastIndexOf("/");
            indexEntry.filename = fp.substring(lastSlash+1);
        }
        
        if (fp.contains("BOOT-INF/lib") && fp.endsWith(".jar")) {
            indexEntry.type = IndexFileType.LIBRARY;
        }
        else if (fp.endsWith(".class")) {
            indexEntry.type = IndexFileType.CLASS;
        } else { 
            indexEntry.type = IndexFileType.RESOURCE;
        }
        
        indexEntry.sizeInBytes = zipEntry.getSize();
        FileTime fTime = zipEntry.getCreationTime();
        if (fTime != null) {
            indexEntry.createdTimeMillis = fTime.toMillis();
        }
        fTime = zipEntry.getLastModifiedTime();
        if (fTime != null) {
            indexEntry.modifiedTimeMillis = fTime.toMillis();
        }

        return indexEntry;
    }
    
    public static class FullPathComparator implements Comparator<IndexedFile> {
        @Override
        public int compare(IndexedFile e1, IndexedFile e2) {
            return e1.fullPath.compareTo(e2.fullPath); 
        }
    }

    public static class FilenameComparator implements Comparator<IndexedFile> {
        @Override
        public int compare(IndexedFile e1, IndexedFile e2) {
            return e1.filename.compareTo(e2.filename); 
        }
    }
}
