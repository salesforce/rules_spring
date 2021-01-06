## Captive Python

There are two ways to invoke Python from Bazel:

- **System Python** - use the python installed on the host
- **Captive Python** - use a dedicated python installed for the Bazel workspace

Setting up a build machine with system Python is the easiest.
Just ```brew install python3```, ```apt-get install python3.8```, install Anaconda, etc.
But the problem with using system Python is lack of hermeticity.
Developer A may have installed Python 3.6, while Developer B may have Python 3.8, and your CI farm may be on Python 3.9.
Also, system Python can drift over time after install, as a developer upgrades it to satisfy other usages of it on their host.

For hermeticity, it is better to have a captive Python.
But there is more work required to achieve this.
This package shows how to set up a captive python environment for Bazel builds for this workspace.

### Setup

Within Salesforce, we have a setup script that developers/CI systems run after cloning the repository,
  but before running a Bazel build.
That script does a set of work, including installing Python3 into a *captive_python3* subdirectory in our *//tools/python_interpreter* package.

This step is left as an exercise to the reader.
Some options:

- Do you have a setup script? Can you add captive python3 install to it?
- Are you using Ansible? Can you add captive python3 to your playbook?
- Are you familiar with the //tools/bazel wrapper script (it is not really documented)? You could insert an install step there.

### Python Toolchain Registration in BUILD and WORKSPACE

The [BUILD](BUILD) file defines the python toolchain.
You will need to uncomment the rules in the BUILD file once you have performed the setup step.

But this by itself does not have an affect.
The key step is this invocation in the [WORKSPACE](../../WORKSPACE) file.

```starlark
register_toolchains(
    "//tools/python_interpreter:captive_python_toolchain",
)
```

This installs the captive version as the preferred python toolchain.

### Verify the Captive Python

To check that the captive python is being used by Bazel, run this:

```bash
bazel run //tools/python_interpreter:check_python_path
```
