/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
*/
package com.sample;

import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.junit4.SpringRunner;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

/**
 * This test class starts the Spring Boot application. Because the Spring context is
 * created, you can autowire spring beans into the test.
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = SampleMain.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(locations = {"classpath:/test.properties"})
public class SampleRestFuncTest {

    @Autowired
    private SampleRest sampleRest;

    @Test
    public void apiTest() {
      assertEquals("Hello!", sampleRest.hello());
    }
}
