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

This works but there is a problem - 

