package com.depsfilter;

public class H {
    private A a;
    // G is a runtime dependency, so no compile-time reference here
    public H() {
        a = new A();
    }
} 