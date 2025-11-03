package com.depsfilter;

public class A {
    int a;
    private B b;
    private E e;
    public A() {
        a = 1;
        b = new B();
        e = new E();
    }
}