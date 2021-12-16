# Issue reporting and Reproducing Issues

In order to identify and solve bugs, rather than just a description of the problem, the engine developers need an example project that they can debug to see what is going wrong.

Normally you will discover a bug when working on your own project, which may be large and complex.

There are two problems here:

1) You may not want to post your work in progress game into a github issue. It may not be open source, and you may not want critical eyes looking over something that is a work in progress, or it may simply be too big. This is totally understandable.

2) If you did post your entire project, it would likely contain a whole load of code / assets that had nothing to do with the bug, but came along for the ride. This can make it incredibly difficult for the engine developers to work with.

The solution we prefer to use for these problems is the "minimal reproduction project".

## Minimal Reproduction Projects

Strictly speaking, by definition, a minimal reproduction project is a project that demonstrates the bug, and does _nothing else_. The easiest to work with MRPs contain no superfluous scenes, nodes, gdscript, addons, textures, models, animations, sounds etc.

This follows the adage "perfection is achieved not when there is nothing more to add, but when the is nothing left to take away".

Ideally _there should be nothing present in your project that we could remove_, such that the bug would still exhibit.

* The best MRPs are a few Kb, and contain e.g. a scene tree with a single node that demonstrates the problem, and nothing else.
* Try not to include elaborate control schemes for cameras / players, unless this is necessary to show the bug.
* If a mesh shows a bug, show us the bug in a mesh with 8 vertices, rather than 2000.
* Try not to include animations if they are not part of the bug.

## Why do engine developers prefer minimal reproduction projects?
* Primarily, it is much easier to work out what is going on in a minimal reproduction project.
* A medium sized project which seems simple to you (because of familiarity) could take hours for a third party to understand.
* The time of developers who are familiar with the engine is limited, and it is better for everyone that they spend it fixing bugs / adding features rather than trying to understand / simplify over elaborate issue projects. Time spent not fixing the bug is time wasted.
* Issues with non-minimal projects may take longer to get fixed - simply because developers will tend to work on issues that are easier to reproduce first.
 
## Don't simply send the project that you are working on as an MRP
You can do a lot of the job of bug fixing before an engine developer sets eyes on it.

1) Make a note of what is going wrong
2) Try and identifying the area that is causing the problem

Now you have a choice, you can either try and reproduce the nodes concerned in a new project (which is often easiest).

Or, if you are not sure what is causing it:

* Copy your existing project (folders) to a new location.
* Load it up in the IDE.
* Begin removing nodes, functions, scripts, resources etc. Each time check whether the bug still exhibits (use undo / keep backups to help with this).
* Keep removing features, until you have the simplest possible project. This is your MRP.

## Engine development is a shared endeavour

This does require some time spent on your part - but recognise that Godot is developed as a _partnership_ between engine developers and game developers. We each depend on one another and by helping each other, where possible, it enables us all to do more. Good bug reports with good MRPs are invaluable contributions and can often go 9/10ths of the way towards fixing a bug.
