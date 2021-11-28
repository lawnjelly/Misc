## Occluder Nodes

In addition to the Rooms & Portals, Godot also has the ability to use simple geometric occluders. These are geometric shapes that are invisible at runtime but show in the editor. Any object that is fully occluded by the shape (behind or in some cases inside) will be culled at runtime. They are designed to be simple to use and inexpensive at runtime, but the trade off is they may not be as effective at culling as rooms & portals. Nevertheless they can still significantly boost performance in some situations.

The Occluder node itself is a holder for an OccluderShape resource, which determines the functionality. To get started, add an Occluder node to your scene tree, then choose a new OccluderShape from the inspector.

## OccluderShapeSphere



