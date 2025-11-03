load("@bazel_skylib//lib:unittest.bzl", "asserts")

def verify_jars(env, actual_jars, expected_jars, jar_field):
    expected_jars = sorted(expected_jars)
    actual_jars = sorted(actual_jars)
    asserts.equals(env, type(expected_jars), type(actual_jars), 
        "JAR type mismatch: {}".format(jar_field))
    asserts.equals(env, expected_jars, actual_jars, 
        "JAR contents mismatch: {}".format(jar_field))
        
def verify_runtime_and_compile_jars(ctx, env, javainfo, expected_compile_jars = None, expected_full_compile_jars = None, expected_transitive_compile_jars = None, expected_transitive_runtime_jars = None):
    """Helper function to verify runtime and compile time JARs."""
    transitive_runtime_jars = [jar.basename for jar in javainfo.transitive_runtime_jars.to_list()]
    verify_jars(env, transitive_runtime_jars, expected_transitive_runtime_jars, "transitive_runtime_jars")
    transitive_compile_jars = [jar.basename for jar in javainfo.transitive_compile_time_jars.to_list()]
    verify_jars(env, transitive_compile_jars, expected_transitive_compile_jars, "transitive_compile_jars")
    compile_jars = [jar.basename for jar in javainfo.compile_jars.to_list()]
    verify_jars(env, compile_jars, expected_compile_jars, "compile_jars")
    full_compile_jars = [jar.basename for jar in javainfo.full_compile_jars.to_list()]
    verify_jars(env, full_compile_jars, expected_full_compile_jars, "full_compile_jars")

def verify_jars_and_dropped_counts(env, expected, expected_compile_dropped = "0", expected_full_compile_dropped = "0", expected_transitive_compile_dropped = "0", expected_transitive_runtime_dropped = "0"):
    dropped_counts = {
        "compile_jars_dropped": expected["compile_jars_dropped"],
        "full_compile_jars_dropped": expected["full_compile_jars_dropped"],
        "transitive_compile_jars_dropped": expected["transitive_compile_jars_dropped"],
        "transitive_runtime_jars_dropped": expected["transitive_runtime_jars_dropped"],
    }
    verify_dropped_counts(env, dropped_counts, 
                          expected_compile_dropped, expected_full_compile_dropped,
                          expected_transitive_compile_dropped, expected_transitive_runtime_dropped)

def verify_dropped_counts(env, dropped_counts, expected_compile_dropped = "0", expected_full_compile_dropped = "0", expected_transitive_compile_dropped = "0", expected_transitive_runtime_dropped = "0"):
    """
    Verifies that the correct number of JARs were dropped for each type.
    """
    if expected_compile_dropped == "0":
        asserts.equals(env, dropped_counts["compile_jars_dropped"], 0, 
            "Expected no compile JARs to be dropped, but {} were dropped".format(dropped_counts["compile_jars_dropped"]))
    elif expected_compile_dropped == ">0":
        asserts.true(env, dropped_counts["compile_jars_dropped"] > 0, 
            "Expected some compile JARs to be dropped, but {} were dropped".format(dropped_counts["compile_jars_dropped"]))
    
    if expected_full_compile_dropped == "0":
        asserts.equals(env, dropped_counts["full_compile_jars_dropped"], 0, 
            "Expected no full compile JARs to be dropped, but {} were dropped".format(dropped_counts["full_compile_jars_dropped"]))
    elif expected_full_compile_dropped == ">0":
        asserts.true(env, dropped_counts["full_compile_jars_dropped"] > 0, 
            "Expected some full compile JARs to be dropped, but {} were dropped".format(dropped_counts["full_compile_jars_dropped"]))
    
    if expected_transitive_compile_dropped == "0":
        asserts.equals(env, dropped_counts["transitive_compile_jars_dropped"], 0, 
            "Expected no transitive compile JARs to be dropped, but {} were dropped".format(dropped_counts["transitive_compile_jars_dropped"]))
    elif expected_transitive_compile_dropped == ">0":
        asserts.true(env, dropped_counts["transitive_compile_jars_dropped"] > 0, 
            "Expected some transitive compile JARs to be dropped, but {} were dropped".format(dropped_counts["transitive_compile_jars_dropped"]))
    
    if expected_transitive_runtime_dropped == "0":
        asserts.equals(env, dropped_counts["transitive_runtime_jars_dropped"], 0, 
            "Expected no transitive runtime JARs to be dropped, but {} were dropped".format(dropped_counts["transitive_runtime_jars_dropped"]))
    elif expected_transitive_runtime_dropped == ">0":
        asserts.true(env, dropped_counts["transitive_runtime_jars_dropped"] > 0, 
            "Expected some transitive runtime JARs to be dropped, but {} were dropped".format(dropped_counts["transitive_runtime_jars_dropped"]))

def update_jar_name(jar_name, new_jar_name, jar_list):
    for i, jar in enumerate(jar_list):
        if jar_name in jar:
            jar_list[i] = jar.replace(jar_name, new_jar_name)
    return jar_list

def _collect_filtered_jars(existing_jars, jar_list, excluded_jars = [], exclusion_patterns = []):
    dropped_count = 0
    for jar in jar_list:
        jar_name = jar.basename
        if jar_name not in existing_jars and jar_name not in excluded_jars:
            should_include = True
            for pattern in exclusion_patterns:
                if pattern in jar_name:
                    should_include = False
                    dropped_count += 1
                    break
            if should_include:
                existing_jars.append(jar_name)
            else:
                dropped_count += 1
        elif jar_name in excluded_jars:
            dropped_count += 1
    return existing_jars, dropped_count

def _compute_excluded_jars_from_labels(ctx):
    excluded_compile_jars = []
    excluded_full_compile_jars = []
    excluded_transitive_compile_jars = []
    excluded_transitive_runtime_jars = []
    
    if not ctx.attr.deps_exclude_labels:
        return {
            "compile_jars": excluded_compile_jars,
            "full_compile_jars": excluded_full_compile_jars,
            "transitive_compile_jars": excluded_transitive_compile_jars,
            "transitive_runtime_jars": excluded_transitive_runtime_jars,
        }
    
    for excluded_label in ctx.attr.deps_exclude_labels:
        java_info = excluded_label[JavaInfo]
        
        if ctx.attr.exclude_transitives:
            # Exclude the dep and its transitives
            excluded_compile_jars, _ = _collect_filtered_jars(excluded_compile_jars, java_info.compile_jars.to_list())
            excluded_full_compile_jars, _ = _collect_filtered_jars(excluded_full_compile_jars, java_info.full_compile_jars.to_list())
            excluded_transitive_compile_jars, _ = _collect_filtered_jars(excluded_transitive_compile_jars, java_info.transitive_compile_time_jars.to_list())
            excluded_transitive_runtime_jars, _ = _collect_filtered_jars(excluded_transitive_runtime_jars, java_info.transitive_runtime_jars.to_list())
        else:
            # Only exclude the direct dep JARs
            excluded_compile_jars, _ = _collect_filtered_jars(excluded_compile_jars, java_info.compile_jars.to_list())
            excluded_full_compile_jars, _ = _collect_filtered_jars(excluded_full_compile_jars, java_info.full_compile_jars.to_list())
            excluded_transitive_compile_jars, _ = _collect_filtered_jars(excluded_transitive_compile_jars, java_info.compile_jars.to_list())
            excluded_transitive_runtime_jars, _ = _collect_filtered_jars(excluded_transitive_runtime_jars, java_info.full_compile_jars.to_list())
             
    return {
        "compile_jars": excluded_compile_jars,
        "full_compile_jars": excluded_full_compile_jars,
        "transitive_compile_jars": excluded_transitive_compile_jars,
        "transitive_runtime_jars": excluded_transitive_runtime_jars,
    }

def compute_expected_jars(ctx, test_lib_name = None):
    """
    Computes expected JARs after applying all exclusions (labels and patterns).
    """
    excluded_jars = _compute_excluded_jars_from_labels(ctx)
    exclusion_patterns = ctx.attr.deps_exclude_paths or []
    
    if test_lib_name == None:
        expected_compile_jars = []
        expected_full_compile_jars = []
        expected_transitive_compile_jars = []
        expected_transitive_runtime_jars = []
    else:
        test_lib_compile_jar = "lib" + test_lib_name + "-hjar.jar"
        test_lib_full_compile_jar = "lib" + test_lib_name + ".jar"
        expected_compile_jars = [test_lib_compile_jar]
        expected_full_compile_jars = [test_lib_full_compile_jar]
        expected_transitive_compile_jars = [test_lib_compile_jar]
        expected_transitive_runtime_jars = [test_lib_full_compile_jar]

    compile_jars_dropped = 0
    full_compile_jars_dropped = 0
    transitive_compile_jars_dropped = 0
    transitive_runtime_jars_dropped = 0
    
    # Process compile-time deps
    for dep in ctx.attr.deps_labels:
        java_info = dep[JavaInfo]
        if test_lib_name == None:
            expected_compile_jars, dropped = _collect_filtered_jars(expected_compile_jars, java_info.compile_jars.to_list(), excluded_jars["compile_jars"], exclusion_patterns)
            compile_jars_dropped += dropped
            expected_full_compile_jars, dropped = _collect_filtered_jars(expected_full_compile_jars, java_info.full_compile_jars.to_list(), excluded_jars["full_compile_jars"], exclusion_patterns)
            full_compile_jars_dropped += dropped
        else:
            _, dropped = _collect_filtered_jars([], java_info.compile_jars.to_list(), excluded_jars["compile_jars"], exclusion_patterns)
            compile_jars_dropped += dropped
            _, dropped = _collect_filtered_jars([], java_info.full_compile_jars.to_list(), excluded_jars["full_compile_jars"], exclusion_patterns)
            full_compile_jars_dropped += dropped
        expected_transitive_compile_jars, dropped = _collect_filtered_jars(expected_transitive_compile_jars, java_info.transitive_compile_time_jars.to_list(), excluded_jars["transitive_compile_jars"], exclusion_patterns)
        transitive_compile_jars_dropped += dropped
        expected_transitive_runtime_jars, dropped = _collect_filtered_jars(expected_transitive_runtime_jars, java_info.transitive_runtime_jars.to_list(), excluded_jars["transitive_runtime_jars"], exclusion_patterns)
        transitive_runtime_jars_dropped += dropped
    
    # Process runtime deps
    for runtime_dep in ctx.attr.runtime_deps_labels:
        java_info = runtime_dep[JavaInfo]
        expected_transitive_runtime_jars, dropped = _collect_filtered_jars(expected_transitive_runtime_jars, java_info.transitive_runtime_jars.to_list(), excluded_jars["transitive_runtime_jars"], exclusion_patterns)
        transitive_runtime_jars_dropped += dropped
        # Note: Runtime deps typically don't contribute to compile-time transitives
    
    return {
        "compile_jars": expected_compile_jars,
        "full_compile_jars": expected_full_compile_jars,
        "transitive_compile_jars": expected_transitive_compile_jars,
        "transitive_runtime_jars": expected_transitive_runtime_jars,
        "compile_jars_dropped": compile_jars_dropped,
        "full_compile_jars_dropped": full_compile_jars_dropped,
        "transitive_compile_jars_dropped": transitive_compile_jars_dropped,
        "transitive_runtime_jars_dropped": transitive_runtime_jars_dropped,
    }