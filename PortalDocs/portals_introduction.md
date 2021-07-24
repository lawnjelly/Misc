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

Visibility determination is important because if we have to draw all the objects in a scene that are hidden behind other objects, it can take 10x as long (or more) to draw the scene.

Visibility determination is one of those tasks that appears obvious to a human, but turns out to be incredibly difficult for a computer to do efficiently. An analogous tasks would be something like entering a grocery store and buying some items. Something most humans can do without much thought, but would require a team of experts to achieve with a computer and robot.

