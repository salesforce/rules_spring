load("@bazel_tools//tools/python:toolchain.bzl", "py_runtime_pair")

#
# What Python is being used?
#
# Simple utility to print out the python executable being used by Bazel.
#   bazel run //tools/python_interpreter:check_python_path

py_binary(
    name = "check_python_path",
    srcs = [
        "check_python_path.py",
    ],
)


#
# CAPTIVE PYTHON
#
# Install a specific version of python to be used by the Bazel build with the
# rule invocations below. This is disabled by default. To enable, follow these steps:
# 1. Create a subdirectory 'captive_python3' and install python3 into it. You should
#    end up with ./captive_python3/bin/python3 existing on the filesystem.
# 2. Uncomment the rule invocations below.
# 3. Uncomment the python toolchain invocation in the WORKSPACE file.

#py_runtime(
#    name = "python3",
#    interpreter = "captive_python3/bin/python3",
#    python_version = "PY3",
#    visibility = ["//visibility:public"],
#)

#py_runtime_pair(
#    name = "captive_python_runtimes",
#    py3_runtime = ":python3",
#)

#toolchain(
#    name = "captive_python_toolchain",
#    toolchain = ":captive_python_runtimes",
#    toolchain_type = "@bazel_tools//tools/python:toolchain_type",
#)
