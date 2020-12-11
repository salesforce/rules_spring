rm -rf bazel-*

TMPDIR=/tmp/bazel-springboot-rule-release
mkdir $TMPDIR
mv tools/python_interpreter/bin $TMPDIR
mv tools/python_interpreter/captive_python3 $TMPDIR

jar -cvf bazel-springboot-rule-1.0.7.zip *

mv $TMPDIR/bin tools/python_interpreter
mv $TMPDIR/captive_python3 tools/python_interpreter
