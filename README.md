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

Ongoing development is planned and tracked using this GitHub repository's [Project Manager](https://github.com/salesforce/rules_spring/projects).
To see what bug fixes and new features are planned, consult the roadmaps located there.

:octocat: Please do us a **huge favor**. If you think this project could be useful for you, now or in the future,
  please hit the **Star** button at the top. That helps us advocate for more time and resources on this project. Thanks!

### Loading the Spring Rules in your WORKSPACE

Before you can use the rule in your BUILD files, you need to add it to your workspace.

**Bzlmod**

We aren't currently listed in the Bazel Central Registry (hopefully this will be fixed soon).
```starlark
# rules_spring is not in Bazel Central Registry yet, so specify the specific commit
bazel_dep(name = "rules_spring", version = "2.5.1")
git_override(
    module_name = "rules_spring",
    remote = "https://github.com/salesforce/rules_spring",
    commit="29e7be015415b1a80e706cf40e333b1a6251961b",
)
```

**WORKSPACE (legacy)**

This loads a pre-built version of this rule into your workspace during the build.
```starlark
http_archive(
    name = "rules_spring",
    sha256 = "fe247b8b8bd58c82023e0b4212484724bf17f81394f97e913c522cea68b125e8",
    urls = [
        "https://github.com/salesforce/rules_spring/releases/download/2.5.1/rules-spring-2.5.1.zip",
    ],
)
```

Do not use a git_repository rule with our main branch.
If you choose not to use an official release, you may be tempted to use a *git_repository* workspace
  rule to point to our *main* branch,
Please **do not** do this, as we use *main* for ongoing work.
We may check breaking changes into *main* at any time.


### Upgrading to Spring Boot 3

This is largely outside the scope of *rules_spring*.
You will need to update your dependencies in your *maven_install* rules, of course.

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
    # The launcher class changed in between Boot2 and Boot3, so we provide the
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
