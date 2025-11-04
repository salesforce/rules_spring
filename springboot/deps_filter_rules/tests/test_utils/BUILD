package(default_visibility = ["//visibility:public"])

java_library(
    name = "test_utils",
    srcs = glob(["src/test/java/**/*.java"]),
    data = [":dependency_graph.txt"],
    deps = [],
)

# Export the dependency graph file for tests
exports_files(["dependency_graph.txt"]) 