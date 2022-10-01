package com.salesforce.rulesspring.cli;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;

import com.salesforce.rulesspring.index.SpringBootIndexReporter;
import com.salesforce.rulesspring.index.IndexOfFiles;
import com.salesforce.rulesspring.index.SpringBootJarIndexer;

public class SpringBootInspector {

    public static void main(String[] args) throws Exception {
        if (args.length < 3) {
            System.out.println("ERROR: this tool needs at least 3 arguments");
            usage();
            return;
        }

        Command cmd = parseArgs(args);
        if (cmd == null) {
            // command line was invalid, and reason was already logged, just exit
            return;
        }

        if ("inspector".equals(cmd.mode)) {
            File jarFile = new File(cmd.jarFilepath);
            if (!jarFile.exists()) {
                System.err.println("ERROR: File "+cmd.jarFilepath+" does not exist.");
                return;
            }
            System.out.println("Spring Boot Jar absolute path: "+jarFile.getAbsolutePath());

            if ("index".equals(cmd.operation)) {
                File indexFile = new File(cmd.outputPath);
                if (indexFile.exists()) {
                    System.err.println("ERROR: File "+indexFile.getAbsolutePath()+" already exists and we don't overwrite files.");
                    return;
                }
                System.out.println("Index output file absolute path: "+indexFile.getAbsolutePath());


                SpringBootJarIndexer indexer = new SpringBootJarIndexer(jarFile);
                IndexOfFiles index = indexer.indexJar(cmd.recursive);

                SpringBootIndexReporter reporter = new SpringBootIndexReporter();
                String report = reporter.generateReport(index, cmd.reportOptions);

                BufferedWriter writer = new BufferedWriter(new FileWriter(indexFile));
                writer.write(report);
                writer.close();

                System.out.println("Wrote index file as "+cmd.outputPath);
            } else {
                System.err.println("Operation "+cmd.operation+" is not implemented.");
            }
        }
    }

    protected static void usage() {
        System.out.println("Spring Boot Jar Inspector");
        System.out.println("Usage:");
        System.out.println("  java -jar springboot-cli.jar MODE OPERATION [operation specific args]");
        System.out.println("    MODE: 'inspector' for running operations on a single Spring Boot jar; 'comparator' when running operations with multiple Spring Boot jars");
        System.out.println("    OPERATION: a keyword that activates a particular operation; operations are documented below");
        System.out.println("\n");

        System.out.println("INSPECTOR OPERATIONS:");
        System.out.println("\n");
        System.out.println(" index: generates an index of files within the Spring Boot jar.");
        System.out.println("   java -jar springboot-cli.jar inspect index SPRING-BOOT-JAR-PATH INDEX-REPORT-PATH [--recursive] [--report REPORT-OPTIONS]");
        System.out.println("     SPRING-BOOT-JAR-PATH: path to your Spring Boot executable jar file; it must exist");
        System.out.println("     INDEX-REPORT-PATH: path to write the report from this tool; it must not already exist");
        System.out.println("     --recursive: if present, inspector will also index the contents of the nested jars found inside the Spring Boot jar");
        System.out.println("     REPORT-OPTIONS: optional list of modifiers to the reporting engine; see docs for details");
    }

    protected static Command parseArgs(String[] args) {
        // TODO this is pretty awkward but keeping it simple for now

        Command cmd = new Command();
        cmd.mode = args[0];
        cmd.operation = args[1];
        System.out.println("Mode: "+cmd.mode);
        System.out.println("Operation: "+cmd.operation);

        int optionalArgIndex = 2;
        if ("inspector".equals(cmd.mode)) {
            if ("index".equals(cmd.operation)) {
                if (args.length < 4) {
                    System.out.println("ERROR: Not enough arguments for the index command.");
                    usage();
                    return null;
                }
                cmd.jarFilepath = args[2];
                cmd.outputPath = args[3];
                System.out.println("Spring Boot Jar: "+cmd.jarFilepath);
                System.out.println("Index output file: "+cmd.outputPath);
                optionalArgIndex = 4;
            }
        }
        parseOptionalArgs(args, optionalArgIndex, cmd);
        return cmd;
    }

    protected static void parseOptionalArgs(String[] args, int index, Command cmd) {
        for (int i = index; i<args.length; i++) {
            if ("--recursive".equals(args[i])) {
                cmd.recursive = true;
                System.out.println("Recursive: true");
            } else if ("--report".equals(args[i])) {
                cmd.reportOptions = args[i+1];
                i++;
                System.out.println("Report options: "+cmd.reportOptions);
            } else {
                System.err.println("Unrecognized parameter "+args[i]+ ". Ignoring.");
            }
        }

    }

    public static class Command {
        // General args
        public String mode;
        public String operation;
        public String jarFilepath;
        public String outputPath;

        // inspector:index args
        public boolean recursive = false;
        public String reportOptions = null;
    }

}
