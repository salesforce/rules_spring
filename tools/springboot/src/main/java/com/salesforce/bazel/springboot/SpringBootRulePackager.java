package com.salesforce.bazel.springboot;

import java.util.ArrayList;
import java.util.List;

/**
 * Packages the application using the validated attributes on the springboot rule.
 */
public class SpringBootRulePackager {

	protected SpringBootRuleArgs args;
	protected List<String> packagingErrors;
	
	public SpringBootRulePackager(SpringBootRuleArgs args) {
		this.args = args;
	}
	
	public void packageApplication() {
		if (args.validationErrors != null) {
			// should not get in here, but just in case
			addError("Cannot package the application. There are validation errors for the arguments.");
		}
		
		// 
		
	}
	
	// HELPERS
	
	protected void addError(String error) {
		if (packagingErrors == null) {
			packagingErrors = new ArrayList<>();
		}
		packagingErrors.add(error);
	}
	
}
