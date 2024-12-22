package com.sample;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;

import org.springframework.boot.loader.tools.SignalUtils;

public class SampleAutoConfiguration {

    @Value("${demoapp.config.internal:not found}")
    String config_internal;

    @Value("${demoapp.config.rootdirectory:not found}")
    String config_external_root;

    @Value("${demoapp.config.configsubdirectory:not found}")
    String config_external_configsub;

    @Value("${prop1:not found}")
    String config_external_env_prop1;

    @Value("${prop2:not found}")
    String config_external_env_prop2;

    @PostConstruct
    public void logLoadedProperties() {
        System.out.println("SampleAutoConfiguration loading of application.properties files:");
        System.out.println("  internal application.properties: "+config_internal);
        System.out.println("  external application.properties: "+config_external_root);
        System.out.println("  external config/application.properties: "+config_external_configsub);
        System.out.println("SampleAutoConfiguration loading of environment variables:");
        System.out.println("  PROP1: "+config_external_env_prop1);
        System.out.println("  PROP2: "+config_external_env_prop2);
    }

    @PostConstruct
    public void setupSignalHandler() {
        // SignalUtils is really limited, it only attaches to the INT signal (2)
        // You could steal the code and attach to other signals.
        // https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-tools/spring-boot-loader-tools/src/main/java/org/springframework/boot/loader/tools/SignalUtils.java
        SignalUtils.attachSignalHandler(new SampleSignalHandler());
    }

    /**
     * Shows how you can catch an OS signal. This is a good test of the launcher script See
     * https://github.com/salesforce/rules_spring/issues/91
     * The only signal that SignalUtils attaches to is 2 (interrupt). kill -2 [pid]
     */
    private static class SampleSignalHandler implements Runnable {
        @Override
        public void run() {
            System.out.println("Caught an Interrupt signal.");
            System.exit(0);
        }
    }
}
