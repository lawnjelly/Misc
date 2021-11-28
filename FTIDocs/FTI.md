# Physics Interpolation

### Physics ticks and rendered frames
One key concept to understand in Godot is the distinction between physics ticks (sometimes referred to as iterations or physics frames), and rendered frames.

The physics proceeds at a fixed tick rate (set in project_settings/physics/common/physics_fps), which defaults to 60 ticks per second. However, the engine does not necessarily _render_ at the same rate. Although many monitors do refresh at 60 frames per second (fps), some refresh at different frequencies, especially high refresh rate monitors. And although a monitor may show a new frame e.g. 60 times a second, there is no guarantee that the CPU and GPU will be able to _supply_ frames at this rate. For instance, when running with vsync, the computer may be too slow for 60 and only reach the deadlines for 30fps, in which case the frames you see will change at 30fps.

But there is a problem here. What happens if the physics ticks do not coincide with frames? What happens if the physics tick rate is not a multiple of the frame rate? Or worse, what happens if the physics tick rate is _lower_ than the rendered frame rate?

This problem is easier to understand if we consider an extreme scenario. If you set the physics tick rate to 10 ticks per second, in a simple game with a rendered frame rate of 60fps. If we plot a graph of the physics tick against the rendered frames, you can see that the positions of objects will appear to "jump" every 1/10th of a second, rather than giving a smooth motion. When the physics calculates a new position for a new object, it is not rendered in this position for just one frame, but for 6 frames.

This jump can be seen in other combinations of tick / frame rate as glitches, or jitter, caused by this staircasing effect due to the discrepancy between physics tick time and rendered frame time.

## What can we do about this discrepancy?
### Lock the tick / frame rate together?
The most obvious solution is to get rid of the problem, by ensuring there is a physics tick that coincides with every frame. This used to be the approach on old consoles and fixed hardware computers. If you know that every player will be using the hardware, you can ensure it is fast enough to render at e.g. 50fps, and you will be sure it will work great for everybody.

Modern games are often no longer made for fixed hardware. You will often be planning to release on desktop computers, mobiles and more, all of which have huge variation in performance, as well as different monitor refresh rates. We need to come up with a better way of dealing with the problem.

### Adapt the tick rate?
Instead of designing the game at a fixed physics tick rate, we could allow the tick rate to scale according to the end users hardware. We could for example use a fixed tick rate that works for that hardware, or even vary the duration of each physics tick to match a particular frame duration.

This works but there is a problem - physics (and game logic, which is often also run in the `_physics_process`) work best and most consistently when run at a fixed, pre-determined tick rate. If you attempt to run a racing game physics that has been designed for 60tps at e.g. 10tps, the physics will behave completely differently. Controls may be less responsive, collisions / trajectories can be completely different. You may test your game thoroughly at 60tps, then find it breaks on end users machines when it runs at a different tick rate.

This can be extremely problematic for quality assurance purposes, especially for AAA games where problems of this sort can cost many millions of dollars.

### Lock the tick rate, but use interpolation to smooth frames in between physics ticks
This has become one of the two most popular approaches to dealing with the problem, and is automatically supported by Godot (although is optional).

We have established that the most desirable physics / game logic arrangement for consistency and predictability is a physics tick rate that is fixed at design time. The problem is the discrepancy between the physics position recorded, and where we "want" a physics object to be on a frame to give smooth motion.

The answer turns out to be simple, but can be a little hard to get your head around at first.

Instead of keeping track of just the current position of a physics object in the engine, we keep track of both the current position of the object, and the _previous position_ in the previous physics tick.

Why do we need the previous position (in fact the entire transform, including rotation and scaling)? Well by using a little maths magic we can interpolate what the position and rotation of the object would be between those two points.

The simplest way to understand this is linear interpolation, or lerping, which you may have used before. Let us consider only the position, and a situation where we know that the previous physics tick x coordinate was 0, and the current physics tick x coordinate is 16.

If our physics ticks are happening once per second (for this example), what happens if our rendered frame takes place at time 0.5 seconds? Well we can do a little maths to figure out where the object would be to obtain a smooth motion between the two ticks.

The x coordinate would be:
```
x = old_x + ((new_x - old_x) * 0.5)
```



