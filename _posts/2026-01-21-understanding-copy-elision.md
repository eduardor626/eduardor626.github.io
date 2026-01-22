---
title: "Understanding Copy Elision Through Constructor Tracing"
date: 2026-01-21 14:19:47 -0700
categories: [C++]
tags: [c++]
description: "A practical technique for understanding what C++ actually does with your objects"
image: 
  path: /assets/2026/02/copy-elision.png
  width: 700
  height: 500
---

## Introduction

I recently came across a coding question on [getcracked.io](getcracked.io) that required understanding how objects are constructed, copied, moved, and passed into functions in C++. Working through the problem mentally was helpful, but I quickly realized that truly understanding object lifetime and invocation requires seeing what actually happens at runtime.

This post walks through the example, highlights a common misunderstanding that I experienced, and shows how tools like Jason Turner’s *constructor tracing* technique can reveal what C++ is really doing underneath the hood.

---

## The Question

Assume you're using C++17, and `<iostream>` is included. What is the output of this program?

```cpp
struct A {
	A(int x) : x(x) {}
	A(const A& a) { x = 2; }
	A(A&& a) { x = 3; }
	int x;
};

void foo(A t) {
	std::cout << t.x;
}

int main() {
	A a(0);
	foo(a);
	foo(A(0));
}
```

---

## My Initial Thoughts

Let’s step through `main()` line by line.

`A a(0);`

- This constructs an object of type `A` using `A(int)`, setting `x = 0`. Nothing is printed.

`foo(a);`

- The function `foo` takes its parameter **by value**, which means a copy  `A` object must be created from `a`. Since `a` is an **lvalue**, the copy constructor is used: `A(const A& a).`
- This sets `x = 2`, so `foo` prints `2`.

`foo(A(0));`

- At first glance, I thought this code would:
    1. Construct a temporary object from `A(0)`
    2. Copy or move it into `foo`
    
    We’d expect the copy to print a  `2` or the move to print a `3`. So based on this reasoning, the expected output would be:
    
    ```cpp
    22 // or 23
    ```
    
    However, **neither** is correct.
    

---

## The Correct Output

The actual output is: 

```cpp
20
```

Why does the second call print `0` instead of `2` or `3`?

---

## Revealing the Truth with Constructor Tracing

Jason Turner has a [great video](https://www.youtube.com/watch?v=287_oG4CNMc) where he demonstrates printing constructor calls to understand object lifetimes more clearly in C++. Inspired by this, I updated the code to print whenever a constructor is invoked.


```cpp
#include <iostream>

struct A {
    A(int x) : x(x) { std::cout<<"constructor call\n";}
    A(const A& a) { std::cout<<"copy constructor call\n"; x = 2; }
    A(A&& a) { std::cout<<"move constructor call\n"; x = 3; }
    int x;
};

void foo(A t) {
    std::cout << t.x<<'\n';
}

int main() {
    A a(0);
    foo(a);
    foo(A(0));
    return 0;
}
```

This produces the following output:

```cpp
constructor call
copy constructor call
2
constructor call
0
```

This tells us something very important:

- The first call (`foo(a)`) performs a copy.
- The second call (`foo(A(0))`) does **not** invoke the copy or move constructor at all, it only calls the regular constructor once.

This means the parameter `t` in the second `foo` call is constructed directly from `A(0)`, with no intermediate temporary object being created and then copied or moved.

Why isn’t the move constructor called?

- `A(0)` is a prvalue (a temporary expression, not yet an object), there is no source object to move from. In other words, there is no already-existing `A` object whose state could be transferred, therefore the move constructor cannot be called.


## What’s Actually Happening (C++17 Semantics)

In C++17, this behavior is **guaranteed by the language.**

When a prvalue is used to initialize another object of the same type, the standard requires that the object be constructed directly in its final location(copy elision). No temporary object is created, and therefore no copy or move constructor is called! 

In this case, the parameter `t` inside `foo` is constructed directly using `A(int)` . Which is why `t.x = 0` in the second `foo` call. 


## What Is a prvalue?

A **prvalue** (pure rvalue) is an expression that produces a value that does not have a persistent memory location. It is a specific type of rvalue.

Examples of prvalues include:

```cpp
A(0)      // temporary value
42        // literal
x + y     // result of an expression
```

In C++17, prvalues behave differently than in earlier versions of C++. They are no longer treated as temporary objects that must be copied or moved. Instead, they represent *initialization instructions* that tell the compiler how to construct an object directly in its final location.

This change is what makes the behavior in `foo(A(0))` guaranteed and efficient. This is known as *copy elision*.


## What Is copy elision?

**Copy elision** omits copy and move operations, even if their constructors exist.

In C++17, certain cases of copy elision are **mandatory**, including:

- Initializing an object from a prvalue of the same type
    ```cpp
    void foo(A a);  // parameter initialized from prvalue
    foo(A(0));      // A(0) is a prvalue - no copy/move
    ```
- Returning objects by value
    ```cpp
    A bar() {
        return A(42);  // A(42) is a prvalue - guaranteed elision
    }
    ```

Before C++17, copy elision was permitted but optional. Compilers could perform it as an optimization (Return Value Optimization/RVO), but weren't required to. C++17 made these specific cases mandatory, changing the language semantics.


## Conclusion

The surprising output of `20` is not the result of an optional compiler optimization, but a **guaranteed semantic rule** in C++17, mandatory copy elision for prvalues.

Key takeaways:

- Passing by value does not always imply copying or moving
- In C++17 prvalues enable direct construction at the destination
- Copy elision is mandatory in specific cases
- Constructor tracing is a powerful debugging technique for understanding what C++ actually does with your objects

Jason Turner's *constructor tracing* approach is valuable not just for performance analysis, but for building a better understanding about modern C++ semantics. Learning small features of the language such as copy elision can really help develop our understanding of C++ and appreciate these optimizations.