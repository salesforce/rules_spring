## Salesforce Spring Rules for Bazel

This repository contains the [Spring Boot](https://spring.io/guides/gs/spring-boot/) rule
  for the [Bazel](https://bazel.build/) build system.
It enables Bazel to build Spring Boot applications and package them as an executable jar file.
The executable jar is the best way to deploy your Spring Boot application in production environments.

The Salesforce *springboot* rule can be found, along with documentation, in this directory:
- [springboot](springboot): a Bazel extension to build and package Spring Boot applications

### Support and Ongoing Development

This rule was developed and is supported by Salesforce.
If you have any issues with this repository, please create a [GitHub Issue](https://github.com/salesforce/rules_spring/issues).
We will try to quickly address problems and answer questions.
Note that we do not yet officially support running these [rules on Windows](https://github.com/salesforce/rules_spring/issues/25) but some users have gotten it to work.

Ongoing development is planned and tracked using this GitHub repository's [Issues list](https://github.com/salesforce/rules_spring/issues).
To see what bug fixes and new features are planned, consult the backlog located there.
Generally, we prioritize based on our internal requirements at Salesforce, but if you need something 
  please post a comment on the issue and that will help us prioritize.
To see what features/fixes were delivered in a particular release, use the release 
  [version labels](https://github.com/salesforce/rules_spring/issues/labels) and filter on Closed issues.
  [(example)](https://github.com/salesforce/rules_spring/issues?q=label%3A2.6.1+is%3Aclosed).

:octocat: Please do us a **huge favor**. If you think this project could be useful for you, now or in the future,
  please hit the **Star** button at the top. That helps us advocate for more time and resources on this project. Thanks!

### Loading the Spring Rules in your WORKSPACE

Before you can use the rule in your BUILD files, you need to add it to your workspace.

**Bzlmod**

```starlark
bazel_dep(name = "rules_spring", version = "2.6.3")
```

**WORKSPACE (legacy)**

This loads a pre-built version of this rule into your workspace during the build.
```starlark
http_archive(
    name = "rules_spring",
    sha256 = "2d0805b4096db89b8e407ed0c243ce81c3d20f346e4c259885041d5eabc59436",
    urls = [
        "https://github.com/salesforce/rules_spring/releases/download/2.6.3/rules-spring-2.6.3.zip",
    ],
)
```

If you choose not to use an official release, you may be tempted to use a *git_repository* workspace
  rule to point to our *main* branch,
Please **do not** do this, as we use *main* for ongoing work.
We may check breaking changes into *main* at any time.


### Upgrading to Spring Boot 3

This is largely outside the scope of *rules_spring*.
You will need to update your dependencies in your *maven_install* rules, of course.
But there are [a ton of other steps](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide).
Salesforce has some [docs/tools that will help](https://github.com/salesforce/rules_spring/issues/230) for Bazel users.

The one change that you will need to make for *rules_spring* is to choose the Boot3 launcher class.
This is because Boot rewrote the launcher for Boot3 and it is available under a different name.
The Boot2 launcher is the default for *rules_spring* so as not to break backwards compatibility.

Example:
```starlark
springboot(
    name = "helloworld_boot3",
    boot_app_class = "com.sample.SampleMain",
    java_library = ":helloworld_lib",

    # SPRING BOOT 3
    # The launcher class changed in Spring Boot 3.2.0, so we provide the
    # Boot3 launcher class here (the Boot2 one is the default)
    boot_launcher_class = 'org.springframework.boot.loader.launch.JarLauncher',
)
```

### Appendix: Alternate Approach for Building and Running Spring Boot Applications

If you don't need to create a runnable executable jar file, there is an alternate approach to Spring Boot
  in the *rules_jvm_external* repository.
That approach is sufficient if Bazel and your Bazel workspace (i.e. source code) are available in
  all environments that launch the application.
- [rules_jvm_external Spring Boot example](https://github.com/bazelbuild/rules_jvm_external/tree/master/examples/spring_boot)

At Salesforce, Bazel is not available in production environments, and so this alternate approach is not viable.
