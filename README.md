## Salesforce Spring Rules for Bazel

This repository contains the [Spring Boot](https://spring.io/guides/gs/spring-boot/) rule for the [Bazel](https://bazel.build/) build system.
It enables Bazel to build Spring Boot applications and package them as an executable jar file.
The executable jar is the best way to deploy your Spring Boot application in production environments.

The Salesforce *springboot* rule can be found, along with documentation, in this location:
- [springboot](springboot): a Bazel extension to build and package Spring Boot applications

The *springboot* rule runs on any version of Bazel 1.2.1 or higher.
Please do not link to the *master* branch of this rule in your Bazel workspace, use an official release instead:
- [rules-spring releases](https://github.com/salesforce/bazel-springboot-rule/releases)

### Support and Ongoing Development

This rule was developed and is supported by Salesforce.
If you have any issues with this repository, please create a [GitHub Issue](https://github.com/salesforce/bazel-springboot-rule/issues).
We will try to quickly address problems and answer questions.

Ongoing development is planned and tracked using this GitHub repository's [Project Manager](https://github.com/salesforce/bazel-springboot-rule/projects).
To see what bug fixes and new features are planned, consult the roadmaps located there.

:octocat: Please do us a **huge favor**. If you think this project could be useful for you, now or in the future, please hit the **Star** button at the top. That helps us advocate for more time and resources on this project. Thanks!

### Loading the Spring Rules in your WORKSPACE

Before you can use the rule in your BUILD files, you need to add it to your workspace.
There are two approaches to doing this.

**Reference an official release**
This loads a pre-built version of this rule into your workspace during the build.
This is the recommended approach for most users.

```starlark
http_archive(
    name = "rules_spring",
    sha256 = "7d4f12748df340397559decd8348289a6f85ae32dae344545b6d08ad036a9cfe",
    urls = [
        "https://github.com/salesforce/bazel-springboot-rule/releases/download/2.0.0/rules-spring-2.0.0.zip",
    ],
)
```

**Copy the rule into your workspace (aka vendoring)**
This approach allows you to bring in the rule, and make customizations as necessary.
We recommend copying it into location *//tools/springboot* in your workspace but you are free to change this if you like.

Once it is copied in, add this to your WORKSPACE:
```starlark
local_repository(
    name = "rules_spring",
    path = "tools/springboot",
)
```
Make sure to review the [buildstamp](tools/buildstamp) documentation as well.


### Alternate Approach for Building and Running Spring Boot Applications

If you don't need to create a runnable executable jar file, there is a simpler approach to Spring Boot in the *rules_jvm_external* repository.
That approach is sufficient if Bazel and your Bazel workspace (i.e. source code) are available in all environments that launch the application.
- [rules_jvm_external Spring Boot example](https://github.com/plaird/rules_jvm_external/tree/master/examples/spring_boot)

At Salesforce, Bazel is not available in production environments, and so this alternate approach is not viable.

### Migrations

#### Are you refreshing your Spring Boot archive/fork for the first time since March X, 2021?

On that date I merged in the major repackaging of the Spring Boot rule into the *master* branch.
This was to comply with the standardized Bazel rule layout conventions.
When the Spring Boot rule was originally written, the conventions did not exist.
This repackaging makes the rule more modern.

For rule 1.x users, you will need to do the following:
- All WORKSPACE and BUILD file references to *bazel_springboot_rule* must be changed to *rules_spring*
- All BUILD and .bzl file references to *//tools/springboot* must be changed to *//springboot*

See [Repackaging work item](https://github.com/salesforce/bazel-springboot-rule/issues/30) for more details.

#### Are you refreshing your Spring Boot archive/fork for the first time since September 29, 2020?

On that date I switched the repo to use *maven_install* style dependencies, instead of the obsolete *maven_jar* ([removed as of Bazel 2.x](https://github.com/bazelbuild/bazel/issues/6799)).
I tagged the old code line as 1.0.2.
To restore the old style, please use the following stanza in your WORKSPACE (to replace whatever you have there).

```starlark
git_repository(
    name = "rules_spring",
    tag = "1.0.2",
    remote = "https://github.com/salesforce/bazel-springboot-rule",
    verbose = False,
)
```

The 1.0.2 tag will not be maintained.
All new features will be added to *master* which is currently only *maven_install*.
