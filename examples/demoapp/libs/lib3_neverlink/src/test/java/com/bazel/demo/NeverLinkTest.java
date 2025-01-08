/*
 * Copyright (c) 2019-2024, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
*/
package com.bazel.demo;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class NeverLinkTest {

    // because the library is marked neverlink, it should not be on the runtime classpath
    // TODO this is not testing the SpringBoot app, just the java_library, need to rewrite as SpringBootTest
    // manually confirmed with: jar -tvf bazel-bin/examples/demoapp/demoapp.jar | grep lib3
    @Test(expected = NoClassDefFoundError.class)
    public void neverlinkTest() {
      new NeverLinkedClass();
    }
}
