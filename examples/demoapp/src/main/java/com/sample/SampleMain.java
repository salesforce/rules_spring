/*
 * Copyright (c) 2019-2021, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
*/
package com.sample;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.SpringApplication;
import com.bazel.demo.IntentionalDupedClass;

@SpringBootApplication
public class SampleMain {

  // both //examples/demoapp/libs/lib1 and //examples/demoapp/libs/lib2 have this class
  // this is only a problem if the springboot rule is configured to fail on dupes.
  static private IntentionalDupedClass dupedClass = new IntentionalDupedClass();

  public static void main(String[] args) throws Exception {
    System.out.println("SampleMain: Launching the sample SpringBoot demo application...");
    StringBuffer sb = new StringBuffer();
    for (String arg : args) {
      sb.append("[");
      sb.append(arg);
      sb.append("] ");
    }
    System.out.println("SampleMain:  Command line args: "+sb.toString());

    System.out.println("\nSampleMain:  Intentional duped class version: "+dupedClass.hello());

    // test that the root class is available
    Class.forName("com.sample.SampleRootClass");
    System.out.println("\nSampleMain:  loaded the root class com.sample.SampleRootClass");

    SpringApplication.run(SampleMain.class, args);
  }

}
