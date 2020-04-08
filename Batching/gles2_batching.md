# GLES2 Renderer Optimization - 2D Batching

In terms of rendering, while reduz has been busily working on Vulkan, the rest of the rendering team have not been idle, with many bug fixes and improvements to the OpenGL rendering in the 3.x branch.

Soon we will be migrating this work to the 4.x branch, but for now at least some of the improvements will be available in 3.x.

One of the most eagerly awaited 2D features has been batching of drawcalls, and it is something myself and clayjohn have spent several weeks researching and coming up with a reasonable implementation, that should hopefully significantly increase performance in a lot of 2D games.

## How it works

Up until now, the 3.x branch has been drawing primitives (such as rectangles) on an individual basis. Each rectangle / polyon / line etc has been causing a drawcall to OpenGL. While GPUs can cope with this method, they don't work at top efficiency because they are optimized to handle larger numbers of primitives in each drawcall.

In order to take better take advantage of GPU horsepower, we set about organising (on each frame) these primitives into batches, each as large as possible, so that we could reduce the number of drawcalls, and the number of state changes between drawcalls, which are also expensive in performance terms.

After trying various approaches we have settled with a multi-pass approach:

1) The first pass identifies similar items and groups them into batches
2) The second pass draws each batch using a single drawcall

## Results

As predicted, even with the small added housekeeping costs, the batching greatly reduced bottlenecks in this area. Highly specific benchmarks focusing on drawcalls show large improvements in performance.

In real world games however, generally the speedup will depend on to what extent drawcalls are your bottleneck. Games drawing a lot of rects, particularly with high density or multiple tilemaps, or text, are likely to see the largest speedup. Let us know your results!

Even if you don't make large gains because your bottlenecks are elsewhere, note that you can often effectively bump up the amount of detail without adversely affecting performance. 

## How to try out the new build

Akien has kindly been making a series of test builds where we are trying to get as many people as possible to test on different hardware before we merge into the main 3.2.x branch.

Please try these out yourself, they are linked from the PR with many more details:

https://github.com/godotengine/godot/pull/37349

Let us know if it worked okay for your project, and if you discover any problems so we get onto fixing them. :)
