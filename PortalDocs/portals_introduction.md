### Rooms and Portals
# Introduction
The rooms and portals system is an optional component of Godot that allows you to partition your 3D game levels into a series of `Room`s (_aka cells_), and `Portal`s which are openings between the rooms that the `Camera` can see through.

This allows several features:
* Portal occlusion culling, which can increase performance by reducing the number of objects that are drawn
* Gameplay callbacks, allowing turning off activity outside the gameplay area

The trade off for these features is that we have to manually partition our level into rooms, and add portals between them.

Godot `Portal`s should not be confused with those in the games of the same name. They do not warp space, they simply represent a window that the camera (or lights) can see through.

### Minimizing partitioning effort
Bear in mind with portalling that although the effort involved in creating rooms for a large level may seem daunting (particularly if you are a one person team!) there are several factors which can make this much easier:

* If you are 'kit bashing' and reusing rooms or areas already, this is an ideal way to save effort. Your level tiles can be `Room`s, with `Portal`s already placed.
* If you are creating procedural levels, you can create `Room`s and `Portal`s as part of the algorithm.
* And finally if you are manually creating freeform levels, bear in mind there are absolutely no rules as to how far you go with portalling. Even if you separate a large game level into only two `Room`s, with a single `Portal` between them, this can give a relatively large performance gain.

The benefits (especially in terms of occlusion) follow a classic L shaped curve, with the lions share occurring when you have created just a few `Room`s. So do not be afraid to be lazy - _work smart_.

In general, when it comes to medium / large sized levels, it is better to do a little portalling than none at all.

### Some caveats
Note that the portal system should be considered an _advanced feature_ of Godot. You should not attempt to use rooms and portals until you are familiar with the Godot editor, and have successfully made at least a couple of test games. It gives you great power as a game designer, but the trade off is that it requires a very technical approach to level design. It is aimed at producing professional quality results, and assumes the user is prepared to put in the work for this. It is not intended to be used for all 3D games - not all will significantly benefit, and it may require more time than a short game jam allows.
