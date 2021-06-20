# Rooms and Portals
## Introduction
The rooms and portals system is an optional component of Godot that allows you to partition your game levels into a series of rooms (aka cells), and portals which are openings between the rooms that the camera can see through.

This allows several features:
* Portal occlusion culling, which can increase performance by reducing the number of objects that are drawn
* Gameplay callbacks, allowing turning off activity outside the gameplay area

The trade off for these features is that we have to manually partition our level into rooms, and add portals between them.

## The RoomManager
Anytime you want to use the portal system, you need to include a special node in your scene tree, called the `RoomManager`. The RoomManager is responsible for the runtime maintenance of the system, especially converting the objects in your rooms into a `room graph` which can be used at runtime to perform occlusion culling and other tasks.

This conversion must take place every time you want to activate the system, it does not store the `room graph` in your project (for flexibility and to save memory). You can either trigger it by pressing the `convert rooms` button in the editor when the `RoomManager` is selected, or you can call the `rooms_convert` function in the `RoomManager`. This latter method will be what you use in game.

If you convert the level while the editor is running, it is important to realise that the portal culling system will take over from the normal Godot frustum culling. This may affect some editor features. For this reason, you can turn the portal culling on and off, using the `Active` setting in the `RoomManager`.

## Rooms
### What is a room?
Rooms are a way of spatially partitioning your level into areas that make sense in terms of the level design. Rooms often quite literally *are* rooms (for instance in a building). Ultimately as far as the engine is concerned, a room respresents a convex volume, in which you would typically place most of your objects that fall within that area.

A room doesn't need to correspond to a literal room, it could also be for example, a canyon in an outdoor area, or a smaller part of a concave room.

### Why convex?
The reason why rooms are defined as convex volumes (or hulls), is that mathematically it is very easy to determine whether a point is within a convex hull. A simple plane check will tell you the distance of a point from a plane. If a point is behind all the planes bounding the convex hull, then by definition, it is inside the room. This makes all kinds of things easier in the internals of the system, like checking which room a Camera is within.

### How do I create a room?
A Room is a node type that can be added to the scene tree like any other. You would then place objects within the room by making them children and grand-children of the Room node.

However there is another way of creating rooms. In order to allow users to build levels almost entirely within modelling programs such as Blender, rooms can start life as `Spatial`s (or `Empties` in blender). As long as you use a special naming convention, the `RoomManager` will automatically convert these Spatials to Rooms during the conversion phase.

The naming convention is as follows:
* Prefix `Room_`
* Suffix should be the name you choose to give the room, e.g. `Lounge`, `Kitchen` etc.

E.g. `Room_Lounge`.

### How do I define the shape and position of my convex hull?
There are two ways of defining the shape of a room in Godot:
1) Provide a manual bound - a MeshInstance that has geometry in the shape of the desired bound, with a name prefixed by `Bound_`
2) Use the geometry of the objects contained within the room to automatically create an approximate bound

The first option is the most powerful, but it does involve a small amount of work in your modelling program (e.g. blender). On the other hand, for simple situations (especially regular shapes like boxes), you may successfully be able to use the automatic bound. Or you may use a combination, using automatic bounds for most rooms, and manual bounds for problem areas.

The automatic method is used whenever a manual bound is not supplied.

## Portals
If you create some rooms, place objects within them, then convert the level in the editor, you will the objects in the rooms appearing and showing as you move between rooms. There is one problem however! Although you can see the objects within the room that the camera is in, you can't see to any neighbouring rooms! For that we need portals.

Portals are special convex polygons, that you position over openings between rooms to allow the system to see between them. You can create a Portal node directly in the editor - it is really just a `MeshInstance` with some extra functions. Or like with rooms, you can create portals by making a MeshInstance (e.g. in Blender), and using a special naming convention.

Portals only need to be placed in one of each pair of neighbouring rooms (the 'source room') - the system will automatically make them two way unless you choose otherwise in the Portal settings.

The naming convention for portals is as follows:
* Prefix `Portal_`
* Optional : You can add a suffix of the room that the portal will lead to ('destination room'). E.g. `Portal_Kitchen`

The suffix is optional - in many cases the system can automatically detect the nearest room that you intended to link to and do this for you. It is usually only in problem areas you will need to use the suffix.

In rare cases you may end up with two or more portals that you want to give the same name, because they lead into the same destination room. But Godot does not allow duplicate names! The solution to this is the wildcard character `*`. If you place a wildcard at the end of the name, the rest of the characters will be ignored. E.g. `Portal_Kitchen*1`, `Portal_Kitchen*2`.

### Portal restrictions
Portals have some restrictions to work properly. They should be convex, and the polygon points should be in the same plane. The accuracy to the plane does not have to be exact, the system will automatically average the direction of the portal plane.

In practice, in many cases, and especially when beginning, it is sensible to use the Godot builtin `Plane` primitive which is part of `MeshInstance`. This can create rectangular portals only, but in many cases they will do the job.

## Trying it out
By now you should be able to create a couple of rooms, add some objects (regular `MeshInstance`s) within the rooms, and add portals between the rooms. Try converting the rooms in the editor, and see if you can now see the objects in neighbouring rooms, through the portals. Great success!

You have now mastered the basic principles of the system.

The next step is to look at the different types of objects that can be managed by the system.

## Portal mode
If you look in the inspector, every `MeshInstance` in Godot is derived from a `CullInstance`, where you can set a `PortalMode`. This determines how objects will behave in the portal system.

### STATIC
The default mode for objects is STATIC. Static objects are objects within rooms that will not move throughout the life of the level. Things like floors, walls, ceilings are good candidates for STATIC objects.
### DYNAMIC
Dynamic mode is for objects that are expected to move during the game. But there is a limitation - they must not move outside of their original room. These objects are handled very efficiently by the system. Examples might include moving platforms, and elevators.
### ROAMING
Roaming mode is for objects that can move between rooms. Things like players you will want to be roaming. These are more expensive to calculate than STATIC or DYNAMIC modes, because the system has to keep track of which room a roaming object is within.
### GLOBAL
Global mode is for objects that you don't want occlusion culled at all. Things like a main player's weapon, bullets and particle effects are good candidates for GLOBAL mode.
### IGNORE
Ignore is a special mode for objects that will be essentially free in the system. Manual bounds (`Bound_`) get converted to ignore portal mode automatically. They don't need to show up during the game, but are kept in the scene tree in case you need to convert the level multiple times (e.g. in the Editor). You might also choose to use this for objects that you only want to show up in the editor (when RoomManager is inactive).

### In rooms or not?
STATIC and DYNAMIC objects should always be placed within rooms - the system needs to know which room they are in during conversion as it assumes they will never change room. ROAMING and GLOBAL objects you are recommended to maintain in the scene tree outside of any rooms (their position can be inside the rooms, but in terms of the SceneTree they are better kept on their own branch). There are no restrictions on the placement of IGNORE objects.

### Object Lifetimes
At the time of writing, the lifetime of STATIC and DYNAMIC objects is tied to the lifetime of the level, between when you call `rooms_convert` to activate the portal system, and calling `rooms_clear` to unload the system. You should therefore not try to create or delete STATIC or DYNAMIC objects while the portal system is active. Doing so will cause the system to automatically unload because it is in an invalid state.

Other objects can be created and deleted as required.

Congratulations! You have now mastered the basic techniques required to use rooms and portals. You can use these to make games already, but there are many more features.

# Gameplay Callbacks
Although occlusion culling greatly reduces the number of objects that need to be rendered, there are other costs to maintaining objects in a game besides the final rendering. For instance, did you know that in Godot, animated objects will still be animated whether they appear on screen or not! This can take up a lot of processing power, especially for objects that use software skinning (where skinning is calculated on the CPU).

Fear not, rooms and portals can solve these problems, and more.

By building our system of rooms for our game level, not only do we have the information needed for occlusion culling, we also have handily created the information required to know which rooms are in the local 'gameplay area' of the player (or camera). If you think about it, in a lot of cases, there is no need to do a lot of simulation on objects that have nothing to do with gameplay.

The gameplay area is not confined to just the objects you can see in front of you. AI monsters behind you still need to attack you when your back is turned! In Godot the gameplay area is defined as the `potentially visible set` (PVS) of rooms, from the room you are currently within. That is, if there is any part of a room that can possibly be viewed from any part of the room you are in (even from a corner), it is considered within the PVS, and hence the gameplay area.

This works because if a monster is in an area that is completely out of view for yourself or the monster, you are less likely to care what it is doing.

### How does a monster know whether it is within the gameplay area?
This problem is solved because the portal system contains a subsystem called the `gameplay monitor` that can be turned on and off. When switched on, any roaming objects that move inside or outside the gameplay area (whether by moving themselves, or the player moving) will receive callbacks to let them know of this change.

You can choose to either receive these callbacks as signals, or as notifications.

Notifications can be handled e.g. in gdscript:
```
func _notification(what):
	match what:
		NOTIFICATION_ENTER_GAMEPLAY:
			print("notification enter gameplay")
		NOTIFICATION_EXIT_GAMEPLAY:
			print("notification exit gameplay")
```

Signals are sent just as any other signal, they can be attached to functions using the Editor Inspector. The signals are called `gameplay_entered` and `gameplay_exited`.
