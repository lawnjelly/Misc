### Rooms and Portals
# Intermediate
Normally, when you use Godot, all objects that you can see (`VisualInstance`s) are treated the same by the engine. The portal renderer is slightly different, in that it makes a distinction between the different roles objects will have in your game, in order to define the `Room`s, and in order to render and process everything in the most efficient way.

## Portal mode
If you look in the inspector, every `VisualInstance` in Godot is derived from a `CullInstance`, where you can set a `PortalMode`. This determines how objects will behave in the portal system.

![CullInstance](images/cull_instance.png)

### STATIC
The default mode for objects is STATIC. Static objects are objects within rooms that will not move throughout the life of the level. Things like floors, walls, ceilings are good candidates for STATIC objects.
### DYNAMIC
Dynamic mode is for objects that are expected to move during the game. But there is a limitation - they must not move outside of their original room. These objects are handled very efficiently by the system. Examples might include moving platforms, and elevators.
### ROAMING
Roaming mode is for objects that can move between rooms. Things like players you will want to be roaming. These are more expensive to calculate than STATIC or DYNAMIC modes, because the system has to keep track of which room a roaming object is within.
### GLOBAL
Global mode is for objects that you don't want occlusion culled at all. Things like a main player's weapon, bullets and particle effects are good candidates for GLOBAL mode.
### IGNORE
Ignore is a special mode for objects that will be essentially free in the system. Manual bounds (`Bound_`) get converted to ignore portal mode automatically. They don't need to show up during the game, but are kept in the scene tree in case you need to convert the level multiple times (e.g. in the Editor). You might also choose to use this for objects that you _only_ want to show up in the editor (when RoomManager is inactive).

### Should you place objects within rooms (in the scene tree) or not?
STATIC and DYNAMIC objects are ideally placed within rooms in the scene tree. The system needs to know which room they are in during conversion as it assumes they will never change room. Placing them within rooms in the scene tree allows you to explicitly tell the system where you want them.

### Autoplace
However, for ease of use, it is also possible to place STATIC and DYNAMIC objects _outside_ the rooms, but within the roomlist branch. The system will attempt to _autoplace_ the objects into the appropriate room. This works in most cases but if in doubt, use the explicit approach, especially when dealing with internal rooms, which have some restrictions for sprawling objects.

Note that if you place STATIC and DYNAMIC objects outside of rooms, they will not contribute to the room bound. So if you are using the room geometry to derive the bound, tables and chairs can be placed outside the room, but walls and floors should be explicitly within the Room branch of the scene tree, in order to ensure the bound is correct.

ROAMING and GLOBAL objects you are recommended to maintain in a branch of the scene tree outside of any rooms or the roomlist (their _can_ be placed inside the rooms, but to save confusion they are normally better kept on their own branch). There are no restrictions on the placement of IGNORE objects.

### Object Lifetimes
At the time of writing, the lifetime of STATIC and DYNAMIC objects is tied to the lifetime of the level, between when you call `rooms_convert` to activate the portal system, and calling `rooms_clear` to unload the system. You should therefore not try to create or delete STATIC or DYNAMIC objects while the portal system is active. Doing so will cause the system to automatically unload because it is in an invalid state. You can however, freely `show` and `hide` these objects.

The sequence should be therefore:
* Load your level
* Place any STATIC or DYNAMIC objects
* Then run `rooms_convert`.

Other objects can be created and deleted as required.

## Sprawling
Although users can usually ignore the internals of the portal system, they should be aware that it is capable of handling objects that are so big they end up in more than one room. Each object has a central room, but using the AABB or geometry the system can detect when an object extends across a portal into a neighbouring room / rooms. This is called `Sprawling`.

This means that if the corner of an object is showing in a neighbouring room, but the object's main room is not showing (e.g. a train where the end is in a different room), the object will not be culled. The object will only be culled if it is not present in any of the rooms that are visible.

### Portal Margins
It is hard to place objects exactly at the edges of rooms, and if we chose to sprawl objects to the adjacent room the moment a portal was crossed (even by a minute amount), there would be an unnecessary amount of sprawling, and more objects would be rendered than we need. To counter this, portals have an adjustable leeway, called a `margin` over which an object can cross without being considered in the next room. The margin is shown in the editor gizmo as a red translucent area.

You can set the margin globally in the `RoomManager`, and you can override this margin value in any `Portal` if you need to fine tune things. As you edit the margin values in the Inspector, you should see the margins change in the 3d window.

### Include in Bound
The support for objects that are larger than a single room has one side effect - you may not want to include some objects in the calculation of the automatic room bound. You can turn this off in the inspector - `CullInstance/IncludeInBound`.

While this works great for large moving objects, it also has the side effect of allowing you a lot more leeway in level design. You can for instance create a large terrain section and have it present in multiple rooms, without splitting up the mesh.

## Lighting
In general lights are handled like other objects. They can be placed in rooms, and they will sprawl to affect neighbouring rooms, according to the dimensions of the light. The exception to this is DirectionalLights. DirectionalLights have no source room as they affect _everywhere_. They should therefore not be placed in a `Room`. As DirectionalLights can be expensive, it is a good idea to turn them off when inside, see the `RoomGroup`s section below for more details on how to do this.

Congratulations! You have now mastered the intermediate techniques required to use rooms and portals. You can use these to make games already, but there are many more features.
