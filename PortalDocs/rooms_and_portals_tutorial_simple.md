# Room and Portals - Tutorial Simple
## Introduction
This tutorial will introduce you to building a 'hello world' room system with two rooms, and a portal in between.

## Step 1
* Create a new project
* Add a `Spatial` as the scene root (I have called it 'Root')
* Next add a `RoomManager` node. We will need this later to process the room system.
* Next we need to start defining our rooms. We create all our rooms under another `Spatial` we have called 'RoomList'.
* We can, but don't need to create rooms as `Room` nodes directly. Here the indirect method is used - the room is simply a `Spatial` with a name that starts with the prefix `Room_`. We add our chosen name as a suffix, here we have used 'kitchen'.
* 
* 

![Tutorial Simple 1](images/tutorial_simple1.png)
![Tutorial Simple 2](images/tutorial_simple2.png)
![Tutorial Simple 3](images/tutorial_simple3.png)
![Tutorial Simple 4](images/tutorial_simple4.png)
![Tutorial Simple 5](images/tutorial_simple5.png)
![Select RoomList](images/select_roomlist.png)

