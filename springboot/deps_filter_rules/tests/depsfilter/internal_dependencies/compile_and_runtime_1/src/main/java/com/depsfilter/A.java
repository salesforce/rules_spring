package com.depsfilter;

public class A {
    int a;
    private B b;
    // E is a runtime dependency, so no compile-time reference here
    public A() {
        a = 1;
        b = new B();
    }
}