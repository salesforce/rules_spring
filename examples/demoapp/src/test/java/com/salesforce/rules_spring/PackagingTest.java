/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
*/
package com.salesforce.rules_spring;

import org.junit.Before;
import org.junit.Test;

import java.io.File;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import static org.junit.Assert.*;

/**
 */
public class PackagingTest {

    File springbootJarFile = null;

    // file contents
    String gitPropertiesContents = null;
    String buildPropertiesContents = null;
    String applicationPropertiesContents = null;

    // file existence
    boolean exists_lib1 = false;
    boolean exists_lib2 = false;
    boolean exists_lib3_neverlink = false;

    @Before
    public void setup() throws Exception {
        springbootJarFile = new File("./examples/demoapp/demoapp.jar");
        if (!springbootJarFile.exists()) {
            throw new IllegalStateException("Missing demoapp springboot jar; looked in path: " +
                    springbootJarFile.getAbsolutePath());
        }
        extractFilesFromSpringBootJar();
    }

    @Test
    public void gitPropertiesFileTest() {
        assertNotNull(gitPropertiesContents);
        assertTrue(gitPropertiesContents.contains("git.commit"));
    }

    @Test
    public void buildPropertiesFileTest() {
        assertNotNull(buildPropertiesContents);
        assertTrue(buildPropertiesContents.contains("build.number"));
    }

    @Test
    public void applicationPropertiesFileTest() {
        assertNotNull(applicationPropertiesContents);
        assertTrue(applicationPropertiesContents.contains("demoapp.config.internal"));
    }

    @Test
    public void internalLibsAreIncludedTest() {
        assertTrue(this.exists_lib1);
        assertTrue(this.exists_lib2);
    }

    @Test
    public void neverlinkLibsAreExcludedTest() {
        assertFalse(this.exists_lib3_neverlink);
    }

    private void extractFilesFromSpringBootJar() throws Exception {
        try (ZipFile sbZip = new ZipFile(springbootJarFile)) {
            Enumeration<? extends ZipEntry> entries = sbZip.entries();
            for (Iterator<? extends ZipEntry> it = entries.asIterator(); it.hasNext(); ) {
                ZipEntry entry = it.next();
                String name = entry.getName();
                System.out.println("  zipentry: "+name);
                if (name.equals("BOOT-INF/classes/git.properties")) {
                    InputStream is = sbZip.getInputStream(entry);
                    gitPropertiesContents = new String(is.readAllBytes(), StandardCharsets.UTF_8);
                } else if (name.equals("BOOT-INF/classes/META-INF/build-info.properties")) {
                    InputStream is = sbZip.getInputStream(entry);
                    buildPropertiesContents = new String(is.readAllBytes(), StandardCharsets.UTF_8);
                } else if (name.equals("BOOT-INF/classes/application.properties")) {
                    InputStream is = sbZip.getInputStream(entry);
                    applicationPropertiesContents = new String(is.readAllBytes(), StandardCharsets.UTF_8);
                } else if (name.equals("BOOT-INF/lib/examples/demoapp/libs/lib1/liblib1.jar")) {
                    exists_lib1 = true;
                } else if (name.equals("BOOT-INF/lib/examples/demoapp/libs/lib2/liblib2.jar")) {
                    exists_lib2 = true;
                } else if (name.contains("neverlink")) {
                    // we have a lib named lib3_neverlink that has neverlink = True, which means it should NOT be
                    // included in the springboot jar
                    exists_lib3_neverlink = true;
                }
            }
        }
    }
}
