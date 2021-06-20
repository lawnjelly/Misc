# Rooms and Portals
## Introduction
The rooms and portals system is an optional component of Godot that allows you to partition your game levels into a series of rooms (aka cells), and portals which are openings between the rooms that the camera can see through.

This allows several features:
* Portal occlusion culling, which can increase performance by reducing the number of objects that are drawn
* Gameplay callbacks, allowing turning off activity outside the gameplay area

The trade off for these features is that we have to manually partition our level into rooms, and add portals between them.

## Rooms
### What is a room?
Rooms are a way of spatially partitioning your level into areas that make sense in terms of the level design. Rooms often quite literally *are* rooms (for instance in a building). Ultimately as far as the engine is concerned, a room respresents a convex volume, in which you would typically place most of your objects that fall within that area.

A room doesn't need to correspond to a literal room, it could also be for example, a canyon in an outdoor area, or a smaller part of a concave room.

### Why convex?
The reason why rooms are defined as convex volumes (or hulls), is that mathematically it is very easy to determine whether a point is within a convex hull. A simple plane check will tell you the distance of a point from a plane. If a point is behind all the planes bounding the convex hull, then by definition, it is inside the room. This makes all kinds of things easier in the internals of the system, like checking which room a Camera is within.

### How do I define the shape and position of my convex hull?
There are two ways of defining the shape of a room in Godot:
1) Provide a manual bound - a MeshInstance that has geometry in the shape of the desired bound
2) Use the geometry of the objects contained within the room to automatically create an approximate bound

