
## The Problem: Manually Counting Compile Time Parameters

In a recent project, I needed a way to manage a growing number of software components consistently. These components were used to allocate threads for the runtime engine depending on their type.

These components were either allowed to be:

- **exclusive** - belonging to a single exclusive thread
- **cooperative** - belonging to a cooperative thread pool

Great, simple. We just calculate each component type at runtime and create a dynamically sized container at runtime to store each component and its count..

But, this is an embedded project, where we care about dynamic allocation and runtime overhead!

 We wish to know the number of components at **compile time** as opposed to runtime like this:

```cpp
// 8 = number of cooperative components
// 4 = number of exclusive components
// 12 = number of total components
Runtime<8,4,12> runtime_engine;
```

Since `runtime_engine` is a template parameter, the template parameters cannot be defined at runtime! (Prior to this update we were manually counting the components and hardcoding these values for the `runtime_engine`)

To do this, I created an abstraction for installing these components to the runtime called `Installers`.

TODO: DIAGRAM of installers , installing components for a specific tasks

## The Solution: Template Metaprogramming to the Rescue

By using variadic templates, parameter packs, and fold expressions, I was able to automatically calculate resource requirements and reduce boilerplate for component setup.

Here’s a simplified version of what I implemented:

### 🧩 1. The Common Interface

We define a base interface that every installer inherits from:

```cpp
template <size_t CooperativeCount, size_t ExclusiveCount>
class Installer {
public:
    static constexpr size_t CoopComponentCount = CooperativeCount;
    static constexpr size_t ExclusiveComponentCount = ExclusiveCount;

    virtual void create() = 0;
    virtual void configure() = 0;
    virtual void register_to_application(IRuntimeEngine& rte) = 0;
};
```

Each derived installer specifies how many cooperative and exclusive components it adds.

### 🧮 2. Aggregating Installer Counts

Instead of manually adding up component counts, I used a fold expression to do it at compile time:

```cpp
template <typename... Installers>
struct InstallerCounts {
    static constexpr size_t ExclusiveCount = (Installers::ExclusiveComponentCount + ... + 0);
    static constexpr size_t CoopCount = (Installers::CoopComponentCount + ... + 0);
    static constexpr size_t TotalCount = ExclusiveCount + CoopCount;
};
```

### 🔧 3. Declaring Installer Types

We define a list of all installer types using our `InstallerCounts` template:

```cpp
using CarInstallers = InstallerCounts<
    MercedesInstaller,
    SubaruInstaller,
    TeslaInstaller,
    RivianInstaller,
    GenericInstaller<Honda>,
    GenericInstaller<Toyota>,
    GenericInstaller<Lexus>
>;
```

This list is entirely type-based, so no objects are constructed here. Yet we can still use it to determine resource limits for the runtime engine before boot.

### 🚀 4. Static Limits in the Main Installer Class

This is the crucial compile-time win:

```cpp
class Installer_t {
public:
    static constexpr size_t MaxExclusiveComponentCount = CarInstallers::ExclusiveCount;
    static constexpr size_t MaxCoopComponentCount = CarInstallers::CoopCount;
    static constexpr size_t MaxComponentCount = CarInstallers::TotalCount;
    // ...
};
```

Thanks to our metaprogramming setup, `Installer_t` can expose its maximum system limits using only constexpr values! No dynamic computation, no runtime registration needed. The compiler does all the heavy lifting for us! :D

`Installers...` is a template parameter pack.

`(Installers::ExclusiveComponentCount + ... + 0)` is a fold expression over the + operator.

This allowed us to compute the total number of exclusive and cooperative components needed without writing a single line of summation logic ourselves or manually checking each component.

### 🔁 5. Consistent Component Installation

Installers are instantiated and wired in just a few lines, keeping setup DRY and testable:

```cpp

template <typename InstallerType>
void internal_setup(InstallerType& installer, IRuntimeEngine& runtime) {
    installer.create();
    installer.configure();
    installer.register_to_application(runtime);
}
```

```cpp
void install_components(IRuntimeEngine& runtime) {
    internal_setup(subaru_installer, runtime);
    internal_setup(mercedes_installer, runtime);
    internal_setup(honda_installer, runtime);
    internal_setup(tesla_installer, runtime);
    internal_setup(toyota_installer, runtime);
    // ...
}
```

### ✅ The Benefits

- **Compile-time validation:** All installer counts are determined statically, which allows for better sizing, validation, and compile-time asserts.

- **No runtime overhead:** All calculations happen before your code runs.

- **Clean and extensible:** Just add another installer type to the list and the counts are automatically updated.

### 💬 Final Thoughts

This approach showcases the power of modern C++ template programming. Variadic templates and fold expressions allow you to turn runtime configuration into compile-time guarantees — especially critical in embedded and safety-critical systems.

If your system has plugins, components, or services that follow a common structure, this technique scales beautifully and keeps your code maintainable and future-proof.

This keeps each installation consistent and clean. The main `install_components()` function just calls `internal_setup()` for each installer.

## Introduction

In C++, **variadic templates** refer to the feature that allows templates to accept a variable number of template arguments, while **parameter packs** are the mechanism used to represent and handle this variable list of arguments within the template. Essentially, variadic templates *use* parameter packs.

**Fold expressions**, introduced in C++17, provide a concise syntax for applying an operation to all elements of a parameter pack.

```cpp
// variadic template
template<typename... Args> // template parameter pack representing the types
void printAll(Args... args) { // function parameter pack representing the arguments
    auto total = (... + args);  // Fold expression over parameter pack    
    std::cout << "Sum = " << total << std::endl;
}

int main()
{
    // 1. Summing mixed numeric types:
    printAll(1, 2.5678, 3, 4.7f, 5);  // int, double, int, float, int
    // All get promoted to a common type and summed

    // 2. Real World example
    // Calculate total cost from different sources
    double basePrice = 99.99;
    double tax = 8.50;
    double shipping = 12.00;
    int discount = -10;
    printAll(basePrice, tax, shipping, discount);
    // Sum = 110.49
}
```
