# GPU Optimization
The GPU and / or communication with the GPU can often be bottlenecks. This is highly hardware specific, particularly mobile GPUs may struggle with scenes that are no problem for desktop.

GPU bottlenecks are slightly different to CPU, because often you can only change performance indirectly, by changing the instructions you give to the GPU.

## Drawcalls / state changes / API
Godot issues instructions to the GPU via a graphics API (OpenGL, GLES2, GLES3, Vulkan). The communication and driver activity involved can be quite costly, especially in OpenGL. Reducing the amount of drawcalls / state changes can greatly benefit performance. Using techniques such as 2D batching, and reducing the overall number of objects in a scene can help with this.

## Vertex Processing
Too many vertices in a scene can slow down rendering, especially on mobile. Skinned mesh vertices on animated models can be particularly slow in some cases. Reducing poly count or having different versions of models available can help with this.

## Pixels / Fill Rate
Each fragment or pixel that is shaded takes time (and costs in terms of battery use on mobile). Each access to textures within fragment shaders can also slow things down, as well as complicated shaders.

Transparency can particularly be problematic for fill rate because it can prevent some GPU optimizations (early Z), especially on mobile.

You can easily test whether you are fill rate limited - Simply render your scene to a postage stamp sized window, instead of the whole screen. If the frame rate increases, you are, to some extent, fill rate limited.

## Shaders

## Multiplatform / Mobile / Tile renderers
If you are aiming to release on multiple platforms, the best advice is to test early, and test often, on all your platforms, especially mobile. Developing a game on desktop then last minute attempting to port to mobile is a recipe for disaster.

In general you should design your game for the lowest common denominator, then add optional enhancements for more powerful platforms.

