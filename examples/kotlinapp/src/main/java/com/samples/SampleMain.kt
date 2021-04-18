/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
*/

package com.samples

import org.slf4j.LoggerFactory
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationPropertiesScan

/**
 * Main entrypoint
 */
@SpringBootApplication
@ConfigurationPropertiesScan
class SampleMain
fun main(args: Array<String>) {
    val logger = LoggerFactory.getLogger(SampleMain::class.java)
    SpringApplication.run(SampleMain::class.java, *args)
    logger.info("Sample Kotlin application has started")
}
