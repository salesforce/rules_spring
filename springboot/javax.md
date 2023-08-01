## Migrating from javax to jakarta for Spring Boot 3

The Java community is going through its Python2 → Python3 moment.
Oracle donated source code to open source, but their lawyers said that the Java trademark must be protected.
Therefore, the donated code must be repackaged from *javax* to *jakarta* (e.g. from *javax.servlet* to *jakarta.servlet*).
The Maven GAVs change too (e.g. *javax.servlet:javax.servlet-api* to *jakarta.servlet:jakarta.servlet-api*).
Read more [in this article](https://blogs.oracle.com/javamagazine/post/transition-from-java-ee-to-jakarta-ee).

This is obviously super disruptive.
These changes affect runtime, not just compile time.
If you have a compiled jar file with code that references a class in the *javax.servlet* package,
  it will break at runtime if you deploy it with the newly packaged *jakarta* servlet jar.
Therefore you have to make the switch across many libs, all at once.
This is a big bang upgrade, folks.

The Spring Boot project chose to force this migration with [Spring Boot 3](https://spring.io/blog/2022/11/24/spring-boot-3-0-goes-ga).
Whether you like it or not, you must migrate to stay on a supported version of Spring Boot.
Good times.

### Jakarta Migration Path (in a nutshell)

There is a migration path for going from *javax* to *jakarta*.
It doesn't make it easy, but it does allow you to break it up a little.

The important thing to know is that there are two aspects of migration: the **GAV**, and the **Java package**.
- the GAV migration (groupId, artifactId, version) moves from a *javax* groupId and artifactId, to a *jakarta* one
- the Java package migration involves moving from classes in a *javax* package, to a *jakarta* package

The GAV migration is the easier one, since it is just a configuration change.
The Java package migration is tough, because it involves actual code level changes to use the migrated package names.

### Transitional Jars

The Jakarta team helps you out a little bit by providing what I call *transitional jars*.
These jars are half migrated jars that allow you to take the migration steps incrementally.
The best way to explain them is to provide an example:

- Javax Jar:
  - GAV: *javax.json:javax.json-api:1.1.4*
  - Java package: *javax.json*
- Transitional Jar:
  - GAV: *jakarta.json:jakarta.json-api:1.1.6*
  - Java package: *javax.json*
- Jakarta Jar:
  - GAV: *jakarta.json:jakarta.json-api:2.1.2*
  - Java package: *jakarta.json*

This allows you to update to a transitional version of the *jakarta* GAV, without adopting the Java package change too.
That first step is just a build metadata change.

:key: After upgrading to the transitional jars, you should enable the
[springboot rule duplicate class check](https://github.com/salesforce/rules_spring/blob/main/springboot/unwanted_classes.md#detecting-duplicate-classes)
  which should highlight any jars bringing in old versions of the *javax* classes.

### Not All javax is Migrating to jakarta

Before you try to rip out *all* javax usages in your Spring Boot jar, know that not every
  *javax* package is migrating to *jakarta*.
The detection tooling is empathetic to this.
You can ignore jars that have non-migrating *javax* classes for this reason.

### Javax Detect Mode

After upgrading to the transitional jars, and enabling the duplicate class checker, you need to continue to look for *javax* classes
  in your classpath that are not in a transitional jar.
There are widely used projects out there that did bad things - they included standard *javax* classes in their jar files.
While those projects **might** continue to function properly on old *javax* classes, they need to be researched.
They hopefully have newer versions that use the newer *jakarta* classes.

The springboot rule has a *javaxdetect* mode to help with this.
When enabled, it will detect classes in the classpath located in a _javax.*_ package.
If the jar that contains that class is not in your ignorelist, the build will fail.
The intent is for you to analyze all *javax* classes in your classpath to determine if/when/how they will migrate to _jakarta_.

Example:

```starlark
springboot(
    name = "my-boot-app",
    boot_app_class = "com.acme.MyService",
    javaxdetect_enable = True,
    javaxdetect_ignorelist = "//tools/springboot:javaxdetect_ignorelist.txt",
    java_library = ":base_lib",
)
```

where the contents of the *javaxdetect_ignorelist.txt* file will look like this when you are transitioning:

```
# TEMPORARY IGNORES

# These are jakarta transitional jars: they use jakarta GAV but still have javax Java packaging.
# We need these entries until we switch to later versions that contain jakarta packaging.
jakarta.activation-api-1.2.2.jar
jakarta.annotation-api-1.3.5.jar
jakarta.el-3.0.4.jar
jakarta.enterprise.cdi-api-2.0.2.jar
jakarta.inject-2.6.1.jar
jakarta.inject-api-1.0.5.jar
jakarta.interceptor-api-1.2.5.jar
jakarta.jms-api-2.0.3.jar
jakarta.json-1.1.6.jar
jakarta.json-api-1.1.6.jar
jakarta.jws-api-2.1.0.jar
jakarta.persistence-api-2.2.3.jar
jakarta.servlet-api-4.0.4.jar
jakarta.transaction-api-1.3.3.jar
jakarta.validation-api-2.0.2.jar
jakarta.websocket-api-1.1.2.jar
jakarta.websocket-client-api-1.1.2.jar
jakarta.ws.rs-api-2.1.6.jar
jakarta.xml.bind-api-2.3.3.jar
jakarta.xml.soap-api-1.4.2.jar
jakarta.xml.ws-api-2.3.3.jar

# PERMANENT IGNORES

# javax.measure:unit-api
# This jar is the outcome of [JSR-363](https://jcp.org/en/jsr/detail?id=363).
# It appears to have no public plans to migrate, and so will remain javax for the foreseeable future.
unit-api-1.0.jar

# com.google.code.findbugs:jsr305
# This was an early JSR that never progressed beyond proposal, so it is a dormant JSR.
# However, Google emitted this findbugs jar, and a bunch of people use it.
# But since it isn't an official javax product, it has no migration plan.
jsr305-3.0.2.jar

# javax.cache:cache-api
# This is the outcome of [JSR-107](https://www.jcp.org/en/jsr/detail?id=107) (aka JCache).
# Discussion about migration: [JCache for jakarta](https://github.com/jsr107/jsr107spec/issues/415)
# But since JCache was never adopted by JavaEE, it is not planned for migration.
cache-api-1.1.1.jar
```

For completeness, this is the BUILD file at *//tools/springboot*:

```
exports_files([
    "javaxdetect_ignorelist.txt",
])
```

### Javax Reference Checking

Ideally the *springboot()* rule would have a feature for *javax* reference checking.
Meaning, it would decompile every class in the springboot classpath and check if any were referencing
  a *javax* package.
We don't have that. I wish we did.

### Finishing the Jakarta Migration

Once you have moved to the transitional jars, and have investigated and resolved jars with *javax* classes in them, you will be ready
  to finish your migration.
You need to move from the **transitional GAV**, to the **jakarta GAV**.
This is officially documented as the [JaveEE 10 migration.](https://blogs.oracle.com/javamagazine/post/transition-from-java-ee-to-jakarta-ee)
When you do this step, remove the jakarta transitional jars from your ignore list since you should
  now be using newer versions that use jakarta packages.

In addition, the following must happen at the same time as upgrading:
- [Spring Boot 3](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)
- [Spring 6](https://github.com/spring-projects/spring-framework/wiki/Upgrading-to-Spring-Framework-6.x)
- [Jetty 11](https://webtide.com/jetty-10-and-11-have-arrived/)
- and others, depending on what libraries your service uses

It is going to be fun.
