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
* Frame rate (with vsync disabled)

Be very aware that the relative performance of different areas can vary on different hardware. Often it is a good idea to make timings on more than one device, especially including mobile as well as desktop, if you are targetting mobile.

### Limitations
CPU Profilers are often the 'go to' method for measuring performance, however they don't always tell the whole story.
* Bottlenecks are often on the GPU, _as a result_ of instructions given by the CPU
* Spikes can occur in the Operating System processes (outside of Godot) _as a result_ of instructions used in Godot (for example dynamic allocation)
* You may not be able to profile e.g. a mobile phone
* You may have to solve performance problems that occur on hardware you don't have access to

As a result of these limitations, you often need to use detective work to find out where bottlenecks are.

### Detective work
Detective work is a crucial skill for developers (both in terms of performance, and also in terms of bug fixing). This can include hypothesis testing, and binary search.

#### Hypothesis testing
Say for example you believe that sprites are slowing down your game. You can test this hypothesis for example by:
* Measuring the performance when you add more sprites, or take some away.

This may lead to a further hypothesis - does the size of the sprite determine the performance drop?
* You can test this by keeping everything the same, but changing the sprite size, and measuring performance

#### Binary search
Say you know that frames are taking much longer than they should, but you are not sure where the bottleneck lies. You could begin by commenting out approximately half the routines that occur on a normal frame. Has the performance improved more or less than expected?

Once you know which of the two halves contains the bottleneck, you can then repeat this process within the bottleneck half, until you have pinned down the problematic area.

## Profilers
Profilers allow you make a timing run of your program (or sections of it), then provide results telling you what percentage of time was spent in different functions and areas, and how often functions were called.

This can be very useful both to identify bottlenecks and to measure the results of your improvements. Sometimes attempts to improve performance can backfire and lead to slower performance, so always use profiling and timing to guide your efforts.

## Principles of optimization

#### Donald Knuth:
> Programmers waste enormous amounts of time thinking about, or worrying about, the speed of noncritical parts of their programs, and these attempts at efficiency actually have a strong negative impact when debugging and maintenance are considered. We should forget about small efficiencies, say about 97% of the time: premature optimization is the root of all evil. Yet we should not pass up our opportunities in that critical 3%.

The messages are very important:
* Programmer / Developer time is limited. Intead of blindly trying to speed up all aspects of a program we should concentrate our efforts on the aspects that really matter.
* Efforts at optimization often end up with code that is harder to read and debug than non-optimized code. It is in our interests to limit this to areas that will really benefit.

Just because we _can_ optimize a particular bit of code, it doesn't necessarily mean that we should. Knowing when, and when not to optimize is a great skill to build up.

One misleading aspect of the quote is that people tend to focus on the subquote `premature optimization is the root of all evil`. While _premature_ optimization is (by definition) undesirable, I would counter this by pointing out that performant software is the result of performant design.

### Performant Design
The danger with encouraging people to ignore optimization until necessary, is that it conveniently ignores that the most important time to consider performance is at the start, in the design stage, before a key has even hit a keyboard. If the design / algorithms of a program is inefficient, then no amount of polishing the details later will make it run fast. It may run _faster_, but it will never run as fast as a program designed for performance.

This tends to be far more important in game / graphics programming than in general programming. A performant design, even without low level optimization, will often run many times faster than a mediocre design with low level optimization.

### Incremental Design
Of course, in practice, unless you have prior knowledge, you are unlikely to come up with the best design first time. So you will often make a series of versions of a particular area of code, each taking a different approach to the problem, until you come to a satisfactory solution. It is important not to spend too much time on the details at this stage until you have finalized the overall design, otherwise much of your work will be thrown out.

It is difficult to give general guidelines for performant design because this is so dependent on the problem space. One point worth mentioning though, on the CPU side, is that modern CPUs are nearly always limited by memory bandwidth. This has led to a resurgence in data orientated design, which involves designing data structures and algorithms for locality of data and linear access, rather than jumping around in memory.

### The Optimization Process
Assuming we have a reasonable design, and taking our lessons from Knuth, our first step in optimization should be to identify the biggest bottlenecks - the slowest functions, the low hanging fruit.

Once we have successfully improved the speed of the slowest area, it may no longer be the bottleneck. So we should test / profile again, and find the next bottleneck on which to focus.

The process is thus:
1) Identify bottleneck
2) Optimize bottleneck
3) Return to step 1

### Optimizing a Bottleneck
Some profilers will even tell you which part of a function (which data accesses, calculations) are slowing things down.

As with design you should concentrate your efforts first on making sure the algorithms and data structures are the best they can be. Data access should be local (to make best use of CPU cache), and it can often be better to use compact storage of data (again, always profile to test results). Often you can make use of precalculation to do heavy computation ahead of time (e.g. at level load, or loading precalculated data files).

Once algorithms and data is good, you can often make small changes in routines which improve performance, things like moving calculations outside of loops.

Always retest your timing / bottlenecks after making each change. Some changes will increase speed, others may have a negative effect. Sometimes a small positive effect will be outweighed by the negatives of more complex code, and you may choose to leave out that optimization.

## Appendix
### Bottleneck math
The proverb "a chain is only as strong as its weakest link" applies directly to performance optimization. If your project is spending 90% of the time in function 'A', then optimizing A can have a massive effect on performance.

```
A 9 ms
Everything else 1 ms
Total frame time : 10 ms
```

```
A 1 ms
Everything else 1ms
Total frame time : 2 ms
```
So in this example improving this bottleneck A by a factor of 9x, decreases overall frame time by 5x, and increases frames per second by 5x.

If however, something else is running slowly and also bottlenecking your project, then the same improvement can lead to less dramatic gains:

```
A 9 ms
Everything else 50 ms
Total frame time : 59 ms
```

```
A 1 ms
Everything else 50 ms
Total frame time : 51 ms
```

So in this example, even though we have hugely optimized functionality A, the actual gain in terms of frame rate is quite small.
