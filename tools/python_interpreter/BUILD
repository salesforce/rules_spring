#
# Copyright (c) 2017-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#
load("@rules_python//python:defs.bzl", "py_binary")

#
# PYTHON PATH
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
#    If you have python3 in your path, you can do this with 'python3 -m venv captive_python3' in this directory
# 2. Uncomment the rule invocations below.
# 3. Uncomment the python toolchain invocation in the WORKSPACE file.
# 4. Change `is_default = True` -> `is_default = False` in MODULE.bazel OR specify an extra toolchain e.g.
#    --extra_toolchains //tools/python_interpreter:captive_python_toolchain

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
