## Captive Python

This package sets up the captive python environment for Bazel builds for this workspace.
To ensure hermetic results, we don't rely on the system python for builds.

### Setup

Within Salesforce, we have a setup script that developers/CI systems run after cloning the repository,
  but before running a Bazel build.
That script installs Python3 into a *captive_python3* subdirectory of this package.
Then, *BUILD* and *WORKSPACE* rules install the captive python3 binary as the python toolchain.


### Python Toolchain Registration

The [BUILD](BUILD) file defines the python toolchain.
You will need to uncomment the rules in the BUILD file once you have performed the setup step.

But this by itself does not have an affect.
The key step is this invocation in the [WORKSPACE](../../WORKSPACE) file.

```
register_toolchains(
    "//tools/python_interpreter:sfdc_python_toolchain",
)
```

This installs the captive version as the preferred python toolchain.

### Verify the Captive Python

To check that the captive python is being used by Bazel, run this:

```
bazel run //tools/python_interpreter:check_python_path
```
