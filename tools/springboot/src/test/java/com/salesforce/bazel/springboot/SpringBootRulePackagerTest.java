package com.salesforce.bazel.springboot;

import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

import org.junit.Test;

public class SpringBootRulePackagerTest {

  @Test
  public void testSpringBootRuleBasics() throws Exception {
	  SpringBootRuleArgs args = createTestEnv();
  }

  protected SpringBootRuleArgs createTestEnv() throws Exception {
	  System.
	  
	  SpringBootRuleArgs args = new SpringBootRuleArgs();
	  args.appJarFilePath = null;
	  args.dependencyLibNames = null;
	  
	  InputStream is = this.getClass().getResourceAsStream("git.properties");
	  args.gitpropertiesFilePath = null;

	  args.jdkPath = null;
	  args.mainClassName = null;
	  args.manifestFilePath = null;
	  args.outputJarFilePath = null;
	  args.packageWorkingDirPath = null;
	  args.singleJarExecPath = null;

	  
	  return args;
  }
  
  private void writeStreamToFile(InputStream is, String path) throws Exception {
	  File file = new File(path);
	  Files.copy(is, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
  }
}
