package com.salesforce.bazel.springboot;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import net.lingala.zip4j.ZipFile;
import net.lingala.zip4j.model.FileHeader;

/**
 * Packages the application using the validated attributes on the springboot rule.
 */
public class SpringBootRulePackager {

	protected SpringBootRuleArgs args;
	protected List<String> packagingErrors;
	
	public SpringBootRulePackager(SpringBootRuleArgs args) {
		this.args = args;
	}
	
	/*
	 * Test cases:
	 * - sandboxed vs non-sandboxed builds
	 * - parallel builds of multiple spring boot apps
	 * - test using jdk8 and 11 as the javabase
	 */
	
	
	public void packageApplication() throws Exception {
		if (args.validationErrors != null) {
			// if there are arg validation issues, the execution should have failed before now, but just in case...
			throw new IllegalStateException("Cannot package the application. There are validation errors for the arguments.");
		}
		long startTime = System.currentTimeMillis();
		// create an execution id that is used in some temporary file locations
		String ruleExecutionId = ""+args.appJarFilePath.hashCode();

		// Load file paths from args
		File packageDir = findFileAndVerifyExists(args.packageWorkingDirPath);
		File appLibFile = findFileAndVerifyExists(args.appJarFilePath);

		
		// Setup working directories. Working directory is unique to this package path (uses hashcode of path)
		// to tolerate non-sandboxed builds if so configured.
		File workingBaseDir = new File(packageDir, ""+ruleExecutionId);
		File workingDir = new File(workingBaseDir, "working");
		File bootinfLibDir = new File(workingDir, "BOOT-INF/lib");
		File bootinfClassesDir = new File(workingDir, "BOOT-INF/classes");
		bootinfLibDir.mkdirs();
		bootinfClassesDir.mkdirs();
		
		// TODO determine if debugging is enabled
		// TODO create a debugdir and start debug log if debug enabled, write debug header to log, write list of dep jars to log
		System.out.println("DEBUG: rule execution identifier: "+ruleExecutionId);
		
		// compute absolute path to jar command $JAVABASE/bin
		File jdkHomeDir =  findFileAndVerifyExists(args.jdkPath);
		File jdkBinDir = findFileAndVerifyExists(jdkHomeDir, "bin");
		File jarCommand = findFileAndVerifyExists(jdkBinDir, "jar"); // DONT NEED THIS, USING Zip4j ZIPFILE
		
		// Extract the compiled APP JAR application classes into BOOT-INF/classes
		// TODO cd $WORKING_DIR/BOOT-INF/classes
		// $JAR_COMMAND -xf $RULEDIR/$APPJAR
		ZipFile appJarZip = new ZipFile(appLibFile);
		appJarZip.extractAll(bootinfClassesDir.getAbsolutePath());
		
		// Iterate over all deps
		// libname=$(basename $lib)
		// if libname == *spring-boot-loader* {
	    //   if libname contains the string 'spring-boot-loader' then...
	    //   the Spring Boot Loader classes are special, they must be extracted at the root level /,
	    //   not in BOOT-INF/lib/loader.jar nor BOOT-INF/classes/**/*.class
	    //   we only extract org/* since we don't want the toplevel META-INF files
	    //   TODO $JAR_COMMAND xf $RULEDIR/$lib org
		// } else {
		/*
		      # copy the jar into BOOT-INF/lib, being mindful to prevent name collisions by using subdirectories (see Issue #61)
		      # the logic to truncate paths below doesnt need to be perfect, it just hopes to simplify the jar paths so they look better for most cases
		      # for maven_install deps, the algorithm to correctly identify the end of the server path and the groupId is not defined
		      #
		      # a note on duplicate artifacts:
		      # if the same dep (same gav) is brought in multiple times by different
		      # maven_install rules, we do not end up with multiple copies of the same
		      # jar. our logic handles this case because of how we truncate the paths
		      # below: both (identical) jars will get copied into the same location,
		      # the 2nd one overwriting the first one, and therefore we end of with
		      # only a single jar in the final assembly, as desired
		      # example: 2 maven_install rules bring in spring-boot-starter-jetty:
		      # "maven" rule: external/maven/v1/https/repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-jetty/2.4.1/spring-boot-starter-jetty-2.4.1.jar
		      # "spring_boot_starter_jetty" rule: external/spring_boot_starter_jetty/v1/https/repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-jetty/2.4.1/spring-boot-starter-jetty-2.4.1.jar
		      # the relative destpath we compute below starts after "maven2"
		      #
		      # related to above, a note on duplicate jar entries:
		      # if the jar cmd is called with the same path more than once, for example:
		      # jar -cf foo.jar a/b/c.txt d/e/f.txt a/b/c.txt, the first path "wins",
		      # subsequent duplicate paths are ignored. so for the example above, the
		      # jar will have entries: a/b/c.txt, d/e/f.txt
		      # this "first one wins" behavior is also what we want when duplicate
		      # dependencies are encountered
		 */
		/*
		       if [[ ${libdir} == *external*maven2* ]]; then
		        # this is a maven_install jar probably from maven central
		        # libdir:      bazel-out/darwin-fastbuild/bin/external/maven/v1/https/repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-logging/2.2.1.RELEASE/spring-boot-starter-logging-2.2.1.RELEASE.jar
		        # libdestdir:  BOOT-INF/lib/org/springframework/boot/spring-boot-starter-logging/2.2.1.RELEASE/spring-boot-starter-logging-2.2.1.RELEASE.jar
		        libdestdir="BOOT-INF/lib/${libdir#*maven2}"
		      elif [[ ${libdir} == *external*public* ]]; then
		        # this is a maven_install jar probably from Sonatype Nexus
		        # libdir:      bazel-out/darwin-fastbuild/bin/external/maven/v1/https/ournexus.acme.com/nexus/content/groups/public/org/springframework/boot/spring-boot-starter-logging/2.2.1.RELEASE/spring-boot-starter-logging-2.2.1.RELEASE.jar
		        # libdestdir:  BOOT-INF/lib/org/springframework/boot/spring-boot-starter-logging/2.2.1.RELEASE/spring-boot-starter-logging-2.2.1.RELEASE.jar
		        libdestdir="BOOT-INF/lib/${libdir#*public}"
		      elif [[ ${libdir} == bazel-out* ]]; then
		        # this is an internally built jar from the workspace, use the Bazel package name as the path to prevent name collisions
		        # libdir:      bazel-out/darwin-fastbuild/bin/projects/libs/acme/blue_lib/liblue_lib.jar
		        # libdestdir:  BOOT-INF/lib/projects/libs/acme/blue_lib/liblue_lib.jar
		        libdestdir="BOOT-INF/lib/${libdir#*bin}"
		      else
		        # something else, just copy into BOOT-INF/lib using the full path as it exists
		        # this works fine, but you will see some Bazel internal output dirs as part of the path in the jar
		        libdestdir="BOOT-INF/lib/${libdir}"
		      fi
		      mkdir -p ${libdestdir}
		      libdestpath=${libdestdir}/$libname
		      BOOT_INF_LIB_JARS="${BOOT_INF_LIB_JARS} ${libdestpath}"
		      cp -f $RULEDIR/$lib $libdestpath

		 */
		
		long elapsedTime = System.currentTimeMillis() - startTime;
		// TODO debug log the elapsed time
		// echo "DEBUG: finished copying transitives into BOOT-INF/lib, elapsed time (seconds): $ELAPSED_TRANS" >> $DEBUGFILE

		// Inject the Git properties into a properties file in the jar
		// (the -f is needed when remote caching is used, as cached files come down as r-x and
		// if you rerun the build it needs to overwrite)
		// TODO echo "DEBUG: adding git.properties" >> $DEBUGFILE
		// cat $RULEDIR/$GITPROPSFILE >> $DEBUGFILE
		// cp -f $RULEDIR/$GITPROPSFILE $WORKING_DIR/BOOT-INF/classes

		// Inject the classpath index (unless it is the default empty.txt file). Requires Spring Boot version 2.3+ to take effect.
		// https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-executable-jar-format.html#executable-jar-war-index-files-classpath
		// TODO if [[ ! $CLASSPATH_INDEX = *empty.txt ]]; then
		//   cp $RULEDIR/$CLASSPATH_INDEX $WORKING_DIR/BOOT-INF/classpath.idx
		// fi
		

		// TODO JAR UP THE WHOLE THING
		// First use jar to create a correct jar file for Spring Boot
		// Note that a critical part of this step is to pass option 0 into the jar command
		// that tells jar not to compress the jar, only package it. Spring Boot does not
		// allow the jar file to be compressed (it will fail at startup).
		// The current working directory now has exactly the structure we want to jar up
		// HOWEVER, instead of running jar just once, we run jar multiple times to ensure
		// that the jar entries are added in the required order to the jar:
		// Spring Boot Loader -> BOOT-INF/classes -> BOOT-INF/lib
		// A different order can create confusing classpath ordering issues when
		// the uber jar is executed using java -jar

		// TODO RAW_OUTPUT=$RULEDIR/${OUTPUTJAR}.raw
		// echo "DEBUG: Running jar command to produce $RAW_OUTPUT" >> $DEBUGFILE

		
		// Use Bazel's singlejar to re-jar it which normalizes timestamps as Jan 1 2010
		// note that it does not use the MANIFEST from the jar file, which is a bummer
		// so we have to respecify the manifest data
		// TODO we should rewrite write_manfiest.sh to produce inputs compatible for singlejar (Issue #27)
		//SINGLEJAR_OPTIONS="--normalize --dont_change_compression" # add in --verbose for more details from command
		//SINGLEJAR_MAINCLASS="--main_class org.springframework.boot.loader.JarLauncher"
		//$SINGLEJAR_CMD $SINGLEJAR_OPTIONS $SINGLEJAR_MAINCLASS \
		  //  --deploy_manifest_lines "Start-Class: $MAINCLASS" \
		    //--sources $RAW_OUTPUT \
		    //--output $RULEDIR/$OUTPUTJAR 2>&1 | tee -a $DEBUGFILE

		
	}
	
	// HELPERS
	
	protected void addError(String error) {
		if (packagingErrors == null) {
			packagingErrors = new ArrayList<>();
		}
		packagingErrors.add(error);
	}
	
	private File findFileAndVerifyExists(String path) {
		File file = new File(path);
		if (!file.exists()) {
			throw new IllegalStateException("File ["+path+"] does not exist. There is a bug in Spring Boot rule.");
		}
		return file;
	}

	private File findFileAndVerifyExists(File parent, String path) {
		File file = new File(parent, path);
		if (!file.exists()) {
			throw new IllegalStateException("File ["+parent.getAbsolutePath()+File.separatorChar+path+"] does not exist. There is a bug in Spring Boot rule.");
		}
		return file;
	}
}
