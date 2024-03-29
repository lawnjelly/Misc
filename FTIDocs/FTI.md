# Physics Interpolation

### Quick Start Guide
* Turn on physics interpolation: `project_settings/physics/common/physics_interpolation`
* Make sure you move objects and run your game logic in `physics_process()` rather than `process()`
* Be sure to call `reset_physics_interpolation()` on nodes _after_ you first position them, to prevent "streaking"
* Temporarily try setting `project_settings/physics/common/physic_fps` to 10 to see the difference with and without interpolation

## Introduction
### Physics ticks and rendered frames
One key concept to understand in Godot is the distinction between physics ticks (sometimes referred to as iterations or physics frames), and rendered frames.

The physics proceeds at a fixed tick rate (set in project_settings/physics/common/physics_fps), which defaults to 60 ticks per second. However, the engine does not necessarily _render_ at the same rate. Although many monitors do refresh at 60 frames per second (fps), some refresh at different frequencies, especially high refresh rate monitors. And although a monitor may show a new frame e.g. 60 times a second, there is no guarantee that the CPU and GPU will be able to _supply_ frames at this rate. For instance, when running with vsync, the computer may be too slow for 60 and only reach the deadlines for 30fps, in which case the frames you see will change at 30fps.

But there is a problem here. What happens if the physics ticks do not coincide with frames? What happens if the physics tick rate is not a multiple of the frame rate? Or worse, what happens if the physics tick rate is _lower_ than the rendered frame rate?

This problem is easier to understand if we consider an extreme scenario. If you set the physics tick rate to 10 ticks per second, in a simple game with a rendered frame rate of 60fps. If we plot a graph of the physics tick against the rendered frames, you can see that the positions of objects will appear to "jump" every 1/10th of a second, rather than giving a smooth motion. When the physics calculates a new position for a new object, it is not rendered in this position for just one frame, but for 6 frames.

![](FTI1.png)

This jump can be seen in other combinations of tick / frame rate as glitches, or jitter, caused by this staircasing effect due to the discrepancy between physics tick time and rendered frame time.

## What can we do about this discrepancy?
### Lock the tick / frame rate together?
The most obvious solution is to get rid of the problem, by ensuring there is a physics tick that coincides with every frame. This used to be the approach on old consoles and fixed hardware computers. If you know that every player will be using the same hardware, you can ensure it is fast enough to render at e.g. 50fps, and you will be sure it will work great for everybody.

Modern games are often no longer made for fixed hardware. You will often be planning to release on desktop computers, mobiles and more, all of which have huge variation in performance, as well as different monitor refresh rates. We need to come up with a better way of dealing with the problem.

### Adapt the tick rate?
Instead of designing the game at a fixed physics tick rate, we could allow the tick rate to scale according to the end users hardware. We could for example use a fixed tick rate that works for that hardware, or even vary the duration of each physics tick to match a particular frame duration.

This works but there is a problem - physics (and game logic, which is often also run in the `_physics_process`) work best and most consistently when run at a fixed, pre-determined tick rate. If you attempt to run a racing game physics that has been designed for 60tps at e.g. 10tps, the physics will behave completely differently. Controls may be less responsive, collisions / trajectories can be completely different. You may test your game thoroughly at 60tps, then find it breaks on end users machines when it runs at a different tick rate.

This can be extremely problematic for quality assurance purposes, especially for AAA games where problems of this sort can cost many millions of dollars.

### Lock the tick rate, but use interpolation to smooth frames in between physics ticks
This has become one of the most popular approaches to dealing with the problem, and is automatically supported by Godot (although is optional).

We have established that the most desirable physics / game logic arrangement for consistency and predictability is a physics tick rate that is fixed at design time. The problem is the discrepancy between the physics position recorded, and where we "want" a physics object to be on a frame to give smooth motion.

The answer turns out to be simple, but can be a little hard to get your head around at first.

Instead of keeping track of just the current position of a physics object in the engine, we keep track of both the current position of the object, and the _previous position_ in the previous physics tick.

![](FTI2.png)

Why do we need the previous position (in fact the entire transform, including rotation and scaling)? Well by using a little maths magic we can interpolate what the position and rotation of the object would be between those two points.

The simplest way to understand this is linear interpolation, or lerping, which you may have used before. Let us consider only the position, and a situation where we know that the previous physics tick x coordinate was 0, and the current physics tick x coordinate is 16.

If our physics ticks are happening once per second (for this example), what happens if our rendered frame takes place at time 0.5 seconds? Well we can do a little maths to figure out where the object would be to obtain a smooth motion between the two ticks.

The x coordinate would be:
```
x = x_prev + ((x_curr - x_prev) * 0.5)
```
Let me break that down a bit.
* We know the x starts from the coordinate on the previous tick (x_prev)
* We know that after the full tick, the difference between the current tick and the previous tick will have been added (x_curr - x_prev)
* The only thing we need to vary is the proportion of this difference we add, according to how far we are through the physics tick

This last proportion or fraction is known as the `physics_interpolation_fraction`, and is handily available in Godot via the `Engine.get_physics_interpolation_fraction()` funcion. In this case we are at 0.5 seconds through a 1 second physics tick, so our interpolation fraction is quite simply `0.5/1.0`, which is handily also 0.5!

Although this example uses the position, the same thing can be done with the rotation and scale of objects. It is not necessary to know the details of this as Godot can do all this for you.

### Smoothed transformations between physics ticks?
Putting all this together shows that it should be possible to have a nice smooth estimation of the transform of objects between the current and previous physics tick. But wait, you may have noticed something. If we are interpolating between the current and previous ticks, we are not estimating the position of the object _now_, we are estimating the position of the object in the past. To be exact, we are estimating the position of the object _between 1 and 2 ticks_ into the past.

### In the past
What does this mean? This scheme does work, but it does mean we are effectively introducing a delay between what we see on the screen, and where the objects _should_ be. In practice people are not very good at noticing this delay, or rather it is typically not _objectionable_. There are already significant delays involved in games, we just don't typically notice them. The most significant effect is there can be a slight delay to input, which can be a factor in fast twitch games. In some of these fast input situations you may wish to turn off physics interpolation and use a different scheme, or use a high tick rate, which mitagates these delays.

### Why look into the past? Why not predict the future?
There is another simple alternative to this scheme, which is instead of interpolating between the previous and current tick, we use maths to _extrapolate_ into the future, i.e. try to predict where the object _will be_, rather than show it where it was. This can be done and may be offered as an option in future, but there are some significant downsides.
* The prediction may not be correct, especially when an object collides with another object during the physics tick.
* Where a prediction was incorrect, the object may extrapolate into an "impossible" position, like inside a wall.
* Providing the movement speed is slow, these incorrect predictions may not be too much of a problem.
* When a prediction was incorrect, the object may have to jump or snap back onto the corrected path. This can be visually jarring.

In Godot this system is referred to as physics interpolation, but you may also hear it referred to as "fixed timestep interpolation", as it is interpolating between objects moved with a fixed timestep (physics ticks per second). In some ways the second term is more accurate, because it can equally well be used to interpolate objects that are not driven by physics.

## Incorporating physics interpolation into your game
This all sounds as though it could be very beneficial, but is theoretical, but how do we actually incorporate physics interpolation into a Godot game? Are there any caveats?

Physics interpolation is applicable in both 3D and 2D, the principles are the same but there are some slight differences, and extra considerations in 2D. For this reason there some 3D and 2D specifics.

We have tried to make the system as easy to use as possible, and most existing games will work with little or even no significant changes. That said there are some situations which require special treatment, and these will be described.

### Turn on the physics interpolation setting
The first step is to turn on physics interpolation in `project_settings/physics/common/physics_interpolation`. You can now run your game. It is likely that nothing looks hugely different, particularly if you are running physics at 60 tps or a similar high tick rate, however quite a bit more is happening behind the scenes.

### Move (almost) all game logic from _process to _physics_process
The most fundamental requirement (which you may be doing already) is to make sure your scripts are running on the physics tick rather than the rendered frame. This means in most cases you should be putting code, for input, AI etc in `_physics_process` (which runs at a physics tick) rather than `_process` (which runs on a rendered frame). 

This ensures that you are applying movements etc to objects on physics ticks rather than rendered frames, and ensures all this will run the same whatever machine the game is run on. You can leave what happens on the _rendered frames_ to the physics interpolation, it will deal with that.

### Choose a physics tick rate
This is something that you may have never changed before, but when using physics interpolation, the rendering is decoupled from physics, and you can choose something that makes sense for your game.

As a rough guide:

#### Low tick rates (10-30)
* Give better CPU performance
* Add some delay to input
* Physics may not behave as well, except in simple scenarios
* Great for turn based games, strategy or RPGs

#### Medium tick rates (30-60)
* Gives good physics behaviour in complex scenes
* Good for first person games

#### High tick rates (60+)
* Good when physics behaviour is crucial to gameplay, especially with fast moving objects
* Racing games often use high tick rates

You can always change the tick rate as you develop, it is as simple as changing the project setting.

### Call reset_physics_interpolation when teleporting objects large distances
Although 99% of the time interpolation is what you want between two physics ticks, there is one situation in which it may _not_ be what you want. That is when you are initially placing objects, or moving them to a new location, when you do not want a smooth motion between the two, but an instantaneous move.

The solution to this is quite simple, each Node has a `reset_physics_interpolation()` function which you can call _after_ setting the position / transform. The rest is done for you automatically.

Even if you forget to call this, it is not usually a problem in most situations (especially at high tick rates), and is something you can easily leave to the polishing phase of your game. The worst that will happen is seeing a streaking motion for a frame or so when you move them - you will know when you need it!

Note: It is important to call `reset_physics_interpolation()` _after_ setting the new position, rather than before, otherwise you may still see the unwanted streaking motion.

## Special considerations for 2D
Although physics interpolation can be as useful in 2D as in 3D, there are some special situations where you may choose not to use physics interpolation.

### Snapping and pixel perfect retro games
Pixel perfect 2D games where the texels of sprites can be large on screen often utilize snapping to keep objects aligned to a pixel grid. When sprites move off a precise grid, you can get artifacts as fractional relative differences between sprites give a jiggling effect as they move.

Physics interpolation by nature involves fractional positions, and can throw objects off such a grid, resulting in these unwanted artifacts. So in many cases it can be better to disable physics interpolation in such games and use other approaches to deal with varying frame rates and hardware.

## Internet Multiplayer Games
Another category of games where you may choose not to use the in-built physics interpolation is multiplayer games.

Multiplayer games often receive tick or timing based information from other players or a server and must display them. The problem with packets received via the internet is that the timing and order in which they arrive can be quite different to when they were sent. The client machines often have to unscramble the packets, reorder them and make some sensible guess at how the scene should be displayed in a smooth manner.

The client machines are therefore not in control of timing, and the concept of physics ticks on the clients may not be the same as in a single player game. The interpolation needs can therefore be quite different, and in many cases this is better handled by a custom solution depending on the game.

## Conclusion
Although physics interpolation may not be suitable in _every_ case, it should however be the first option you try, especially for 3D games. In many cases it is a no-brainer - it involves very little specific coding or changes, and will often offer a _vastly_ better experience for end users, giving professional fluid gameplay on a wide variety of hardware.

# Tips
* Even if you intend to run physics at 60tps, in order to thoroughly test your interpolation and get the smoothest gameplay, it is highly recommended to temporarily set the physics tick rate to a low value such as 10tps. The gameplay may not work perfectly, but it should enable you to easily see cases where you should be calling `reset_physics_interpolation()`, or where you should be using your own custom interpolation on e.g. a Camera. Once you have these cases fixed, you can set the physics tick rate back to the desired setting.
* The other great advantage to testing at low tick rate is you can often notice other game systems that are synchronized to the physics tick and creating glitches which you may want to work around. Typical examples include setting animation blend values, which you may want to set in `process()` and possibly interpolate manually.

# Advanced

Although simply turning on physics interpolation, and a few calls to `reset_physics_interpolation()` will be all that are necessary for a gentle beginner introduction to physics interpolation, it is possible to go one step further, and make your game not just better, but "perfect". These advanced instructions are for those of you who want the best possible results.

### Exceptions to automatic physics interpolation
Even when you have physics interpolation switched on, there will be some situations where you would benefit from disabling automatic interpolation for a Node (or branch of the SceneTree), and have the finer control of performing interpolation manually. This is possible using the `set_physics_interpolated()` function which is present in all Nodes. If you for example, set this interpolated flag to false for a Node, all the children will recursively also be affected. This means you can easily disable interpolation for an entire subscene.

The most common situation where you may want to perform your own interpolation is Cameras.

## Cameras
Although in many cases a Camera can just use automatic interpolation just like any other node, for best results, especially at low physics tick rates, it is recommended that you take a manual approach to Camera interpolation.

This is because viewers are very sensitive to camera movement. A camera that realigns slightly every, say 1/10th of a second at 10tps tick rate will often be noticeable, and you can get a much smoother result by moving the Camera each frame in `_process`, and following an interpolated target.

### Manual Camera interpolation
#### Get that Camera off the Player!
The very first step when performing manual Camera interpolation should be to move the Camera from being a child of e.g. a player, to making sure it is specified in _global space_, with no moving nodes above it. Technically this is because it is really easy for feedback to occur between the movement of a parent node and the movement of the Camera, which has to compensate for interpolation.

You don't have to fully understand this, but you should change to this model of positioning the Camera independently on its own branch, rather than being a child of a moving object.

![](camera_worldspace.png)

#### Typical example
A typical example of a custom approach is to use the `look_at` function in the Camera every frame in `_process()` to look at a target node (for example the player).

But there is a problem. Given a target Node, if we use the traditional `get_global_transform()` to decide where the Camera should look, this transform will only give us the transform _at the current physics tick_. This is _not_ what we want, as the Camera will jump about on each physics tick as the target moves. Even though the Camera may be updated each frame, this does not help give smooth motion if the _target_ is only changing each physics tick.

#### get_global_transform_interpolated()
What we really want to focus the Camera on, is not the position of the target on the physics tick, but the _interpolated_ position, i.e. the position at which the target will be rendered. We can do this using the `get_global_transform_interpolated()` function. This acts exactly like `get_global_transform()` but it gives you the _interpolated_ transform (during a `_process()` call).

**Note:** `get_global_transform_interpolated()` should only be used once or twice for special cases such as Cameras. It should **not** be used all over the place in your code (both for performance reasons, and to give correct gameplay). In most cases your game logic should be in `_physics_process()` and should be calling `get_global_transform()`, which will give the current physics transform, which is usually what you will want for gameplay code.

#### Example manual Camera script
Here is an example of a simple fixed Camera which follows an interpolated target:
```
extends Camera

# Node that the camera will follow
var _target

# We will smoothly lerp to follow the target
# rather than follow exactly
var _target_pos : Vector3 = Vector3()

func _ready() -> void:
	# Find the target node
	_target = get_node("../Player")
	
	# Turn off automatic physics interpolation for the Camera,
	# we will be doing this manually
	set_physics_interpolated(false)


func _process(delta: float) -> void:
	# Find the current interpolated transform of the target
	var tr : Transform = _target.get_global_transform_interpolated()
	
	# Provide some delayed smoothed lerping towards the target position 
	_target_pos = lerp(_target_pos, tr.origin, min(delta, 1.0))
	
	# Fixed camera position, but it will follow the target
	look_at(_target_pos, Vector3(0, 1, 0))
```

#### Mouse look
Mouse look is a very common way of controlling Cameras. But there is a problem. Unlike keyboard input, the mouse is not polled at each physics tick. New mouse move events come in continuously, and the Camera will be expected to react and follow these on the next frame, rather than waiting until the next physics tick.

In this situation it can be better to disable physics interpolation for the Camera node (using `set_physics_interpolated()`) and directly apply the mouse input to the rotation in the camera `_process` function, rather than `_physics_process`.

Sometimes, especially with Cameras, you will want to use a combination of interpolation and non-interpolation:

* A first person camera may position the camera at a player location (perhaps using `get_global_transform_interpolated()`), but control the Camera rotation from mouse look _without_ interpolation.
* A third person camera may similarly determine the look at (target location) of the camera using `get_global_transform_interpolated()`, but position the camera using mouse look _without_ interpolation.

There are many permutations and variations of Camera types, but it should be clear that in many cases, disabling physics interpolation and handling this yourself in `_process` can give a better result.

### Why can any Node have physics interpolation disabled, why not just Cameras?
Although Cameras are the most common example, there are a number of cases when you may wish other nodes to control their own interpolation, or be non-interpolated. Consider another example, a player in a top view game whose rotation is controlled by mouse look. Disabling physics rotation allows the player rotation to match the mouse in realtime.
