# Rooms and Portals
## Introduction
The rooms and portals system is an optional component of Godot that allows you to partition your game levels into a series of rooms (aka cells), and portals which are openings between the rooms that the camera can see through.

This allows several features:
* Portal occlusion culling, which can increase performance by reducing the number of objects that are drawn
* Gameplay callbacks, allowing turning off activity outside the gameplay area

The trade off for these features is that we have to manually partition our level into rooms, and add portals between them.

Note that some specific types of games may not offer many opportunities for occlusion culling, for example games with fixed top down view, or very small levels that do not stress the engine. However most other games with medium to large sized levels can benefit significantly, performance between 2-10x times faster is not uncommon, which can make the difference between a playable and unplayable game, especially on low power devices such as mobile.

## Index
* [The Basics](portals_basics.md)
* [Intermediate](portals_intermediate.md)
* [Advanced](portals_advanced.md)
* [Appendix](portals_appendix.md)

## Tutorials
* [Simple Tutorial](rooms_and_portals_tutorial_simple.md)
