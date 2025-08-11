---
date: 2025-08-10 10:30:45 -0700
categories: [CMake,Presets,C++]
tags: [cmake,cmakepresets,build]
description: Make your CMake builds effortless with CMake Presets
image: 
  path: /assets/2025/july/DEBUG.png
  width: 700
  height: 500
---

### Build Configurations and Settings

Modern programs often need to be built in different configuration settings depending on the use case of the application. Each configuration may enable or disable certain features such as optimizations or debugging flags. Configurations can also be used to tell the program whether it needs to be built for Windows, Linux, or MacOS platforms. 

Some common configurations that I've used include:

- **Release**: The final optimized application executable that’s shipped to users.
- **Debug**: A version with debugging symbols, logging enabled, and tools for step-through development.
- **Test**: A build that includes unit tests for verifying software components.
- **Simulation**: A version that runs against mock or simulated inputs for creating a simulated work environment for program validation.

### My Previous Workflow

Here is the process that I would previously go through to build and compile my application. Lets say that I wanted to build my program in the  **Debug** configuration mode and pass it two debugging flags. I would do the following: 

```bash
$ mkdir build 
$ cd build
$ cmake .. -DCMAKE_BUILD_TYPE=Debug -DFLAG_A=ON -DFLAG_B=OFF ...
$ make -j
```

### The Issue? 🤔

In traditional CMake workflows, selecting one of these configurations meant manually passing a long list of variables and flags via the command line. For example, you'd specify the build type, enable certain modules, or define certain macros depending on your needs.

While this approach works, it quickly becomes error-prone and difficult to manage—especially as the number of configurations grows.

That's where **CMake presets** come in! 👍

## The Solution 🧑🏻‍🔬 : CMake Presets

I recently found the usefulness of CMake presets and how convenient they are for managing your different build configurations in one single file. 

- `CMakePresets.json` : The file in the root directory of our application that sets the stage for managing multiple build configurations (debug, release, unit test, simulation, etc.) and defining specific settings for each configuration.

---

### Example: A Simple `CMakePresets.json`

We see the power of CMake presets with all the different settings that we can pass to our program for a specific build.


```json
{
  "version": 3,
  "configurePresets": [
    {
      "name": "debug",
      "hidden": false,
      "generator": "Ninja",
      "description": "Debug build with logging",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug",
        "ENABLE_LOGGING": "ON"
      }
    },
    {
      "name": "simulation",
		  "description": "Simulation build with mock components",
		  "inherits": "debug",
		  "cacheVariables": {
		    "BUILD_TESTS": "ON",
		    "USE_MOCK_DRIVERS": "ON"
        }
	  },
    {
      "name": "release",
      "hidden": false,
      "generator": "Ninja",
      "description": "Optimized build for deployment",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release"
      }
    }
  ]
}
```
This allows us to view all the defined configurations and their settings in one location. Making this super convenient to add or remove options for each build!

- We can set different flags here for specific application settings via this `json` style structure. 
- We can add descriptions that we can easily view in VSCode with just a hover.

### Listing Available Presets

Once we’ve created the `CMakePresets.json` file in our root directory we can view the different preset configurations we just setup.

```bash
$ cmake --list-presets
"debug"        - Debug build with logging
"release"      - Optimized build for deployment
"simulation"   - Simulation build with mock components
```

![Alt text](/assets/2025/july/d2.png)


### Configuring the Project with a Preset

Now lets say we wanted to build our program in Debug mode, well now this becomes super trivial by passing the following command to the terminal.

```bash
$ cmake --preset debug
```

which replaces the old cmake workflow of passing manual flags like:

```bash
$ cmake .. -DCMAKE_BUILD_TYPE=Debug -DENABLE_LOGGING=ON ..etc
```

### Building the Project with a Preset

Once your application is configured in Debug mode, you can build it with:

```
$ cmake --build build/debug
[1/76] ...
[70/76] Linking CXX executable my_app.elf
Build files written to build/debug
```

The result application, configured for debugging, would be located in the `build/debug` directory.


### Why CMake Presets Are Better

CMake presets allow us to:

- Simplify workflow by placing different configuration settings in one presets file.
- Save toolchain paths and custom program flags
- Use the same presets in CI or local development
- Avoid typos , forgetting flags, or typing a large amount of CMake variables to pass into our program
- Make onboarding easier for teammates


### Best Practices I’ve Learned about CMake Presets

- CMake Presets are great for integrating into your CI pipelines and projects. They help create a clean configuration setup and help building for different plaforms.
- Be sure to use descriptive names for configurations like `release-x.y.z`, `debug-arm`, `test-sensorA-simulated`, etc.


## Conclusion 

CMake presets offer a clean modern way to manage build configurations and keep your projects organized.

I first came across them through MCU manufacturer generated CMake projects, and I’ve been hooked ever since. They’ve saved me time, reduced setup headaches, and made switching configurations a breeze.

If you’re not using CMake presets yet, now’s the perfect time to try them out. Integrating them into your workflow can make your CMake experience far smoother — especially if you juggle multiple build setups 🤹‍♂️!

Cheers ✌🏼,

Eduardo