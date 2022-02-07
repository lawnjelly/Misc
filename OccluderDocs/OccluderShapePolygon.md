## OccluderShapePolygon
The polygon occluder is a generalist, it can be made to work well in almost all situations, and can quickly provide a degree of occlusion culling to most game levels.
As with all geometric occluders, the key to success is to make them large. They do not have to match rendered geometry, and in many cases they will work better if you extend them past rendered geometry to make them as big as possible, without blocking legitimate lines of sight in other areas. The reason why they need to be large is that in general, they will only cull objects whose AABB is completely hidden by the polygon. For large objects to be culled, you need large occluders.

### Editing and details
Occluder polygons are edited as a list of points which define a _convex_ polygon, on a single plane. In order to confine the polygon to a single plane, the points are defined in 2D rather than 3D. The orientation and position of the polygon is taken instead from the transform of the Occluder Node.

If you create an Occluder and add to it a OccluderShapePolygon resource, by default it will create 4 starting points forming a rectangle. If you move the position and rotation of the Occluder Node you will see how the rectangle follows the node. When the Occluder is selected in the editor, handles will appear for each of the points. You can actually click and drag these handles, to match your polygon to the environment of your scene.

You are not restricted to 4 points, you can create many points, but note that:
* The editor will automatically sanitize your points to form a convex polygon. If you drag a point into a position that would form a concave polygon, it will be ignored.
* In general, the less edges (and thus points), the faster the polygon will work at runtime. A polygon with 6 edges will have to make twice the calculations of a polygon with 3 edges. In most cases 4 is a good number.

### Holes
