# This macro runs a shell script to implant build variables into a properties file,
# which is in turn consumed by Spring's BuildProperties bean. See the script for
# usage details.

def gen_buildinfo_rule(name, output = "src/main/resources/META-INF/build-info.properties"):
    native.genrule(
        name = name,
        cmd = """$(location //examples/demoapp:generate-build-info.sh) $@""",
        tools = ["//examples/demoapp:generate-build-info.sh"],
        outs = [output],
    )
