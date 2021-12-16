## Issue reporting and Reproducing Issues

In order to identify and solve bugs, rather than just a description of the problem, the engine developers need an example project that they can debug to see what is going wrong.

Normally you will discover a bug when working on your own project, which may be large and complex.

There are two problems here:

1) You may not want to post your work in progress game into a github issue. It may not be open source, and you may not want critical eyes looking over something that is a work in progress. This is totally understandable.

2) If you did post your entire project, it would likely contain a whole load of code / assets that had nothing to do with the bug, but came along for the ride. This can make it incredibly difficult for the engine developers to work with.

The solution we prefer to use for these problems is the "minimum reproduction project".

# Minimum Reproduction Project

Strictly speaking, by definition, a minimum reproduction project is a project that demonstrates the bug, but does _nothing else_. It should contain no superfluous scenes, nodes, gdscript, addons, textures, models, animations, sounds etc.

This follows the adage, that "perfection is achieved not when there is nothing more to add, but when the is nothing left to take away".

Ideally _there should be nothing present in your project that we could remove_, such that the bug would still exhibit.

### Try not to include features that show off your skills, but that do not contribute to the bug report.
* There can be a temptation to show off your skills. This is absolutely not the time to do it. In general the less flashy the MRP, the better.
* The best MRPs are a few Kb, and contain e.g. a scene tree with a single node that demonstrates the problem, and nothing else.
* Try not to include elaborate control schemes for cameras / players, unless this is necessary to show the bug.
* If a mesh shows a bug, show us the bug in a mesh with 8 vertices, rather than 2000.
* Don't include animations if they are not part of the bug.

## Why do engine developers prefer minimum reproduction projects?
* Primarily, the time of developers who are familiar with the engine is limited, and it is better for everyone that they spend it fixing bugs / adding features rather than trying to understand / simplify over elaborate issue projects. Time spent not fixing the bug is time wasted.
* A medium sized project which seems simple to you (because of familiarity) could take hours for a third party to understand, time which may not be available.
* In many cases non-minimum projects will result in your issue being treated as low priority, and as a result may be less likely to be fixed.

## In most cases you should not simply package the project that you are working on as an MRP.
You can do a lot of the job of bug fixing before an engine developer sets eyes on it.

1) Make a note of what is going wrong
2) Try and identifying the area that is causing the problem

Now you have a choice, you can either try and reproduce the nodes concerned in a new project (which is often easiest).

Or, if you are not sure what is causing it:

* Copy your existing project (folders) to a new location.
* Load it up in the IDE.
* Begin removing nodes. Each time check whether the bug still exhibits (and use undo / keep backups).
* Keep removing features, until you have the simplest possible project. This is your MRP.

## Engine development is a shared endeavour between engine developers and game developers.

This does require some time spent on your part - but recognise that Godot is developed as a _partnership_ between game developers and engine developers. We each depend on one another and by helping each other, where possible, it enables us all to do more. Good bug reports with good MRPs are invaluable contributions and can often go 9/10ths of the way towards fixing a bug.
