### Rooms and Portals
# Introduction
The rooms and portals system is an optional component of Godot that allows you to partition your 3D game levels into a series of `Room`s (_aka cells_), and `Portal`s which are openings between the rooms that the `Camera` can see through.

This allows several features:
* Portal occlusion culling, which can increase performance by reducing the number of objects that are drawn
* Gameplay callbacks, allowing turning off activity outside the gameplay area

The trade off for these features is that we have to manually partition our level into rooms, and add portals between them.

### Some caveats
Note that the portal system should be considered an _advanced feature_ of Godot. You should not attempt to use rooms and portals until you are familiar with the Godot editor, and have successfully made at least a couple of test games. It gives you great power as a game designer, but the trade off is that it requires a very technical approach to level design. It is aimed at producing professional quality results, and assumes the user is prepared to put in the work for this. It is not intended to be used for all 3D games - not all will significantly benefit, and it may require more time than a short game jam allows.

## Visibility determination and Occlusion in 3D
One of the most difficult tasks in 3D has proved to be visibility determination. Or rather I should say, doing visibility determination _fast_.

Visibility determination is important because if we have to draw all the objects in a scene that are hidden behind other objects, it can take 10x as long (or more) to draw the scene. It is also important so we end up with the _correct_ result, the objects that are closest are seen, and occluded objects should be hidden.

Visibility determination is one of those tasks that appears obvious to a human, but turns out to be incredibly difficult for a computer to do efficiently. An analogous tasks would be something like entering a grocery store and buying some items. Something most humans can do without much thought, but would require a team of experts to achieve with a computer and robot.

### The Z Buffer
The fallback and most common technique used in the past few decades has been the z, or depth, buffer. The idea is incredibly simple. As we draw the triangles etc making up objects, as well as drawing the color into pixels, we also calculate and write the depth of each pixel, relative to the camera. When more than one triangle draws on a pixel, the pixel is only overwritten if the latter triangle is _closer_ than the triangles written before.

There are various optimizations that are used to try and speed this basic process up, such as only writing the color of the 'winning' triangle, but the gist of the method is as described.

In many ways the depth buffer is ideal. It calculates the occlusion for exact places we need it - the pixel locations, and doesn't calculate it where not required. It is simple to implement, and with appropriate optimization it can be _relatively_ fast.

### The problem with Z buffers
Of course there is a catch. The Z buffer works pretty well when you maybe have one or two occluded items. But what happens if instead of a few occluded items, you have thousands of occluded items, and each one writes to the z buffer, resulting in a huge amount of overdraw (and thus performance lost)?

The basic Z buffer is not very good at dealing with this problem.

### Raster Occlusion Culling
There are various techniques to try and improve this with a 'better' Z buffer, that allows faster testing for whole objects, or groups of objects. This is known as _raster occlusion culling_. Rejecting an entire object is far better than rejecting triangles on a pixel by pixel basis, as it is potentially a lot more efficient. Raster occlusion culling has only recently become a practical method due to advances in hardware and techniques.

## Geometric Occlusion Culling
There is on the other hand an entirely different way of dealing with occlusion. Instead of working with pixels (which can be expensive, because there are a lot of them!), what if we could use geometrical methods (some smart maths) to occlusion cull objects instead of doing all that brute force work?

It turns out there are a whole class of techniques available, which have historically been the foundation of most high performance games in the last 2-3 decades. The earliest reference I could find was the work of C.B. Jones, in 1971, with the paper "A new approach to the 'hidden line' problem".

Another landmark was Seth Teller's PhD in 1992 which went on to inspire Quake.

The basic idea was to partition the world (or game level) into a number of convex cells (_aka rooms_), with a series of portals that were windows that established visibility between the cells.
