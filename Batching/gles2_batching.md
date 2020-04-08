# GLES2 Renderer Optimization - 2D Batching

In terms of rendering, while reduz has been busily working on Vulkan, the rest of the rendering team have not been idle, with many bug fixes and improvements to the OpenGL rendering in the 3.x branch.

Soon we will be migrating this work to the 4.x branch, but for now at least some of the improvements will be available in 3.x.

One of the most eagerly awaited 2D features has been batching of drawcalls, and it is something me and clayjohn have spent several weeks researching and coming up with a reasonable implementation, that should hopefully significantly increase performance in a lot of 2D games.

## The problem

GPUs are very good at drawing large numbers of primitives (quads, triangles etc) in large batches, but when primitives are submitted one a time, causing a large number of drawcalls, GPU efficiency drastically drops. On top of this, state changes (such as changing texture, material etc) in between drawcalls can also be very expensive in terms of performance. As it happens the existing 2D renderer does just this, it submits primitives one by one.

_*The penalties for drawcalls and state changes are significantly lower in Vulkan. For these reasons different approaches are used in the Vulkan renderer._

## Solution

Inside the renderer, each primitive is effectively stored in a 'command', and one or several commands are stored in an 'item' (which in many cases equates to a node). Items can contain different transforms (where the primitives should be drawn on the screen), but commands all are placed using the transform of their container item:

PIC

### Commands
The first stage of batching was to join up similar consecutive commands into a batch so they could be rendered together, in one drawcall. This entailed making an extra first pass over commands to identify which could be joined, prior to rendering. In practice the benefits of the batching far outweighed the costs of this extra pass.

Command batching accelerates (amongst other things) tilemaps and text.

### Items
Batching together items proved far more difficult to find a good solution. In the end we went with an approach of adding an extra initial pass over the items to find those that were similar and so could be joined. Then the existing command renderer was modified to deal with joined items rather than single items.

#### Software transform
One consequence of joining items was that in most cases, items that could be joined were similar except for their transform. Normally we try and pass the transform of objects to be drawn separately to the GPU so that it can use hardware transformation, which in general is faster than transformation on the GPU.

However, in order to join these items (with different transforms) we had to use a different approach. Instead for these joined items we performed the transformation in software on the CPU (so that they all matched in coordinate space) prior to sending them to the GPU.

There is a small cost to this software transform, but it is vastly outweighed by the benefits of batching.

#### Dynamic versus Static batching
In real games, often there are areas that very rarely change from frame to frame. Perhaps a background tilemap, for example. In these cases it would be more efficient to make all these batching calculations once and reuse the information on subsequent frames. However, due to not wanting to modify the design outside the renderer, this was difficult to achieve, so for now these calculations are made every frame. We may be able to improve this in 4.0.

In practice though, I'm confident that the majority of batching gains will be made even without static batching.

## Test Build
Akien has kindly been making test builds prior to merging into 3.2, so we can try and iron out as many regressions as possible first. There are always the chance of regressions with such a major change.

The builds are linked from the PR here:
https://github.com/godotengine/godot/pull/37349

There are two types of regression we are particularly on the look out for

* Visual differences caused by logic bugs. For instance if we are joining items that should not be joined, you may see something in the wrong color.
* Hardware / driver issues. With OpenGL being quite a loose specification, there can be differences in how hardware responds to different usage patterns, particular the use of orphan buffers. If we do encounter problems, we can modify techniques to work on as high a range of hardware as is possible.

### How to use
You don't need to modify anything in your game to use the new build. Just start the engine, and run as normal. There are however several new options available in `projectsettings/rendering/gles2`.

* `use_batching` - turns batching on and off. You can use this to compare with the previous renderer to test for differences, and to measure performance improvements.
* `use_batching_in_editor` - only use this once you are confident it is working fine by running a project.
* `flash_batching` - in order to diagnose differences between the old and batched renderer, this will alternate between the two on alternate frames. Visual differences will indicate a regression. Note that this option will decrease performance significantly.
* `max_join_item_commands` - the best value may vary slightly in different games, but usually the default will be fine. A value of 0 will prevent joining items (and only allow batching commands). This is useful for diagnosing problems.
* `colored_vertex_format_threshold` - unless there are a large proportion of color changes between primitives, it can be more performant to use a smaller vertex format without color. This value is the ratio of color changes / number of vertices at which it changes between the two methods.
* `batch_buffer_size` - this is the maximum number of vertices that can be used in a single batch. Higher values require reserving more memory at runtime. You may be able to reduce this on mobile with little effect on performance.

#### Light Scissoring
Not directly related to the batching, there is now also one more performance option, `light_scissor_area_threshold`.
The GLES2 2D renderer draws lights by adding additional render passes on objects that touch the light. This can be quite expensive in terms of fill rate, particularly when for instance only one corner of a large object touches the light area.
Light scissoring can help alleviate the fill rate requirements by calculating only the intersecting area between the light and the object, and limiting rendering to that area only, using the GL_SCISSOR functionality of the GPU.
The default value of 1 is off, however, if you are using lights you are encouraged to try moving the slider towards 0 because you may be able to significantly increase performance in some situations.

## Benchmarks
These figures are based on my Linux desktop with integrated Intel HD Graphics 630. Exact numbers depend on the hardware and test. Desktops typically gain more than mobile, and these will repesent the upper range of gains available.

#### Joining commands only
In tests fully limited by the number of commands (e.g. large number of small text commands) on my performance is increased by around 58-80x.
#### Joining items only
In tests limited by a large number of items, each with a single command (e.g. large number of sprite nodes) performance is increased by 8-9x.

### Real World
The above benchmarks are designed to test batching gains in isolation. In real world games you are likely to see less extreme improvements.

In particular for sprite nodes, the costs within other parts of Godot increase dramatically once you start calling _process or _physics_process on them, so realistically you are unlikely to gain more than around 2.5x speed improvement for single primitive nodes, best case.

#### Realistic cases - How do bottlenecks work?

If your game is spending only 1% of the time making drawcalls, even if we speed up the batching 100%, you only have 1% of gain available. If on the other hand your game is spending 80% of time in drawcalls, you can see very large performance increases. You can either use profiling to examine this (a large amount of time spent in the graphics driver normally indicates API bottlenecks), or simple try out the build.

In practice the benefits of batching are more likely to be seen where you are using tilemaps, and large paragraphs of text. This is because these batch very efficiently.

In general, the greater the number of rects, the more will be the benefit. A tilemap at low density will likely not stress the GPU with drawcalls. However one with higher density, or overlapping tilemaps, or lights, can benefit significantly.

Even within render limited games, these can be bottlenecked by either geometry (i.e. batching), or fill rate (drawing pixels), or both. You can test whether a game is fill rate limited by reducing the size of the screen to a postage stamp. If the frame rate increases significantly it is fill rate limited. Fill rate limited games will see relatively less benefit from batching. This may partly explain why performance increases are typically higher on desktop than on mobile, as mobile is often fill rate limited.

## Future

Once we are happy that batching is working for everyone, the next stage will be to add batching for other primitives other than rect. These are typically used less in games but may help make the editor more efficient.

From there we can begin getting the new GLES2 renderer working in the 4.x branch alongside Vulkan, where there may be other opportunities to improve the overall design and feature set.
