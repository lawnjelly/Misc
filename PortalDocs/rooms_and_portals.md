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


