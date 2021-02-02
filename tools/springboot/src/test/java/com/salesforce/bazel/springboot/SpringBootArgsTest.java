package com.salesforce.bazel.springboot;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.fail;

import org.junit.Test;

public class SpringBootArgsTest {
	
	
	// SETTER TESTS
	
	@Test
	public void testSingleJarSetter() {
		SpringBootRuleArgs args = new SpringBootRuleArgs();
		args.setSingleJarPath("/darwin-sandbox/334/java_tools/src/tools/singlejar/singlejar_local", "test");
		assertNull(args.validationErrors);
		
		args.setSingleJarPath("/not/a/path/to/singljar", "test");
		assertNotNull(args.validationErrors);
	}

	@Test
	public void testMainClassSetter() {	
		SpringBootRuleArgs args = new SpringBootRuleArgs();
		args.setMainClassName("com.acme.MyMainClass", "test");
		assertNull(args.validationErrors);
		
		args.setMainClassName("com.acme.MyMainClass.java", "test");
		assertNotNull(args.validationErrors); // fail
		args.validationErrors = null;
		
		args.setMainClassName("com.acme.MyMainClass.class", "test");
		assertNotNull(args.validationErrors); // fail
		args.validationErrors = null;

		args.setMainClassName("com/acme/MyMainClass", "test");
		assertNotNull(args.validationErrors); // fail
	}

	@Test
	public void testOutputJarSetter() {	
		SpringBootRuleArgs args = new SpringBootRuleArgs();
		args.setOutputJarFilePath("bazel-out/darwin-fastbuild/bin/samples/helloworld/helloworld.jar", "test");
		assertNull(args.validationErrors);
		
		args.setOutputJarFilePath("darwin-fastbuild/bin/samples/helloworld/helloworld.jar", "test");
		assertNotNull(args.validationErrors); // fail
		args.validationErrors = null;
		
		args.setOutputJarFilePath("bazel-out/darwin-fastbuild/bin/samples/helloworld/helloworld", "test"); 
		assertNotNull(args.validationErrors); // fail
	}

	@Test
	public void testAppJarSetter() {	
		SpringBootRuleArgs args = new SpringBootRuleArgs();
		args.setAppJarFilePath("bazel-out/darwin-fastbuild/bin/samples/helloworld/libhelloworld_lib.jar", "test");
		assertNull(args.validationErrors);
		
		args.setAppJarFilePath("darwin-fastbuild/bin/samples/helloworld/libhelloworld_lib.jar", "test");
		assertNotNull(args.validationErrors); // fail
		args.validationErrors = null;
		
		args.setAppJarFilePath("bazel-out/darwin-fastbuild/bin/samples/helloworld/libhelloworld_lib", "test"); 
		assertNotNull(args.validationErrors); // fail
	}

	@Test
	public void testManifestSetter() {	
		SpringBootRuleArgs args = new SpringBootRuleArgs();
		args.setManifestFilePath("bazel-out/darwin-fastbuild/bin/samples/helloworld/MANIFEST.MF", "test");
		assertNull(args.validationErrors);
		
		args.setManifestFilePath("darwin-fastbuild/bin/samples/helloworld/MANIFEST.MF", "test");
		assertNotNull(args.validationErrors); // fail
		args.validationErrors = null;
		
		args.setManifestFilePath("bazel-out/darwin-fastbuild/bin/samples/helloworld/MANIFEST", "test"); 
		assertNotNull(args.validationErrors); // fail
	}

	@Test
	public void testClasspathIndexSetter() {	
		SpringBootRuleArgs args = new SpringBootRuleArgs();
		args.setClasspathIndexFilePath("samples/helloworld/helloworld_classpath.idx", "test");
		assertNull(args.validationErrors);
		
		args.setClasspathIndexFilePath("samples/helloworld/helloworld_classpath", "test");
		assertNotNull(args.validationErrors); // fail
		args.validationErrors = null;
	}

	@Test
	public void testDepLibsSetter() {	
		SpringBootRuleArgs args = new SpringBootRuleArgs();
		String[] depLibs = { "notalib", "notalib", "aaa.jar", "bbb.jar", "ccc.jar", "ddd.jar"};
		
		args.setDependencyLibNames(depLibs, 2);
		assertNull(args.validationErrors);
		assertEquals(4, args.dependencyLibNames.size());
		args.dependencyLibNames = null;
		
		args.setDependencyLibNames(depLibs, 1);
		assertNotNull(args.validationErrors); // fail, notalib is seen as a non jar
		args.validationErrors = null;
		
		String[] depLibsEndNamed = { "notalib", "notalib", "aaa.jar", "bbb.jar", "ccc.jar", "ddd.jar", "--some_named_arg"};
		args.setDependencyLibNames(depLibsEndNamed, 2);
		assertNull(args.validationErrors);
		assertEquals(4, args.dependencyLibNames.size());		
	}


	// FULL COMMAND LINE TESTS
	
	@Test
	public void testPositionalArgsHappy() {
		String[] argList = generatePositionalArgs();
		SpringBootRuleArgs args = new SpringBootRuleArgs(argList);
		boolean success = args.parseAndValidateCommandLine();
		if (!success) {
			String errorLines = "";
			for (String error : args.validationErrors) {
				System.err.println(error);
				errorLines = errorLines + error + " ";
				fail("Failed to parse the command line. "+errorLines);
			}
		}
		assertNull(args.validationErrors);
		assertEquals(TEST_ARG_WORKING_PATH, args.packageWorkingDirPath);
		assertEquals(TEST_ARG_SINGLEJAR, args.singleJarExecPath);
		assertEquals(TEST_ARG_MAINCLASS, args.mainClassName);
		assertEquals(TEST_ARG_OUTPUTJAR, args.outputJarFilePath);
		assertEquals(TEST_ARG_JDKPATH, args.jdkPath);
		assertEquals(TEST_ARG_APPLIBPATH, args.appJarFilePath);
		assertEquals(TEST_ARG_APPLIBNAME, args.appJarName);
		assertEquals(TEST_ARG_MANIFESTPATH, args.manifestFilePath);
		assertEquals(TEST_ARG_CPINDEXPATH, args.classpathIndexFilePath);
		assertEquals(3, args.dependencyLibNames.size());
	}

	@Test
	public void testNamedArgsHappy_Ordered() {
		String[] argList = generateNamedArgs_ordered();
		SpringBootRuleArgs args = new SpringBootRuleArgs(argList);
		boolean success = args.parseAndValidateCommandLine();
		if (!success) {
			String errorLines = "";
			for (String error : args.validationErrors) {
				System.err.println(error);
				errorLines = errorLines + error + " ";
				fail("Failed to parse the command line. "+errorLines);
			}
		}
		assertNull(args.validationErrors);
		assertEquals(TEST_ARG_WORKING_PATH, args.packageWorkingDirPath);
		assertEquals(TEST_ARG_SINGLEJAR, args.singleJarExecPath);
		assertEquals(TEST_ARG_MAINCLASS, args.mainClassName);
		assertEquals(TEST_ARG_OUTPUTJAR, args.outputJarFilePath);
		assertEquals(TEST_ARG_JDKPATH, args.jdkPath);
		assertEquals(TEST_ARG_APPLIBPATH, args.appJarFilePath);
		assertEquals(TEST_ARG_APPLIBNAME, args.appJarName);
		assertEquals(TEST_ARG_MANIFESTPATH, args.manifestFilePath);
		assertEquals(TEST_ARG_CPINDEXPATH, args.classpathIndexFilePath);
		assertEquals(3, args.dependencyLibNames.size());
	}

	@Test
	public void testNamedArgsHappy_Unordered() {
		String[] argList = generateNamedArgs_unordered();
		SpringBootRuleArgs args = new SpringBootRuleArgs(argList);
		boolean success = args.parseAndValidateCommandLine();
		if (!success) {
			String errorLines = "";
			for (String error : args.validationErrors) {
				System.err.println(error);
				errorLines = errorLines + error + " ";
				fail("Failed to parse the command line. "+errorLines);
			}
		}
		assertNull(args.validationErrors);
		assertEquals(TEST_ARG_WORKING_PATH, args.packageWorkingDirPath);
		assertEquals(TEST_ARG_SINGLEJAR, args.singleJarExecPath);
		assertEquals(TEST_ARG_MAINCLASS, args.mainClassName);
		assertEquals(TEST_ARG_OUTPUTJAR, args.outputJarFilePath);
		assertEquals(TEST_ARG_JDKPATH, args.jdkPath);
		assertEquals(TEST_ARG_APPLIBPATH, args.appJarFilePath);
		assertEquals(TEST_ARG_APPLIBNAME, args.appJarName);
		assertEquals(TEST_ARG_MANIFESTPATH, args.manifestFilePath);
		assertEquals(TEST_ARG_CPINDEXPATH, args.classpathIndexFilePath);
		assertEquals(3, args.dependencyLibNames.size());
	}
	
	@Test
	public void testNamedArgsUnhappy_MissingArgs() {
		String[] argList = generateNamedArgs_missing();
		SpringBootRuleArgs args = new SpringBootRuleArgs(argList);
		boolean success = args.parseAndValidateCommandLine();
		assertFalse(success);
		assertNotNull(args.validationErrors);
	}
	
	
	// HELPERS
	
	private static String TEST_ARG_WORKING_PATH = "/private/var/tmp/_bazel_user/7c9d9/sandbox/darwin-sandbox/334/execroot/bazel_springboot_rule ";
	private static String TEST_ARG_SINGLEJAR = "/private/var/tmp/_bazel_user/7c9d9/sandbox/darwin-sandbox/334/execroot/bazel_springboot_rule/external/remote_java_tools_darwin/java_tools/src/tools/singlejar/singlejar_local";
	private static String TEST_ARG_MAINCLASS = "com.sample.SampleMain";
	private static String TEST_ARG_OUTPUTJAR = "bazel-out/darwin-fastbuild/bin/samples/helloworld/helloworld.jar";
	private static String TEST_ARG_JDKPATH = "external/remotejdk11_macos";
	private static String TEST_ARG_APPLIBPATH = "bazel-out/darwin-fastbuild/bin/samples/helloworld/libhelloworld_lib.jar";
	private static String TEST_ARG_APPLIBNAME = "helloworld";
	private static String TEST_ARG_MANIFESTPATH = "bazel-out/darwin-fastbuild/bin/samples/helloworld/MANIFEST.MF";
	private static String TEST_ARG_GITPROPSPATH = "bazel-out/darwin-fastbuild/bin/samples/helloworld/git.properties";
	private static String TEST_ARG_CPINDEXPATH = "samples/helloworld/helloworld_classpath.idx";
	
	
	private String[] generatePositionalArgs() {
		return new String[] { 
				TEST_ARG_WORKING_PATH, 
				TEST_ARG_SINGLEJAR, 
				TEST_ARG_MAINCLASS, 
				TEST_ARG_JDKPATH, 
				TEST_ARG_APPLIBNAME, 
				TEST_ARG_OUTPUTJAR, 
				TEST_ARG_APPLIBPATH,
				TEST_ARG_MANIFESTPATH, 
				TEST_ARG_GITPROPSPATH, 
				TEST_ARG_CPINDEXPATH, 
				"test1.jar", "test2.jar", "test3.jar"}; 
	}

	private String[] generateNamedArgs_ordered() {
		return new String[] { 
				"--"+SpringBootRuleArgs.ARG_WORKING_PATH, TEST_ARG_WORKING_PATH, 
				"--"+SpringBootRuleArgs.ARG_SINGLEJAR, TEST_ARG_SINGLEJAR, 
				"--"+SpringBootRuleArgs.ARG_MAINCLASS, TEST_ARG_MAINCLASS, 
				"--"+SpringBootRuleArgs.ARG_OUTPUTJAR, TEST_ARG_OUTPUTJAR, 
				"--"+SpringBootRuleArgs.ARG_JDKPATH, TEST_ARG_JDKPATH, 
				"--"+SpringBootRuleArgs.ARG_APPLIBPATH, TEST_ARG_APPLIBPATH,
				"--"+SpringBootRuleArgs.ARG_APPLIBNAME, TEST_ARG_APPLIBNAME, 
				"--"+SpringBootRuleArgs.ARG_MANIFESTPATH, TEST_ARG_MANIFESTPATH, 
				"--"+SpringBootRuleArgs.ARG_GITPROPS, TEST_ARG_GITPROPSPATH, 
				"--"+SpringBootRuleArgs.ARG_CPINDEXPATH, TEST_ARG_CPINDEXPATH, 
				"--"+SpringBootRuleArgs.ARG_DEPS, "test1.jar", "test2.jar", "test3.jar"
			}; 
	}
	
	private String[] generateNamedArgs_unordered() {
		return new String[] { 
				"--"+SpringBootRuleArgs.ARG_SINGLEJAR, TEST_ARG_SINGLEJAR, 
				"--"+SpringBootRuleArgs.ARG_MAINCLASS, TEST_ARG_MAINCLASS, 
				"--"+SpringBootRuleArgs.ARG_DEPS, "test1.jar", "test2.jar", "test3.jar",
				"--"+SpringBootRuleArgs.ARG_OUTPUTJAR, TEST_ARG_OUTPUTJAR, 
				"--"+SpringBootRuleArgs.ARG_CPINDEXPATH, TEST_ARG_CPINDEXPATH, 
				"--"+SpringBootRuleArgs.ARG_WORKING_PATH, TEST_ARG_WORKING_PATH, 
				"--"+SpringBootRuleArgs.ARG_APPLIBNAME, TEST_ARG_APPLIBNAME, 
				"--"+SpringBootRuleArgs.ARG_JDKPATH, TEST_ARG_JDKPATH, 
				"--"+SpringBootRuleArgs.ARG_MANIFESTPATH, TEST_ARG_MANIFESTPATH,
				"--"+SpringBootRuleArgs.ARG_GITPROPS, TEST_ARG_GITPROPSPATH, 
				"--"+SpringBootRuleArgs.ARG_APPLIBPATH, TEST_ARG_APPLIBPATH,
			}; 
	}
	
	private String[] generateNamedArgs_missing() {
		return new String[] { 
				"--"+SpringBootRuleArgs.ARG_WORKING_PATH, TEST_ARG_WORKING_PATH, 
				"--"+SpringBootRuleArgs.ARG_SINGLEJAR, TEST_ARG_SINGLEJAR, 
				"--"+SpringBootRuleArgs.ARG_MAINCLASS, TEST_ARG_MAINCLASS, 
				"--"+SpringBootRuleArgs.ARG_OUTPUTJAR, TEST_ARG_OUTPUTJAR, 
				"--"+SpringBootRuleArgs.ARG_JDKPATH, TEST_ARG_JDKPATH, 
			}; 
	}
	
}
