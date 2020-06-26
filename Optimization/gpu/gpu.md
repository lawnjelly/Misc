# GPU Optimization
The demand for graphical features and progress almost guarantees that you will encounter graphics bottlenecks. Some of these can be CPU side, for instance in calculations inside the Godot engine to prepare objects for rendering. Bottlenecks can also occur on the CPU in the graphics driver, which sorts instructions to pass to the GPU. And finally bottlenecks also occur on the GPU itself.

Where bottlenecks occur in graphics is highly hardware specific. Mobile GPUs in particular may struggle with scenes that run easily on desktop.

Understanding and investigating GPU bottlenecks is slightly different to the situation on the CPU, because often you can only change performance indirectly, by changing the instructions you give to the GPU, and it may be more difficult to take measurements. Often the only way of measuring performance is by examining changes in frame rate.

## Drawcalls / state changes / API
Godot issues instructions to the GPU via a graphics API (OpenGL, GLES2, GLES3, Vulkan). The communication and driver activity involved can be quite costly, especially in OpenGL. If we can provide these instructions in a way that is preferred by the driver and GPU, we can greatly increase performance.

Nearly every API command in OpenGL requires a certain amount of validation, to make sure the GPU is in the correct state. Even seemingly simple commands can lead to a flurry of behind the scenes housekeeping. Therefore the name of the game is reduce these instructions to a bare minimum, and group together similar objects as much as possible so they can be rendered together, or with the minimum number of state changes.

### 2d batching
In 2d in particular the costs of treating each item individually can be prohibitively high - there can easily be thousands on screen. This is why 2d batching is used - multiple similar items are grouped together and rendered in a batch, via a single drawcall, rather than making a separate drawcall for each item. In addition this means that state changes, material and texture changes can be kept to a minimum.

### 3d batching
In 3d we still aim to minimize drawcalls and state changes, however, it can be more difficult to batch together several objects into a separate drawcall. 3d meshes tend to comprise hundreds or thousands of triangles, and combining large meshes at runtime is prohibitively expensive. The costs of joining them quickly exceeds any benefits as the number of triangles grows per mesh. A much better alternative is to join meshes ahead of time (static meshes in relation to each other). This can either be done by artists, or programmatically within Godot.

There is also a cost to batching together objects in 3d. Several objects rendered as one cannot be individually culled. An entire city that is off screen will still be rendered if it is joined to a single blade of grass that is on screen. So attempting to batch together 3d objects should take account of their location and effect on culling. Often though the benefits of joining static objects will outweigh other considerations, especially for large numbers of low poly objects.

## Vertex processing
Historically, vertex processing could be a big bottleneck, which is why old games often featured low poly models. On modern hardware however, the costs of pixel and fragment processing have relatively become a far greater problem. Essentially - the number of triangles has increased, but the number of pixels to shade and the complexity of those shaders has increased to a far greater extent.

That said there are two exceptions to be aware of.
* Vertex processing in animated objects such as skeletal meshes and morphed meshs can be far more expensive than fixed meshes.
* Vertex processing on mobile GPUs (tile renderers) can be relatively a lot more expensive than desktop.

On mobile especially, having large numbers of triangles in a small screen area can slow down performance. Consider using low poly models or level of detail in this situation.


## Pixel / fragment shaders - fill rate
In contrast to vertex processing, the costs of fragment shading has increased dramatically over the years. Screen resolutions have increased (the area of a 4K screen is 8,294,400 pixels, versus 307,200 for an old 640x480 VGA screen, that is 27x the area), but also the complexity of fragment shaders has exploded. Physically based rendering requires complex calculations for each fragment.

You can test whether a project is fill rate limited quite easily. Turn off vsync to prevent capping the frames per second, then compare the frames per second when running with a large window, to running with a postage stamp sized window. Usually you will find the fps increases quite a bit using a small window, which indicates you are to some extent fill rate limited. If on the other hand there is little to no increase in fps, then your bottleneck lies elsewhere.

### Reading textures
The other factor in fragment shaders is the cost of reading textures. Reading textures is an expensive operation (especially reading from several in a single fragment shader), and also consider the filtering may add expense to this (trilinear filtering between mipmaps, and averaging). Reading textures is also expensive in power terms, which is a big issue on mobiles.

Compressed textures can greatly help with this problem, although be aware that in some cases on mobile you may not be able to use compression for textures with alpha (e.g. tranparency).



Each fragment or pixel that is shaded takes time (and costs in terms of battery use on mobile). Each access to textures within fragment shaders can also slow things down, as well as complicated shaders.

Transparency can particularly be problematic for fill rate because it can prevent some GPU optimizations (early Z), especially on mobile.

You can easily test whether you are fill rate limited - Simply render your scene to a postage stamp sized window, instead of the whole screen. If the frame rate increases, you are, to some extent, fill rate limited.

## Shaders

## Multiplatform / Mobile / Tile renderers
If you are aiming to release on multiple platforms, the best advice is to test early, and test often, on all your platforms, especially mobile. Developing a game on desktop then last minute attempting to port to mobile is a recipe for disaster.

In general you should design your game for the lowest common denominator, then add optional enhancements for more powerful platforms.

