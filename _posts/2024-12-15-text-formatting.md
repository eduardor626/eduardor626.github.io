---
title: Why I Love std::format
date: 2024-12-15
categories: [Programming]
tags: [c++]
description: The Evolution of Text Formatting in C++
image:
  path: /assets/2024/finally_std_format.png
---

# Introduction: The Evolution of Text Formatting in C++

Text formatting has been a challenge in C and C++. Developers have juggled between different approaches, each with their own limitations. This post explores how `std::format` introduced into the standard with C++20, nicely solves many of these formatting challenges.

# C's printf(): The Traditional Approach

`printf()`: Writes formatted output to the console/terminal.

Pros ✅:
- Simple and straightforward syntax
- Lightweight and performant
- Part of the standard C library
- Works across different platforms

Cons ⛔:
- Type-unsafe
- Limited type support, primarily supporting primitive built-in types
- No compile-time type checking
- Potential security vulnerabilities
- Can lead to undefined behavior with incorrect format specifiers

### Quick and Easy

I personally really enjoy using C's `printf()` for outputting primitive types. Specifically in embedded programming where I'm often outputting the hex and decimal representation of a certain value, along with a human-readable string name for enum-based codes.

```cpp
// Define an example enum for status
typedef enum {
    SUCCESS = 0x00,
    ERROR_COMMUNICATION = 0x10,
    ERROR_TIMEOUT = 0xA5,
    ERROR_MEMORY_FULL = 0xFF
} StatusCode;

// Function to convert error code to string
const char* get_status_name(StatusCode code) {
    switch(code) {
        case SUCCESS: return "SUCCESS";
        case ERROR_COMMUNICATION: return "ERROR_COMMUNICATION";
        case ERROR_TIMEOUT: return "ERROR_TIMEOUT";
        case ERROR_MEMORY_FULL: return "ERROR_MEMORY_FULL";
        default: return "UNKNOWN_ERROR";
    }
}

int main() {
    StatusCode value = ERROR_MEMORY_FULL;
    printf("Hex value: 0x%02X, Name: %s, Dec value: %d\n", 
           value, 
           get_status_name(value), 
           value);
    
    return 0;
}
```
This to me is much easier than using the more verbose syntax of `std::cout`.

However, the lack of type safety and potential security vulnerabilities make `printf()` less desirable in production code.

## Limitations and Security Risks

### Type Mismatches

The following code will compile but cause undefined behavior at runtime:

```cpp
int x = 42;
char * str = "Hello";
printf("%d", str); // Passing a char string where an integer is expected
printf("%s", x); // Passing an integer where a string is expected
```

### Buffer Overflow
Potential buffer overflow scenario:
``` cpp
char buffer[10];
strcpy(buffer, "very long string that exceeds 10 characters");
printf("%s", buffer);  // This could cause a buffer overflow
```

### Format String Attacks
Direct user input can be dangerous:
```cpp
char *user_input = "malicious input";
printf(user_input);  // dangerous if user input is passed directly to printf() without proper formatting,
```


# C++'s std::iostream: The Verbose Alternative
C++ introduces input/output streams, specifically a type-safe `std::cout`.

`std::cout`:  "standard character output." It is part of the C++ Standard Library and is used to output data to the standard output stream, typically the console or terminal. An alternative to C's `printf()`.


Pros ✅:
- Type-safe
- Supports stream manipulators
- Supports custom output for user-defined types

Cons ⛔:
- Verbose syntax
- Performance overhead compared to `printf`
- Complex formatting requires additional manipulators
- Less intuitive than traditional formatting/print methods

I have used `std::cout` for most of my C++ programming career, and only after using `printf()` or Python's `print()` function did I realize how verbose it was.

## std::iostream Verbosity 🤢
If we were to use the same example as the `printf` above, the syntax now using `std::iostream` becomes way more convoluted for simply writing output to the terminal in a specific format. 
```cpp
int main() {
    StatusCode value = StatusCode::ERROR_MEMORY_FULL;
    
    std::cout << "Hex value: " << std::hex << std::showbase 
              << static_cast<int>(value) 
              << ", Name: " << get_status_name(value)
              << ", Dec value: " << std::dec << static_cast<int>(value) 
              << std::endl;
    
    return 0;
}
```

### My Opinion:
C++ offers overloading the operator `<<` for a user defined object type, allowing for custom output using `std::iostream`. This is a significant improvement over `printf()`, which mainly works with primitive types.


However, the verbose syntax makes it less appealing and more of a hassle to write. As a programmer, I want to express intent clearly, but this syntax seems like overkill. It becomes particularly complex when using `#include <iomanip>` for width and positioning functionality.

The excess of stream manipulators can also be annoying when performing different output formats.


Why couldn't C++ learn from the simplicity of the `printf()` function? It seems others shared similar sentiments, which led to the creation of the [fmt library](https://github.com/fmtlib/fmt). 

Its popularity was so significant that it eventually made its way into the standard with C++20!


# Introducing std::format: The Modern Solution 🙌🏼

The [fmt library](https://github.com/fmtlib/fmt)
 library is an open-sourced library created by Victor Zverovich. It has a large amount of contributors and has gained so much recognition that it is now included with C++20 👏🏼


## Practical Examples
### Basic Formatting
`std::format` returns a formatted string type that can then be output using `std::cout`, creating a more concise output.


```cpp
#include <format>
#include <iostream>

int main() {
    // Simple string interpolation with placeholder
    const auto output_str{std::format("Hello, {}!", "World")};
    std::cout << output_str << std::endl;

    // Formatting with specifics
    std::cout << std::format("Hex value: {:#x}, Dec value: {:d}", 255,255) << std::endl;
    
    // Positional arguments
    std::cout << std::format("{1} {0} {2}", "World", "Hello", "C++") << std::endl;

}
// output
Hello, World!
Hex value: 0xff, Dec value: 255
Hello World C++

```
And if we were to use the same example as in the previous two sections, this is how the code would look with `std::format`.
```cpp
int main() {
    StatusCode value = StatusCode::ERROR_MEMORY_FULL;

    std::cout << std::format("Hex value: 0x{:X}, Name: {}, Dec value: {}\n", 
                              static_cast<int>(value), 
                              get_status_name(value), 
                              static_cast<int>(value));
    return 0;
}
```
The place holder syntax is much cleaner in my opinion and even though we still need to cast the value, its much more readable!

### Advanced Formatting
We can also use it for formatting our own types as long as we define the format function for the type.
```cpp
struct Point {
    int x;
    int y;
};

// Custom formatter for Point
template <>
struct std::formatter<Point> {
    constexpr auto parse(std::format_parse_context& ctx) { 
        return ctx.begin();
    }

    auto format(const Point& p, std::format_context& ctx) const {
        return std::format_to(ctx.out(), "({}, {})", p.x, p.y);
    }
};

int main()
{
    Point p{10, 20};
    std::cout << std::format("The point is: {}\n", p);
    return 0;
}
//output:
The point is: (10, 20)

```

Pros ✅:
- Type-safe formatting 
- Compile-time checking 
- Performance comparable to `printf`
- Intuitive and readable syntax 
- Supports custom formatting for user-defined types 
- Locale-aware formatting 
- Zero-overhead abstractions 

Cons ⛔:
- Requires `C++20` support
- Not all compilers fully implement the standard yet

### Advantages Over Alternatives

- **Safety**: Compile-time type checking prevents runtime errors as we saw with `printf`. Allowing us to see compilation errors if trying to format incompatible types.
- **Performance**: Near `printf`-level efficiency!
- **Expressiveness**: Clean, readable formatting syntax
- **Flexibility**: Support for custom types and advanced formatting

## But Wait! There's More!! 😏
C++23 introduced the `#include <print>` into the standard library which allows us to use `print()` and `println()` which work with formatted output!

If you're familiar with Python's `print` function, which prints to the standard output. Then you'll be surprised that C++ has FINALLY adapted this into its standard! **ABOUT TIME** if you ask me!! 🫡

Now we can avoid that whole `std::cout` jargon and simply write what we intend to do in a readable fashion. `print()` if we simply want to write to standard output or `println()` to write to standard output with a new line at the end.

```cpp
#include <print>
#include <format>

int main() {
    // Basic formatting
    std::print("without a newline.\n");
    std::println("with a new{}!", "line");
    
    // Formatting with multiple arguments
    int x = 42;
    double y = 3.14159;
    std::print("x = {}, y = {:.2f}", x, y);

    // Using placeholders
    std::println("My name is {} and I'm {} years old", "Eduardo",30);
    return 0;
}

//output
without a newline.
with a newline!
x = 42, y = 3.14
My name is Eduardo and I'm 30 years old

```

### My Opinion
This is so much cleaner and I'm glad C++ is getting more expressive and continues to be developed. Since C++23 is still being integrated into modern compilers, I believe it will make C++ that much more attractive to  beginners and easier to use. 

Although C++23 will take some time to be more available in projects, I believe the `std::format` inclusion in C++20 is already a huge step ahead. 📈

# Summary
`std::format` represents significant progress in C++ text formatting. It combines the simplicity of `printf` with the type-safety of `std::iostream`, providing a modern, elegant solution for C++ developers.

I've only touched on the surface of capabilities of the `<format>` header, but I'm really happy with the update in C++ and glad the language continues to grow better and more expressive. 👍🏼


### Recommended Resources
For more information and examples please check out these references on `<format>`.
- [C++ Reference: std::format](https://en.cppreference.com/w/cpp/utility/format/format)
- [fmt library](https://github.com/fmtlib/fmt) (original inspiration)
