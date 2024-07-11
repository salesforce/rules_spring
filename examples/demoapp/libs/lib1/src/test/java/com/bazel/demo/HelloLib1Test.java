/*
 * Copyright (c) 2019-2021, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
*/
package com.bazel.demo;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class HelloLib1Test {

    @Test
    public void helloTest() {
      HelloLib1 testClass = new HelloLib1();
      assertEquals("Hello LIB1!", testClass.hello());
    }
}
