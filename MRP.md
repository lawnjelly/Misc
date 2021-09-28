## What is a minimum reproduction project?

A MINIMUM reproduction project is a project that demonstrates the bug,
but contains no superfluous scenes, nodes, gdscript, addons, textures, models, animations, sounds etc.

That means, _there should be nothing present in your project that we could remove_, such that the bug would still exhibit.

### DO NOT include features that show off your skills, but that do not contribute to the bug report.
* This is absolutely not the time to show off your skills.
* The best MRPs are a few Kb, and contain e.g. a scene tree with a single node that demonstrates the problem, and NOTHING ELSE.
* Do not include elaborate control schemes for cameras / players, unless this is necessary to show the bug.
* If a mesh shows a bug, show us the bug in a mesh with 8 vertices, rather than 2000. This makes it easier to debug.

## Why do engine developers want only minimum reproduction projects?
* Primarily, the time of developers who are familiar with the engine is limited, and it is better for all of us that they spend it fixing bugs / adding features rather than trying to understand / simplify over elaborate issue projects. Time spent not fixing the bug is time wasted.
* A project which seems simple to you (because of familiarity) may take some time for a third party to understand, time which we do not have available.
* In practice in most cases non-minimum projects will result in your issue being ignored, or not fixed.

## DO NOT simply package your project that you are working on as an MRP.
You can do a lot of the job of bug fixing for us.

1) Make a note of what is going wrong
2) Try and identifying the area that is causing the problem

You have a choice, you can either try and reproduce the nodes concerned in a new project (which is often easiest).
Or, if you are not sure what is causing it:
* Copy your existing project (folders) to a new location
* load it up in the IDE
* begin removing nodes. Each time check whether the bug still exhibits.
* Keep removing features, until you have the simplest possible project. This is your MRP.
