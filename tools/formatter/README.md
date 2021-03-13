# Bazel File Formatter

This script runs the Bazel buildifier tool on all of our Bazel files (BUILD, \*.bzl).
Execute it from the root of the repo.

```bash
cd rules-spring
./tools/formatter/format_bazel_files.sh
```

Please do not mix functional and formatting changes in a PR.
Before running the script, make sure you have a clean Git workspace.
