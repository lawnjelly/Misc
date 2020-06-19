# General Optimization
## Introduction
In an ideal world, computers would run at infinite speed, and the only limit to what we could achieve would be our imagination. In the real world, however, it is all too easy to produce software that will bring even the fastest computer to its knees.

Designing games and other software is thus a compromise between what we would like to be possible, and what we can realistically achieve while maintaining good performance.

To achieve the best results, we have two approaches:
* Work faster
* Work smarter

And preferably, we will use a blend of the two.

### Smoke and Mirrors

Part of working smarter is recognising that, especially in games, we can often get the player to believe they are in a world that is far more complex / interactive / graphically exciting than it really is (under the hood). A good programmer is somewhat akin to a magician, and should strive to learn the tricks of the trade, and try to invent new ones.

### The nature of slowness
To the outside observer, performance problems are often lumped together. But in reality, there are several different kinds of performance problem:

* A slow process that occurs every frame, leading to a continuously low frame rate
* An intermittent process that causes 'spikes' of slowness, leading to stalls
* A slow process that occurs outside of normal gameplay, for instance, on level load

Each of these are annoying to the user, but in different ways.

## Measuring Performance

Probably the most important tool for optimization is the ability to measure performance - to identify where bottlenecks are, and to measure the success of our attempts to speed them up.

There are several methods of measuring performance, including :
* Putting a start / stop timer around code of interest
* Using the Godot profiler
* Using external third party profilers
* Using GPU profilers / debuggers
* Frame rate

You can also use detective work to find out where bottlenecks are.

### Detective work
Detective work is a crucial skill for developers (both in terms of performance, and also in terms of bug fixing). This can include hypothesis testing, and binary search.

While other techniques such as profiling are usually preferable, profiling may not always be available (for instance when the bottleneck is within the GPU, or on a mobile phone).

#### Hypothesis testing
Say for example you believe that sprites are slowing down your game. You can test this hypothesis for example by:
* Measuring the performance when you add more sprites, or take some away.

This may lead to a further hypothesis - does the size of the sprite determine the performance drop?
* You can test this by keeping everything the same, but changing the sprite size, and measuring performance

#### Binary search
Say you know that frames are taking much longer than they should, but you are not sure where the bottleneck lies. You could begin by commenting out approximately half the routines that occur on a normal frame. Has the performance improved more or less than expected?

Once you know which of the two halves contains the bottleneck, you can then repeat this process, until you have pinned down the problematic area.

## Profilers
Profilers generally allow you make a timing run of your program (or sections of it), then provide results telling you what percentage of time was spent in different functions and areas, and how often functions were called.

Godot profiler screenshot

Callgrind screenshot

This can be very useful both to identify bottlenecks and to measure the results of your improvements. Sometimes attempts to improve performance can backfire and lead to slower performance, so always use profiling and timing to guide your efforts.

## Principles

#### Knuth
> Programmers waste enormous amounts of time thinking about, or worrying about, the speed of noncritical parts of their programs, and these attempts at efficiency actually have a strong negative impact when debugging and maintenance are considered. We should forget about small efficiencies, say about 97% of the time: premature optimization is the root of all evil. Yet we should not pass up our opportunities in that critical 3%.

_Donald Knuth_

This famous quote is a great one, because it does contain some important lessons, but in some ways it is misleading, as I will get to later.

The message is very important: Programmer / Developer time is limited. Intead of blindly trying to speed up all aspects of a program we should concentrate our efforts on the aspects that really matter. The other point is equally valid - efforts at optimization often end up with code that is harder to read and debug than non-optimized code. It is in our interests to limit this to areas that will really benefit.

The problematic bit, is that people tend to focus on the subquote `premature optimization is the root of all evil`. While _premature_ optimization is (by definition) undesirable, I would qualify this by pointing out an opposite point, that _the root of performant software is performant design_.

#### Performant Design
The problem with encouraging people to ignore optimization until necessary, is that the most important time to consider optimization is in the design stage, before a key has even hit a keyboard. If the design / algorithms of a program is inefficient, then no amount of polishing the details will make it run fast. It may run _faster_, but it will never run as fast as a program designed for performance.

This is far more important in game / graphics programming than in more general programming.

Of course, in practice, unless you have prior knowledge, you are unlikely to come up with the best design first time. So you will often make a series of versions of a particular area of code, each taking a different approach to the problem, until you come to a satisfactory solution.

#### Knuth
#### Low hanging fruit
#### The process
#### Algorithms
#### Data structures
#### Routines



#### Continuous and spikes
#### CPU / GPU / OS

## Profiling
#### Within Godot
#### External tools

## Bottlenecks
#### Bottleneck math
#### Examples


## CPU
#### Threads
#### GDNative / c++

## GPU
#### Drawcalls / API
#### Vertex processing
#### Pixels / Fillrate
#### Platform Specific
#### Mobile / Tile renderers
Battery use

### Links
* 3D Optimization
* 2D Batching

