## Physics Interpolation

One key concept to understand in Godot is the distinction between physics ticks (sometimes referred to as iterations or physics frames), and rendered frames.

The physics proceeds at a fixed tick rate (set in project_settings/physics/common/physics_fps), which defaults to 60 ticks per second. However, the engine does not necessarily _render_ at the same rate. Although many monitors do refresh at 60fps, some refresh at different frequencies, especially high refresh rate monitors. And although a monitor may show a new frame e.g. 60 times a second, there is no guarantee that the CPU and GPU will be able to _supply_ frames at this rate. For instance, when running with vsync, the computer may be too slow for 60 and only reach the deadlines for 30fps, in which case the frames you see will change at 30fps.

