## Salesforce Spring Rules for Bazel

This repository contains the [Spring Boot](https://spring.io/guides/gs/spring-boot/) rule
  for the [Bazel](https://bazel.build/) build system.
It enables Bazel to build Spring Boot applications and package them as an executable jar file.
The executable jar is the best way to deploy your Spring Boot application in production environments.

The Salesforce *springboot* rule can be found, along with documentation, in this location:
- [springboot](springboot): a Bazel extension to build and package Spring Boot applications

### Support and Ongoing Development

This rule was developed and is supported by Salesforce.
If you have any issues with this repository, please create a [GitHub Issue](https://github.com/salesforce/rules_spring/issues).
We will try to quickly address problems and answer questions.
Note that we do not yet support running these [rules on Windows](https://github.com/salesforce/rules_spring/issues/25).

Ongoing development is planned and tracked using this GitHub repository's [Project Manager](https://github.com/salesforce/rules_spring/projects).
To see what bug fixes and new features are planned, consult the roadmaps located there.

:octocat: Please do us a **huge favor**. If you think this project could be useful for you, now or in the future,
  please hit the **Star** button at the top. That helps us advocate for more time and resources on this project. Thanks!

### Loading the Spring Rules in your WORKSPACE

Before you can use the rule in your BUILD files, you need to add it to your workspace.

**Reference an official release**
This loads a pre-built version of this rule into your workspace during the build.
This is the recommended approach for most users.

```starlark
http_archive(
    name = "rules_spring",
    sha256 = "c5b1166949c7291945ddd7b3becbe22cec0c8a91458660842506cb634b36f3f0",
    urls = [
        "https://github.com/salesforce/rules_spring/releases/download/2.1.1/rules-spring-2.1.1.zip",
    ],
)
```

**Do not use a git_repository rule with our master branch**
If you choose not to use an official release, you may be tempted to use a *git_repository* workspace
  rule to point to our *master* branch,
Please **do not** do this, as we use *master* for ongoing work.
We may check breaking changes into *master* at any time.


### Alternate Approach for Building and Running Spring Boot Applications

If you don't need to create a runnable executable jar file, there is an alternate approach to Spring Boot
  in the *rules_jvm_external* repository.
That approach is sufficient if Bazel and your Bazel workspace (i.e. source code) are available in
  all environments that launch the application.
- [rules_jvm_external Spring Boot example](https://github.com/bazelbuild/rules_jvm_external/tree/master/examples/spring_boot)

At Salesforce, Bazel is not available in production environments, and so this alternate approach is not viable.

### Upgrades

This section contains notes for specific upgrade steps needed to adopt newer versions of *rules-spring*.
Starting with the 1.1.x line, we strive to adhere to [SemVer](https://semver.org/).

:fire: this Git repository was renamed from *bazel-springboot-rule* to *rules_spring* on March 17, 2021.
This was done to comply with required Bazel naming conventions for external rules.

#### 2.0.0: March 13, 2021

This release refactored the rule with the standardized Bazel rule layout conventions.
When the Spring Boot rule was originally written, the conventions did not exist.
This repackaging makes the rule more modern.

For rule 1.x users upgrading to 2.0.0, you will need to do the following:
- All WORKSPACE and BUILD file references to *bazel_springboot_rule* must be changed to *rules_spring*
- All BUILD and .bzl file references to *//tools/springboot* must be changed to *//springboot*

See [Repackaging work item](https://github.com/salesforce/rules_spring/issues/30) for more details.

#### 1.0.0 September 21, 2020

With this release we switched the repo to use *maven_install* style dependencies, instead of the obsolete *maven_jar*.
The *maven_jar* rule was [removed from Bazel in 2.x](https://github.com/bazelbuild/bazel/issues/6799).
