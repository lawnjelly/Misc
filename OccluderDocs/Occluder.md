## Geometric Occluder Nodes

In addition to the Rooms & Portals, Godot also has the ability to use simple geometric occluders. These are geometric shapes that are invisible at runtime but show in the editor. Any object that is fully occluded by the shape (behind or in some cases inside) will be culled at runtime. They are designed to be simple to use and inexpensive at runtime, but the trade off is they may not be as effective at culling as rooms & portals. Nevertheless they can still significantly boost performance in some situations.

Another advantage to occluder nodes is that they are fully dynamic. For example if you place an occluder node as a child of a spaceship, it will move as you move the parent object.

The Occluder node itself is a holder for an OccluderShape resource, which determines the functionality. To get started, add an Occluder node to your scene tree. You will see a yellow warning triangle that lets you know that you must set an OccluderShape from the inspector before the Occluder becomes functional.

## OccluderShapeSphere
The sphere is one of the simplest and fastest occluders, and is easy to setup and position. The downside is that the sphere only tends to make sense in certain game level designs, and is more suited to terrain or organic background geometry.

Once you have added an OccluderNode and chosen to add a new OccluderShapeSphere in the inspector, click the OccluderShapeSphere in the inspector to bring up the parameters. Unlike many Nodes, the OccluderShapeSphere can store multiple spheres in the same object. This is more efficient in the engine, and keeps your SceneTree clearer. You don't have to store all your spheres in one Occluder as it could become tricky to manage, but it is perfectly reasonable to add 10 or so spheres or more. They are very cheap, and often the more you place, the better the match you will get to your geometry.

In order to store multiple spheres, they are stored as an Array. If you click on the Array in the inspector, you can increase the size of the Array to add one.

The sphere will appear as a small pink spherical object in the editor window (you can turn on and off the display of the Occluder gizmos in the View menu of the 3D viewport). There are two handles on each sphere. The larger middle handle enables you to move the sphere around in the local space of the Occluder, and the small handle enables you to adjust the radius.

Although you can change the position of the sphere using the Occluder Node transform in the inspector, this moves _the entire array_ of spheres. When you want to use multiple spheres in one occluder, the handles do this job. In order to allow positioning in 3D, the gizmo will only move the 3D position in the two principal axes depending on the viewpoint in the editor. This is easier for you to get the hang of by trying it out than by explanation.








