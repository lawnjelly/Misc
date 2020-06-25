# CPU Optimization

## CPU Profilers
The most important tool in any optimizers bag of tricks is the profiler. Profilers run alongside your program, and as your program runs, they take timing measurements in order to work out what proportion of time is spent in different functions, and different parts of the code.

The kind of results you will be looking for are illustrated on this diagram (from callgrind, a profiler for linux):
![valgrind](images_cpu/valgrind.png)

From the left, it is listing the percentage of time within a function and its children (Inclusive), the percentage of time spent within the function itself, excluding child functions (Self), the number of times the function is called, the function name, and the file.

In this example we can see nearly all time is spent under the `Main::iteration()` function, this is the master function in the Godot source code that is called repeatedly, and causes frames to be drawn, physics ticks to be simulated, and nodes and scripts to be updated. A large proportion of the time is spent in the functions to render a canvas (66%), because in this example I was running a 2d benchmark. Below this we see that almost 50% of the time is spent outside Godot code in `libglapi`, and `i965_dri` (the graphics driver). This tells us the a large proportion of the time is being spent in the graphics driver.

This is actually an excellent example because in an ideal world, only a very small proportion of time would be spent here, and this is an indication that there is a problem with too much communication and work being done in the graphics API. This profiling lead to the development of 2d batching, which greatly speeds up 2d by reducing bottlenecks in this area.

The easiest way to get started with profiling is to use the profiler in built in the Godot IDE. This is an ideal way to find out, for example, what part of your gdscript may be slowing 


## SceneTree

## GDScript

## c++

## Physics

## Threads

## SIMD


