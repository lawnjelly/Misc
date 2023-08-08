# 2D Physics Interpolation (preliminary docs)

In general everything in the existing docs applies:
https://docs.godotengine.org/en/3.6/tutorials/physics/interpolation/index.html

## Differences from 3D physics interpolation
In 3D, physics interpolation is performed **INDEPENDENTLY** on the *global transform* of each 3D instance. In 2D by contrast, physics interpolation is performed on the *local transform* of each 2D instance. This is due to the architecture of the `VisualServer` and the methods available.

This has some implications:
* In 3D, it is easy to turn interpolation on and off at the level of each `Spatial`, via the `physics_interpolation_mode` property in the Inspector, which can be set to `ON`, `OFF`, or `INHERITED`.
* However this means that in 3D, pivots that occur in the scene tree (due to parent child relationships) can only be approximately interpolated over the physics tick. In most cases this will not matter, but in some situations the interpolation can look slightly "off".
* In 2D, interpolated local transforms are passed down to children during rendering. This means that if a parent is set to `physics_interpolation_mode` `ON`, but the child is set to `OFF`, the child will still be interpolated if the parent is moving. _Only the child local transform is uninterpolated._
* On the positive side, pivot behaviour in the scene tree is perfectly preserved during interpolation in 2D.


