# Dev snapshot: Godot 3.6 beta 5

It has been a while since our last beta, and admittedly 3.6 seems to have been in development *for ever* (beta 1 was over a year ago!).

There are fewer developers now working on 3.x branch, and Remi's time has been largely monopolized by the huge growth in contributors to 4.x, and the consequent increase in his workload. For this reason we have been trying to get maintainers more actively involved in release management, which is allowing enthusiasts to take on more of the work and get everything running in a more efficient manner.

This is great news for Godot 3, as it means in the future we will be more efficiently be able to address bugs, improve performance, and add new features, to keep Godot 4's baby brother as a force to be reckoned with.

This beta represents feature freeze for 3.6. We will now concentrate on bug fixing until we reach stable. Any new features will be scheduled for 3.7.

### Caution

There have been a *lot* of changes in 3.6, so as always with beta versions we advise you to work on a copy of your project when loading in beta 5, just in case there are problems.

## Highlights

Although beta 1, beta 2, beta 3 and beta 4 contained many 2D features, beta 5 adds a number of 3D features so there is something for everyone:

### Tighter Shadow Culling
https://github.com/godotengine/godot/pull/84745

Godot shadow mapping involves taking a simplified camera shot from the point of view of each shadow casting light, when objects move within this light volume. This happens every frame when objects are moving, and this can add up to a lot of drawcalls for each light.

Tighter shadow culling reduces this workload considerably by eliminating drawcalls for shadow casters that cannot cast a shadow upon the main camera view. This involves some clever geometry, but the upshot is you will often see significantly faster frame rates when using shadows.

This happens automatically.

### Discrete Level of Detail (LOD)
https://github.com/godotengine/godot/pull/85437

The new LOD node provides simple but powerful LOD capabilities, allowing the engine to automatically change visual representation of objects based on the distance from the camera. An example would be simplifying trees in the distance in open world games.

### Mesh Merging
https://github.com/godotengine/godot/pull/61568

https://docs.godotengine.org/en/3.6/tutorials/3d/merge_groups.html

Two years in the making, Godot 3.6 now offers a comprehensive system for mesh merging, both at design time and at runtime. OpenGL can be severely bottlenecked by drawcalls and state changes when drawing lots of objects. Now you can blast through these barriers and potentially render any number of similar objects in a single drawcall.

As well as allowing you to optimize existing maps and moving objects, this also makes new procedural game types possible, as thousands of procedurally placed objects can be merged at runtime so as to render efficiently (think vegetation, rocks, furniture, houses etc).

### ORM Materials
https://github.com/godotengine/godot/pull/76023

Ansraer adds support for ORM materials, which is a standard format where occlusion, roughness and metallic are combined into a single texture. This means these standard PBR textures can be used without modification, rendering performance will likely be increased where they are used (compared to the old workflow).

### Vertex cache optimization
https://github.com/godotengine/godot/pull/86339

In the mesh import options (e.g. obj, dae) you will find a new setting for "vertex cache optimization".
This is an ancient technique to speed up rendering of high poly meshes. It works by rearranging mesh indices in order to take advantage of vertex caching on the GPU.

GPUs have admittedly changed quite a bit since this technique was originally introduced, but testing indicates it still provides significant performance benefit on low end GPUs (although there may be no change to performance on high end GPUs, it is still worth doing so that your low end users will benefit).

In order to take advantage of vertex cache optimization in an already completed project, simply delete the hidden ".godot" folder (which contains imported data), and this imported data (including optimized meshes) will be recreated next time you open the editor.

### View Selected Mesh Stats
https://github.com/godotengine/godot/pull/88207

The 3D view menu now offers a new (long overdue) option, "view selected mesh stats". This will display total triangle counts, vertex counts and index counts for the selected meshes (and multimeshes).

This is incredibly useful information for diagnosing performance and checking imported meshes, and use in conjunction with mesh merging and LOD.

## 2D
Fixes to physics interpolation, and hierarchical culling, as well as performance increases.

