package com.salesforce.bazel.springboot;

public class SpringBootRuleMain {
    public static void main(String[] rawArgs) {
    	SpringBootRuleArgs args = new SpringBootRuleArgs(rawArgs);
    	
    	boolean argsCorrect = args.parseAndValidateCommandLine();
    	if (!argsCorrect) {
    		showArgsValidationErrors(args);
        	return;
    	}

    	
    }
    
    
    private static void showArgsValidationErrors(SpringBootRuleArgs args) {
    	System.err.println("rules_springboot invocation is invalid:");
    	for (String error: args.validationErrors) {
    		System.err.println(error);
    	}
    }
}
