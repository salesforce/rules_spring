load("//springboot/deps_filter_rules:deps_filter.bzl", "deps_filter")

def dependencyset(name, items, deps_exclude_labels = [], deps_exclude_paths = [], 
        exclude_transitives = False, verbose = False, testonly = False):

    # implement logic to add default exclusions. 

    if "runtime_deps" in name:
        return deps_filter(
            name = name,
            runtime_deps = items,
            deps_exclude_labels = deps_exclude_labels,
            deps_exclude_paths = deps_exclude_paths,
            exclude_transitives = exclude_transitives,
            verbose = verbose,
            testonly = testonly,
        )
    else:
        return deps_filter(
            name = name,
            deps = items,
            deps_exclude_labels = deps_exclude_labels,
            deps_exclude_paths = deps_exclude_paths,
            exclude_transitives = exclude_transitives,
            verbose = verbose,
            testonly = testonly,
        )