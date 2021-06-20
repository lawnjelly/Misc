# Rooms and Portals
## Introduction
The rooms and portals system is an optional component of Godot that allows you to partition your game levels into a series of rooms (aka cells), and portals which are openings between the rooms that the camera can see through.

This allows several features:
* Portal occlusion culling, which can increase performance by reducing the number of objects that are drawn
* Gameplay callbacks, allowing turning off activity outside the gameplay area

The trade off for these features is that we have to manually partition our level into rooms, and add portals between them.

## Rooms
### What is a room?
Rooms often literally are rooms (for instance in a building), but ultimately as far as the engine is concerned, a room are just convex volumes in the scene tree that you place most of your objects within. A room doesn't need to correspond to a literal room, it could also be for example, a canyon in an outdoor area, or a smaller part of a concave room.

### Why convex?
The reason why rooms are defined as convex volumes (or hulls), is that mathematically it is very easy to determine whether a point is within a convex hull. A simple plane check will tell you the distance of a point from a plane. If a point is behind all the planes bounding the convex hull, then by definition, it is inside the room. This makes all kinds of things easier in the internals of the system, like checking which room a Camera is within.

