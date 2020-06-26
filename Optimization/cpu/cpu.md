# CPU Optimization

## Measuring Performance
In order to know how to speed up our program, we have to know where the 'bottlenecks' are, the slowest parts that are limiting the rate that everything can progress. This allows us to concentrate our efforts on optimizing the areas which will give us the greatest speed improvement, instead of spending a lot of time optimizing functions that will lead to little if any improvement to performance.

For the CPU, the easiest way to identify bottlenecks is to use a profiler.

## CPU Profilers

Profilers run alongside your program as it runs, and take timing measurements in order to work out what proportion of time is spent in each function.

Godot IDE conveniently has a built in profiler. It does not run every time you start your project, and must be manually started and stopped. This is because, in common with most profilers, recording these timing measurements can slow down your project.

After profiling, you can look back at the results for a frame.

![godot profiler](images_cpu/godot_profiler.png)

_These are the results of a profile of one of the demo projects._

Note that we can see the cost of in built processes such as physics and audio, as well as seeing the cost of our own scripting functions at the bottom.

When a project is running slowly, you will often see an obvious function or process taking a lot more time than others. This is your primary bottleneck, and you can usually increase speed by optimizing this area.

## External Profilers

Although the Godot IDE profiler is very convenient and useful, sometimes you need more power, and the ability to profile the Godot engine source code itself.

You can use a number of third party profilers to do this, often free, including Valgrind, VerySleepy, Visual Studio and Intel VTune. Note that in order to use a third party profiler, you may need to compile the Godot engine from source, in order to have program database information available for the profiler. You can also use a debug build, however, note that the results of profiling a debug build will be different to a release build, because of optimizations in the latter. Simply put, bottlenecks are often in a different place in debug builds, so profiling release builds should be the gold standard.

![valgrind](images_cpu/valgrind.png)

_These are example results from Callgrind, part of Valgrind, on Linux._

From the left, Callgrind is listing the percentage of time within a function and its children (Inclusive), the percentage of time spent within the function itself, excluding child functions (Self), the number of times the function is called, the function name, and the file or module.

In this example we can see nearly all time is spent under the `Main::iteration()` function, this is the master function in the Godot source code that is called repeatedly, and causes frames to be drawn, physics ticks to be simulated, and nodes and scripts to be updated. A large proportion of the time is spent in the functions to render a canvas (66%), because in this example I was running a 2d benchmark. Below this we see that almost 50% of the time is spent outside Godot code in `libglapi`, and `i965_dri` (the graphics driver). This tells us the a large proportion of the time is being spent in the graphics driver.

This is actually an excellent example because in an ideal world, only a very small proportion of time would be spent in the graphics driver, and this is an indication that there is a problem with too much communication and work being done in the graphics API. This profiling lead to the development of 2d batching, which greatly speeds up 2d by reducing bottlenecks in this area.

## Manually timing functions
Another handy technique, especially once you have identified the bottleneck using a profiler, is to manually time the function or area under test. The specifics vary according to language, but in pseudocode, you would do the following:

```
var time_start = get_time()
...
... your_function
...
var time_end = get_time()
print("Function took " + (time_end - time_start)) 
```
I have deliberately left out the time units here, as this will vary.

When manually timing functions, it is usually a good idea to run the function many times (say 1000 or more times), instead of just once (unless it is a very slow function). A large part of the reason for this is that timers often have limited accuracy, and CPUs will schedule processes in a haphazard manner, so an average over a series of runs is more accurate than a single measurement.




## SceneTree

## GDScript

## c++

## Physics

## Threads

## SIMD


