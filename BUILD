#
# Copyright (c) 2017-2024, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

load("@rules_license//rules:license.bzl", "license")

exports_files([
    "LICENSE.txt",
])

# Using a package wide default ensure that all targets are associated with the
# license.
package(
    default_applicable_licenses = [":license"],
    default_visibility = ["//visibility:public"],
)

license(
    name = "license",
    copyright_notice = "Copyright (c) 2017-2024, Salesforce",
    license_kinds = [
        "@rules_license//licenses/spdx:Apache-2.0",
    ],
    license_text = "//:LICENSE.txt",
    package_name = "@rules_spring",
    package_url = "https://github.com/salesforce/rules_spring",
    package_version = "2.4.2",
    visibility = ["//visibility:public"],
)
