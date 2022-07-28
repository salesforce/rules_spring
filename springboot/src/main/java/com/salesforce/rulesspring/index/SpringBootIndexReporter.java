package com.salesforce.rulesspring.index;

import java.util.Comparator;
import java.util.List;

/**
 * Generates the text report with the results of an indexing operation.
 * This class is pretty simple, so the code serves as the documentation.
 * <p>
 * To see what options are implemented, see parseOptions() below.
 */
public class SpringBootIndexReporter {
    
    protected boolean includeLibs = true;
    protected boolean includeClasses = true;
    protected boolean includeResources = true;
    
    protected boolean prettyHeadings = true;
    
    protected boolean writeFullPaths = false;
    protected boolean writeFileSize = false;
    protected boolean writeCreatedTime = false;
    protected boolean writeModifiedTime = false;
    
    protected boolean sortOnFullPaths = false;
    
    public SpringBootIndexReporter() {
        
    }

    public String generateReport(IndexOfFiles index) {
        return this.generateReport(index, null);
    }

    public String generateReport(IndexOfFiles index, String options) {
        StringBuffer result = new StringBuffer();
        parseOptions(options);
        
        Comparator<IndexedFile> sortOrder = new IndexedFile.FilenameComparator();
        if (sortOnFullPaths) {
            sortOrder = new IndexedFile.FullPathComparator();
        }
        
        if (prettyHeadings) {
            result.append("Jar File: ");
            result.append(index.getJarPath());
            result.append("\n");
        }
        
        if (includeLibs) {
            index.libraries.sort(sortOrder);
            processList(index.libraries, "Libraries", result);
        }

        if (includeClasses) {
            index.classes.sort(sortOrder);
            processList(index.classes, "Classes", result);
        }

        if (includeResources) {
            index.resources.sort(sortOrder);
            processList(index.resources, "Resources", result);
        }

        return result.toString();
    }
    
    protected void parseOptions(String options) {
        if (options == null) {
            return;
        }
        includeLibs = options.contains("L"); // write the list of .jar files found
        includeClasses = options.contains("C"); // write the list of  .class files found
        includeResources = options.contains("R"); // write the list of other files found
        prettyHeadings = options.contains("H"); // write pretty headings into the output
        writeFullPaths = options.contains("F"); // write full paths of each entry
        writeFileSize = options.contains("Z"); // write the file size of each file
        writeCreatedTime = options.contains("B"); // write the created time of each file
        writeModifiedTime = options.contains("M"); // write the modified time of each file
        sortOnFullPaths = options.contains("S"); // when sorting, sort on the path and not the filename
    }
    
    protected void processList(List<IndexedFile> list, String headingLabel, StringBuffer result) {
        if (prettyHeadings) {
            result.append("\n\n");
            result.append(headingLabel);
            result.append("\n---------------\n");
        }
        for (IndexedFile lib : list) {
            if (writeFullPaths) {
                result.append(lib.fullPath);
            } else {
                result.append(lib.filename);
            }
            if (writeFileSize) {
                result.append("  size=");
                result.append(""+lib.sizeInBytes);
            }
            if (writeCreatedTime) {
                result.append("  created=");
                result.append(""+lib.createdTimeMillis);
            }
            if (writeModifiedTime) {
                result.append("  modified=");
                result.append(""+lib.modifiedTimeMillis);
            }
            result.append("\n");
        }
    }
}
