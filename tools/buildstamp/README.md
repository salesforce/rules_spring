## Build Stamping

Bazel has a feature to optionally add 'stamping' information to particular build artifacts.
We sometimes stamp Spring Boot applications with Git information (such as branch,
   commit id, build time, etc) such that the data can be found in the */manage/info* endpoint.
This helps with troubleshooting.
Great, right?

#### The Downsides of Stamping

The main issue with stamping is that it reduces the benefit of Bazel remote build caching.
Once an artifact is stamped with Git data, it cannot be shared via the remote cache with other builds.
Also, any other artifact that depends on that artifact will also miss the remote cache.
This is a big limitation.

#### Full Stamping is Disabled by Default at Salesforce

At Salesforce, we like to make use of remote caching for developer builds.
To mitigate the remote caching limitation, our build by default has very limited build stamping.
It does **not** include the Git data in the stamp.
This allows multiple machines to share the same remote cache artifacts, particularly for Spring Boot.

Details about how this is done is explained in the Internals section below.

#### Run a Build with Full Stamping

The default behavior of the build is optimized for remote caching performance.
But when you are building artifacts for deployment to shared environments (e.g. test envs, prod)
  you should run your build with the full stamp.
This will allow others to figure out who built the artifact, when, and with what Git coordinates.
When troubleshooting problems, that extra data is critical.

To signal to the build that you want full stamping, you can create a marker file to enable it:

```
$ cd [your workspace] (i.e. top level directory of your repo where WORKSPACE is)
$ touch full_stamp.txt  (marker file that triggers full stamping)
$ bazel build //...
```

Full stamping is also signaled if the environment variable *IS_RELEASE_BUILD* is set to true.
This may be more convenient for CI systems.

```
$ export IS_RELEASE_BUILD=true
$ bazel build //...
```

### BUILD File Configuration

The way to signal to Bazel to stamp a particular artifact is to add an attribute to the rule in your BUILD file:

```
  stamp = 1
```

This is done automatically for you in the [Spring Boot rule](../springboot/springboot.bzl)
   when it generates the *git.properties* file, as seen in this snippet:

```
gengitinfo_out = "git.properties"
native.genrule(
    name = gengitinfo_rule,
    cmd = "$(location //tools/springboot:write_gitinfo_properties.sh) $@",
    tools = ["//tools/springboot:write_gitinfo_properties.sh"],
    outs = [gengitinfo_out],
    tags = tags,
    stamp = 1,
)
```

### Internals

#### Understand stable-status.txt and volatiles-status.txt

The Bazel documentation provides a good explanation for how stamping works in Bazel, so please visit that first:
- [Bazel Build Stamping](https://docs.bazel.build/versions/master/user-manual.html#workspace_status)

#### Monorepo Stamping Implementation

The build is configured to **always** run the stamping code, configured here:
- [.bazelrc](../../.base-bazelrc#L55)

The stamping code is in this directory, and has our custom code to do the stamping:
- [get_workspace_status](get_workspace_status)

That script is where we do performance optimization to **only apply a full stamp when doing important builds**.
The way we do this is by halting the script before it writes the Git data into the *stable-status.txt* file by default.

This is where we make that choice:
- [Halt stamping of Git data by default](get_workspace_status#L46)

If the file *full_stamp.txt* exists at the top level of the monorepo, it will run the full stamping code.
