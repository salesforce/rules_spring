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

  // both //samples/helloworld/libs/lib1 and //samples/helloworld/libs/lib2 have this class
  // this is only a problem if the springboot rule is configured to fail on dupes.
  private IntentionalDupedClass dupedClass = new IntentionalDupedClass();

  public static void main(String[] args) {
    System.out.println("Launching the sample SpringBoot demo application...");
    StringBuffer sb = new StringBuffer();
    for (String arg : args) {
      sb.append(arg);
      sb.append(" ");
    }
    System.out.println("  Command line args: "+sb.toString());

    SpringApplication.run(SampleMain.class, args);
  }

}
