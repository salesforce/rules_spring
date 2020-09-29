## Salesforce Spring Boot Rule for Bazel

This repository contains the [Spring Boot](https://spring.io/guides/gs/spring-boot/) rule for the [Bazel](https://bazel.build/) build system.
It enables Bazel to build Spring Boot applications and package them as an executable jar file.
The executable jar is the best way to deploy your Spring Boot application in production environments. 

The Salesforce *springboot* rule is contained in a directory that is designed to be copied into your workspace.
It can be found, along with documentation, in this location:
- [bazel-springboot-rule](tools/springboot): a Bazel extension to build and package Spring Boot applications

### Did your build break on September 29, 2020?

:fire: If you have a git repository rule bringing in this Spring Boot rule with *brach=master*, you broke on Sept 29, 2020 at around 3pm Pacific.
I switched the repo to use *maven_install* style dependencies, instead of the obsolete *maven_jar*.
I tagged the old code line as 1.0.2.
To restore the old style, please use the following stanza in your WORKSPACE (to replace whatever you have there).

```
git_repository(
    name = "bazel_springboot_rule",
    tag = "1.0.2",
    remote = "https://github.com/salesforce/bazel-springboot-rule",
    verbose = False,
)
```

The 1.0.2 tag will not be maintained. 
All new features will be added to *master* which is currently only *maven_install*.

### Support

This rule was developed by Salesforce.
If you have any issues with this repository, please create a [GitHub Issue](https://github.com/salesforce/bazel-springboot-rule/issues).
We will try to quickly address problems and answer questions.

:octocat: Please do us a huge favor. If you think this project could be useful for you, now or in the future, please hit the **Star** button at the top. That helps us advocate for more resources on this project. Thanks!

### Alternate Approach

If you don't need to create a runnable executable jar file, there is a simpler approach to Spring Boot in the *rules_jvm_external* repository.
That approach is sufficient if Bazel and your Bazel workspace are available in all environments that launch the application.
- [rules_jvm_external Spring Boot example](https://github.com/plaird/rules_jvm_external/tree/master/examples/spring_boot)

At Salesforce, Bazel is not available in production environments, and so this alternate approach is not viable.
