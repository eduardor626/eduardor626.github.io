---
date: 2025-06-29 14:30:45 -0700
categories: [Programming,Career,C++,Templates]
tags: [templates]
description: The power of variadic templates and fold expressions for counting at compile time
image:
  path: /assets/2025/b1.png
  width: 700
  height: 600
---

## The Problem: Manual Tracking of Compile-Time Parameters
In a recent project, I faced the challenge of managing a growing number of components. Specifically, I needed to track **two** types of components at <u>compile time</u>:

- **Exclusive components** — bound to their own dedicated thread.

- **Cooperative components** — scheduled in a shared thread pool.

Initially, we were manually counting the number of each component and hardcoding the values into template parameters of a thread manager like this:

```cpp
// 8 = number of cooperative components
// 4 = number of exclusive components
// 12 = total component count
ThreadManager<8, 4, 12> thread_manager;
````

However, the above code is in violation of best practices, specifically: 
- The hardcoded values are magic numbers.
- Having a setup like this means adding a component requires updating these parameters manually.
    - Making this extremely error prone


Due to the constraints of this embedded application, the thread manager must be configured with its parameters at compile time rather than being dynamically created. This is because embedded systems often have strict limitations on memory, real-time responsiveness, and resource allocation. By determining thread parameters at compile time, we reduce runtime overhead, eliminate the need for dynamic memory allocation, and ensure deterministic behavior.

## The Solution: Let the Compiler Do the Math

![Alt text](/assets/2025/b1.png)

The magic happens with *variadic templates*, *constexpr*, and *fold expressions*, which allow us to sum the **cooperative** and **exclusive** components at <u>compile time</u>! Letting the compiler do the counting for us! 

Let’s walk through how this works.

## Step 1: Module Interface 🧩 

Every different module in the application must install its cooperative and or exclusive components into the thread manager. We can do so using an interface like the one below.

```cpp
template <size_t CooperativeCount, size_t ExclusiveCount>
class Module {
public:
    // number of each component for this Module
    static constexpr size_t CoopComponentCount = CooperativeCount;
    static constexpr size_t ExclusiveComponentCount = ExclusiveCount;

    virtual void create() = 0; // create the components
    virtual void configure() = 0; // configure the components (if necessary)
    virtual void install_to_app(ThreadManager& thread_manager) = 0; // install components to the thread manager
};
```

For example, we can have a `SensorModule` subclass responsible for installing all sensor related components. The sensor module requires 1 cooperative component and 2 exclusive components.


```cpp
static constexpr size_t SENSOR_COOPERATIVE_COUNT{1U};
static constexpr size_t SENSOR_EXCLUSIVE_COUNT{2U};
class SensorModule : public Module<SENSOR_COOPERATIVE_COUNT, SENSOR_EXCLUSIVE_COUNT> {
public:
    void create() override;
    void configure() override;
    void register_to_app(ThreadManager& thread_manager) override;
private:
    // components
};

```

## Step 2: Compile-Time Aggregation of Component Counts 🧮
Using a *parameter pack* of `Module` types, we can calculate total resource requirements at compile time by doing the following:

```cpp
// this takes the base type Module so that we can use all the derived types as well
template <typename... Module>
struct ModuleCounts {
    // since each Module has a templated component count associated with it, we can 
    // ask the compiler to do this for us
    static constexpr size_t CoopCount = (Module::CoopComponentCount + ... + 0);
    static constexpr size_t ExclusiveCount = (Module::ExclusiveComponentCount + ... + 0);
    static constexpr size_t TotalCount = CoopCount + ExclusiveCount;
};
```

- `template<typename... Module>` : tells the template that we're taking a pack of `Module` types for this `ModuleCounts` struct. 
- `(Module::CoopComponentCount + ... + 0)` : a C++17 feature (fold expression) that tells the compiler to expand the template parameter pack like this:
```cpp
Module1::Count + Module2::Count + Module3::Count + ...
```
- `static constexpr size_t` : guarantees that we'll know this value at compile time!

`ModuleCounts` is a type used to hold all the component counts of each Module. This will come in handy next.



## Step 3: Declaring All Module Modules 🔧 
Now that we've defined a type that allows us to sum all the components of a list of `Module`s, we can do something like this: 
```cpp
using Modules = ModuleCounts<
    SensorModule,
    CommunicationModule,
    LoggingModuleModule
>;
```
Where we create an alias and pass it a list of `Module` types for it to calculate component counts for. This list is purely type based, no runtime instances are ever created.


## Step 4: Static Limits for the Thread Manager 🚀 
Now, our thread manager can compute its limits statically!

```cpp
static constexpr size_t COOPERATIVE_COMPONENT_COUNT = Modules::CoopCount;
static constexpr size_t EXCLUSIVE_COMPONENT_COUNT = Modules::ExclusiveCount;
static constexpr size_t MAX_COMPONENT_COUNT = Modules::TotalCount;

ThreadManager<COOPERATIVE_COMPONENT_COUNT, EXCLUSIVE_COMPONENT_COUNT, MAX_COMPONENT_COUNT> thread_manager;
```
This eliminates manual counting entirely and ensures the limits are always correct.

## Why This Is Better? 🤔

- **Compile-time correctness**: All component counts are evaluated statically.

- **Zero runtime overhead:** No dynamic counting or allocation. 

- **Modular and maintainable:** Adding new modules is as easy as adding a new type to the `ModuleCounts` list.

- **Separation Of Concerns:** Each `Module` is responsible for knowing how many **cooperative** and **exclusive** components it owns. When you add a new Module you get the counting of it's components for free, without having to interact with the Module directly.

## Final Thoughts 🔚

These template techniques demonstrate the power of modern C++ metaprogramming. By using **constexpr** values for compile time variables, **variadic templates** for passing a list of types, and **fold expressions** for performing a computation on the list of types, we’ve eliminated boilerplate code and let the compiler do the work for us.

Our code is now more maintainable, correct, and way less error prone!







---
