package com.salesforce.bazel.springboot;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/*
  PKGDIR          /private/var/tmp/_bazel_user/7c9d9/sandbox/darwin-sandbox/334/execroot/bazel_springboot_rule     (build working directory)
  SINGLEJAR       /private/var/tmp/_bazel_user/7c9d9/sandbox/darwin-sandbox/334/execroot/bazel_springboot_rule/external/remote_java_tools_darwin/java_tools/src/tools/singlejar/singlejar_local (path to the singlejar utility)
  MAINCLASS       com.sample.SampleMain   (classname of the @SpringBootApplication class for the MANIFEST.MF file entry)
  OUTPUTJAR       bazel-out/darwin-fastbuild/bin/samples/helloworld/helloworld.jar   (the executable JAR that will be built from this rule)
  JAVABASE        external/remotejdk11_macos    (the path to the JDK2)
  APPJAR          bazel-out/darwin-fastbuild/bin/samples/helloworld/libhelloworld_lib.jar      (contains the .class files for the Spring Boot application)
  APPJAR_NAME     helloworld (unused, is the appjar filename without the .jar extension)
  MANIFEST        bazel-out/darwin-fastbuild/bin/samples/helloworld/MANIFEST.MF    (the location of the generated MANIFEST.MF file)
  CLASSPATH_INDEX samples/helloworld/helloworld_classpath.idx (the location of the classpath index file - optional)
  DEPLIBS
 */

/**
 * Command line args parsing code. This could be made easier with an open source library
 * (e.g. commons-cli) but I dont want to drag a dep tree into the springboot rule implementation.
 * So this is just a bare bones CLI processor for our needs.
 * Actually, we now drag in zip4j so we could also add a cli lib, but this code is already written
 * so we will just go with it.
 */
public class SpringBootRuleArgs {
	
	public static final String ARG_WORKING_PATH = "workingdir";
	public static final String ARG_SINGLEJAR = "singlejar";
	public static final String ARG_MAINCLASS = "mainclass";
	public static final String ARG_OUTPUTJAR = "outputjar";
	public static final String ARG_JDKPATH = "jdk";
	public static final String ARG_APPLIBPATH = "appjar";
	public static final String ARG_APPLIBNAME = "name";
	public static final String ARG_MANIFESTPATH = "manifest";
	public static final String ARG_GITPROPS = "gitprops";
	public static final String ARG_CPINDEXPATH = "classpathindex";
	public static final String ARG_DEPS = "dependencies";
	
	protected static Set<String> ARG_KEYS = new HashSet<>();
	static {
		ARG_KEYS.add(ARG_WORKING_PATH);
		ARG_KEYS.add(ARG_SINGLEJAR);
		ARG_KEYS.add(ARG_MAINCLASS);
		ARG_KEYS.add(ARG_OUTPUTJAR);
		ARG_KEYS.add(ARG_JDKPATH);
		ARG_KEYS.add(ARG_APPLIBPATH);
		ARG_KEYS.add(ARG_APPLIBNAME);
		ARG_KEYS.add(ARG_MANIFESTPATH);
		ARG_KEYS.add(ARG_GITPROPS);
		ARG_KEYS.add(ARG_CPINDEXPATH);
		ARG_KEYS.add(ARG_DEPS);
	}
	
	protected final String[] rawArgs;
	
	protected String packageWorkingDirPath;
	protected String singleJarExecPath;
	protected String mainClassName;
	protected String outputJarFilePath;
	protected String jdkPath;
	protected String appJarFilePath;
	protected String appJarName;
	protected String manifestFilePath;
	protected String gitpropertiesFilePath;
	protected String classpathIndexFilePath;
	protected List<String> dependencyLibNames;

	/**
	 * List of detected errors in the command line. We want to report all issues so users don't have to
	 * do repeated tries to find all of their errors.
	 */
	protected List<String> validationErrors;

	// test only
	public SpringBootRuleArgs() {
		rawArgs = new String[] {};
	}

	public SpringBootRuleArgs(String[] args) {
		rawArgs = args;
	}
		
	/**
	 * Parses the command line (either style, positional or named args) and loads the values
	 * into the member variables. Also sanity checks the values as much as possible to make 
	 * sure we are getting usable data.
	 * 
	 * @return true if the parsing was successful, false if not
	 */
	public boolean parseAndValidateCommandLine() {
		String firstArg = rawArgs[0];
		if (firstArg.startsWith("--")) {
			// using named args
			parseAndValidateNamedCommandLine();
		} else {
			// using positional scheme
			parseAndValidatePositionalCommandLine();
		}

		if (validationErrors != null) {
			return false;
		}
		if (!hasAllRequiredArgs()) {
			return false;
		}
		
		return true;
	}
	
	// PARSERS

	protected void parseAndValidateNamedCommandLine() {
		
		for (int i=0; i<rawArgs.length; i++) {
			String arg = rawArgs[i];
			
			if (arg.startsWith("--")) {
				String key = arg.substring(2);
				if (ARG_KEYS.contains(key)) {
					// now make sure we have a value, all args require a value
					int valueIndex = i+1;
					if (valueIndex < rawArgs.length) {
						i++;
						String value = rawArgs[valueIndex];
						if (ARG_WORKING_PATH.equals(key)) {
							setPackageWorkingDirPath(value, "arg "+valueIndex+1);
						} else if (ARG_SINGLEJAR.equals(key)) {
							setSingleJarPath(value, "arg "+valueIndex+1);
						} else if (ARG_MAINCLASS.equals(key)) {
							setMainClassName(value, "arg "+valueIndex+1);
						} else if (ARG_OUTPUTJAR.equals(key)) {
							setOutputJarFilePath(value, "arg "+valueIndex+1);
						} else if (ARG_JDKPATH.equals(key)) {
							setJdkFilePath(value, "arg "+valueIndex+1);
						} else if (ARG_APPLIBPATH.equals(key)) {
							setAppJarFilePath(value, "arg "+valueIndex+1);
						} else if (ARG_APPLIBNAME.equals(key)) {
							setAppJarName(value, "arg "+valueIndex+1);
						} else if (ARG_MANIFESTPATH.equals(key)) {
							setManifestFilePath(value, "arg "+valueIndex+1);
						} else if (ARG_GITPROPS.equals(key)) {
							setGitPropertiesFilePath(value, "arg "+valueIndex+1);
						} else if (ARG_CPINDEXPATH.equals(key)) {
							setClasspathIndexFilePath(value, "arg "+valueIndex+1);
						} else if (ARG_DEPS.equals(key)) {
							// this one gets handled a little differently, because there are
							// N number of deps separated by a space. The index returned from
							// this method is the last index processed so we set i from that
							i = setDependencyLibNames(rawArgs, valueIndex);
						}
					} else {
						addError("Missing a value for final arg ["+id("arg "+(i+1), arg)+"] in command line.");
					}
				} else {
					addError("Unknown argument name ["+id("arg "+(i+1), arg)+"] in command line.");
				}
			} else {
				addError("Unexpected token ["+id("arg "+(i+1), arg)+"] in command line.");
			}
			
		}
		
	}

	protected void parseAndValidatePositionalCommandLine() {
		setPackageWorkingDirPath(rawArgs[0], "arg 1");
		setSingleJarPath(rawArgs[1], "arg 2");
		setMainClassName(rawArgs[2], "arg 3");
		setJdkFilePath(rawArgs[3], "arg 4");
		setAppJarName(rawArgs[4], "arg 5");
		setOutputJarFilePath(rawArgs[5], "arg 6");
		setAppJarFilePath(rawArgs[6], "arg 7");
		setManifestFilePath(rawArgs[7], "arg 8");
		setGitPropertiesFilePath(rawArgs[8], "arg 9");
		setClasspathIndexFilePath(rawArgs[9], "arg 10");
		setDependencyLibNames(rawArgs, 10);
	}
	
	
	// ARG SETTERS
	
	// Ex: /private/var/tmp/_bazel_user/7c9d9/sandbox/darwin-sandbox/334/execroot/bazel_springboot_rule     (build working directory)
	protected void setPackageWorkingDirPath(String arg, String source) {
		this.packageWorkingDirPath = arg;
	}
	
	// Ex: /private/var/tmp/_bazel_user/7c9d9/sandbox/darwin-sandbox/334/execroot/bazel_springboot_rule/external/remote_java_tools_darwin/java_tools/src/tools/singlejar/singlejar_local
	protected void setSingleJarPath(String arg, String source) {
		this.singleJarExecPath = arg;
		if (!this.singleJarExecPath.contains("singlejar")) {
			addError("Command line argument ["+id(source, arg)+"] should be a path to the 'singlejar' executable, was: "+singleJarExecPath);
		}
	}
	
	// Ex: com.sample.SampleMain
	protected void setMainClassName(String arg, String source) {
		this.mainClassName = arg;
		if (this.mainClassName.contains("/") || this.mainClassName.contains("\\")) {
			// a common mistake is to put the filepath to the main class:  com/acme/SampleMainClass
			addError("Command line arg ["+id(source, arg)+"] should be of the form com.acme.SampleMainClass, not a file system path.");
		}
		if (this.mainClassName.endsWith(".java")) {
			// we don't want .java on the end:  com.acme.SampleMainClass.java
			addError("Command line arg ["+id(source, arg)+"] should be of the form [com.acme.SampleMainClass] with no .java suffix");
		}
		if (this.mainClassName.endsWith(".class")) {
			// we don't want .class on the end:  com.acme.SampleMainClass.class
			addError("Command line arg ["+id(source, arg)+"] should be of the form [com.acme.SampleMainClass] with no .class suffix.");
		}
	}
	
	// Ex: bazel-out/darwin-fastbuild/bin/samples/helloworld/helloworld.jar
	protected void setOutputJarFilePath(String arg, String source) {
		this.outputJarFilePath = arg;
		if (!this.outputJarFilePath.contains("bazel-out")) {
			addError("Command line arg ["+id(source, arg)+"] should be the output jar path in the bazel-out tree of directories.");
		}
		if (!this.outputJarFilePath.endsWith(".jar")) {
			addError("Command line arg ["+id(source, arg)+"] should be the output jar file path (ends with .jar).");
		}
		
	}
	
	// Ex: external/remotejdk11_macos  (which is a relative path under the execution root dir)
	protected void setJdkFilePath(String arg, String source) {
		this.jdkPath = arg;
	}
	
	// Ex: bazel-out/darwin-fastbuild/bin/samples/helloworld/libhelloworld_lib.jar
	protected void setAppJarFilePath(String arg, String source) {
		this.appJarFilePath = arg;
		if (!this.appJarFilePath.contains("bazel-out")) {
			addError("Command line arg ["+id(source, arg)+"] should be the application jar path in the bazel-out tree of directories.");
		}
		if (!this.appJarFilePath.endsWith(".jar")) {
			addError("Command line arg ["+id(source, arg)+"] should be the application jar file path (ends with .jar).");
		}		
	}
	
	// Ex: helloworld
	protected void setAppJarName(String arg, String source) {
		this.appJarName = arg;
	}
	
	// Ex: bazel-out/darwin-fastbuild/bin/samples/helloworld/MANIFEST.MF 
	protected void setManifestFilePath(String arg, String source) {
		this.manifestFilePath = arg;
		if (!this.manifestFilePath.contains("bazel-out")) {
			addError("Command line arg ["+id(source, arg)+"] should be the MANIFEST.MF path in the bazel-out tree of directories.");
		}
		if (!this.manifestFilePath.endsWith("MANIFEST.MF")) {
			addError("Command line arg ["+id(source, arg)+"] should be the MANIFEST.MF file path.");
		}		
	}

	// Ex: bazel-out/darwin-fastbuild/bin/samples/helloworld/git.properties
	protected void setGitPropertiesFilePath(String arg, String source) {
		this.gitpropertiesFilePath = arg;
		if (!this.gitpropertiesFilePath.contains("bazel-out")) {
			addError("Command line arg ["+id(source, arg)+"] should be the git.properties path in the bazel-out tree of directories.");
		}
		if (!this.gitpropertiesFilePath.endsWith("properties")) {
			addError("Command line arg ["+id(source, arg)+"] should be the git.properties file path.");
		}		
	}
	
	// Ex: samples/helloworld/helloworld_classpath.idx
	protected void setClasspathIndexFilePath(String arg, String source) {
		this.classpathIndexFilePath = arg;
		if (!this.classpathIndexFilePath.endsWith(".idx")) {
			addError("Command line arg ["+id(source, arg)+"] should be the file path to the classpath index file (ends with .idx).");
		}		
	}
	
	// Ex: bazel-out/a/b/c/spring-aop-5.3.2.jar bazel-out/a/b/c/spring-boot-actuator-2.4.1.jar bazel-out/a/b/c/spring-web-5.3.2.jar
	// but could also contains non .jar files (which we later ignore)
	// returns the index in the rawArgs array of the last item processed as a dependency lib
	protected int setDependencyLibNames(String[] argArray, int argIndexStart) {
		// pull off the list of jars until we reach the end of the args list, or find a named parameter
		// if this is a positional style of args, the dependency list (by definition) is at the end of the args
		this.dependencyLibNames = new ArrayList<>();
		
		for (int i = argIndexStart; i<argArray.length; i++) {
			String arg = argArray[i];
			if (arg.startsWith("--")) {
				// a different named arg, stop processing
				return i-1;
			}
			
			// Spring Boot rule only wants jars in the dep list, but the user may not have control over their transitive closure
			// of upstream deps. So we don't validate that each dep is a .jar here. Later, in the Spring Boot rule we will skip
			// non-jar deps.			
			this.dependencyLibNames.add(arg);
		}
		
		return argArray.length-1;
	}
	
	// VALIDATION
	
	protected boolean hasAllRequiredArgs() {
		boolean complete = true;
		if (packageWorkingDirPath == null) {
			addError("Missing required arg "+ARG_WORKING_PATH);
			complete = false;
		}
		if (singleJarExecPath == null) {
			addError("Missing required arg "+ARG_SINGLEJAR);
			complete = false;
		}
		if (mainClassName == null) {
			addError("Missing required arg "+ARG_MAINCLASS);
			complete = false;
		}
		if (outputJarFilePath == null) {
			addError("Missing required arg "+ARG_OUTPUTJAR);
			complete = false;
		}
		if (jdkPath == null) {
			addError("Missing required arg "+ARG_JDKPATH);
			complete = false;
		}
		if (appJarFilePath == null) {
			addError("Missing required arg "+ARG_APPLIBPATH);
			complete = false;
		}
		if (manifestFilePath == null) {
			addError("Missing required arg "+ARG_MANIFESTPATH);
			complete = false;
		}
		if (this.gitpropertiesFilePath == null) {
			addError("Missing required arg "+ARG_GITPROPS);
			complete = false;
		}
		if (dependencyLibNames == null) {
			addError("Missing required arg "+ARG_DEPS);
			complete = false;
		}
		
		return complete;
	}
	
	// HELPERS
	
	protected void addError(String error) {
		if (validationErrors == null) {
			validationErrors = new ArrayList<>();
		}
		validationErrors.add(error);
	}
	
	private String id(String source, String value) {
		return "["+source+": "+value+"]";
	}
}
