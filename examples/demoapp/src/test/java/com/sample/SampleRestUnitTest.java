/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
*/
package com.sample;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

/**
 * This test class does NOT start the Spring Boot application. It is a simple unit test.
 */
public class SampleRestUnitTest {

    @Test
    public void apiTest() {
      SampleRest testClass = new SampleRest();
      assertEquals("Hello!", testClass.hello());
    }
}
