## Neverlink Lib

This example *java_library* has *neverlink* set to true.

```
Boolean; default is False

Whether this library should only be used for compilation and not at runtime. Useful if the library will be provided by the runtime environment during execution. Examples of such libraries are the IDE APIs for IDE plug-ins or tools.jar for anything running on a standard JDK.

Note that neverlink = True does not prevent the compiler from inlining material from this library into compilation targets that depend on it, as permitted by the Java Language Specification (e.g., static final constants of String or of primitive types). The preferred use case is therefore when the runtime library is identical to the compilation library.

If the runtime library differs from the compilation library then you must ensure that it differs only in places that the JLS forbids compilers to inline (and that must hold for all future versions of the JLS).
```