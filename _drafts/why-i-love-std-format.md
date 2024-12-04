---
title: Why I Love `std::format`
date: 2024-10-25 14:30:45 -0700
categories: [Programming]
tags: [c++]
description: Exploring the format library in C++20
image:
  path: /assets/img/github_icon.png
  width: 800
  height: 800
  alt: My Github Icon Photo [credits to original]
---

## The Format Library

The fmt library is an open sourced library that allows you to format text in a way that concise, expressive, and supportive of many different features like being able to output color, time, objects, etc.

## C's `printf`
Lately, I've been writing a ton of C code and notice the conventional `printf` function that is offered in C to print values to the console.

Coming from a C++ background, I found the `printf` function to be quite useful after getting used to it. Especially when working with embedded systems where its often useful to see the output of a register value in hex.

For example:
```C
// register address
uint32_t register_addr = 0x000f;
uint32_t register_value = 0x0001;

printf("Register Address: \n")

```

or printing string outputs:
```C
const char * characters = {'a','b','c'};
printf("the character array is $\n,characters);

```




### Issues

## C++'s `std::iostream`


### Issues


# The best of both worlds

## C++20's `std::format`
Introduced in C++20, we get the `#include <format>` library.

I personally love this library and believe it offers all the benefits of `printf` with the formatting of the output.

Can also print out to the console in C++23! 


## Summary
While C has the `printf` , which can be seen as a samurai blade. Allowing you to perform various output of different primitive types. A/llowing for nice output of hex values, string, etc. 

And C++ has `iostream` such as `std::cout` which allows more functionality but can be seen as too long of a syntax. Especially when trying to format the output and having `iomanip` get involved. It almost seems as if the iostreams are overkill and more like Cloud's blade. Where it just comes with too much baggage.

In comes the sleek, lean, more futuristic cousin of both `printf` and `iostram`, brought to us by the creators of std::format. The bow and arrow and sword, with a shield because of its safety. 