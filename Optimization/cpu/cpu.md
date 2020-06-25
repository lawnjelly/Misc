# CPU Optimization

## CPU Profilers
The most important tool in any optimizers bag of tricks is the profiler. Profilers run alongside your program, and as your program runs, they take timing measurements in order to work out what proportion of time is spent in different functions, and different parts of the code.

The kind of results you will be looking for are illustrated on this diagram (from callgrind, a profiler for linux):
![valgrind](images_cpu/valgrind.png)
From the left, it is listing the percentage of time within a function and its children (Inclusive), the percentage of time spent within the function itself, excluding child functions (Self), the number of times the function is called, the function name, and the file.

The easiest way to get started with profiling is to use the profiler in built in the Godot IDE. This is an ideal way to find out, for example, what part of your gdscript may be slowing 


## SceneTree

## GDScript

## c++

## Physics

## Threads

## SIMD


