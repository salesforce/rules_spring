package com.sample;

import jakarta.annotation.PostConstruct;

import org.springframework.boot.loader.tools.SignalUtils;

public class SampleAutoConfiguration {

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
