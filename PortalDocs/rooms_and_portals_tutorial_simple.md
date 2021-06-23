# Room and Portals - Tutorial Simple
[Main Documentation](rooms_and_portals.md)
## Introduction
This tutorial will introduce you to building a 'hello world' room system with two rooms, and a portal in between.

## Step 1
![Tutorial Simple 1](images/tutorial_simple1.png)
* Create a new project
* Add a `Spatial` as the scene root (I have called it 'Root')
* Next add a `RoomManager` node. We will need this later to process the room system.
* Next we need to start defining our rooms. We create all our rooms under another `Spatial` we have called 'RoomList'.
* We can, but don't need to create rooms as `Room` nodes directly. Here the indirect method is used - the room is simply a `Spatial` with a name that starts with the prefix `Room_`. We add our chosen name as a suffix, here we have used 'kitchen'.
* We will now create the geometry of our room. The names you give to the geometry is up to you.
* Create a `MeshInstance` for the floor. Create a box mesh, and scale and position it to form a floor.
* Create `MeshInstance`s for the walls. Again use box meshes, and scale and position them, but be sure to leave an opening on one side (you will need to create two wall segments to do this on that side).
## Step 2
![Tutorial Simple 2](images/tutorial_simple2.png)
* Now we need to create the other room.
* You can do this simply by duplicating the first room (select the 'Room_kitchen' node, right click and choose 'duplicate').
* Rotate and position the second room so that the openings line up.
* Rename the second room to 'Room_lounge'.
## Step 3
![Tutorial Simple 3](images/tutorial_simple3.png)
* Next we will add a portal between the two rooms
* Create a new `MeshInstance` in the kitchen, and call it `Portal_lounge`. The name ensures it will be converted to a portal, and tells the system which room it should link to.
* Create a new `Plane` mesh for this `MeshInstance`.
* Scale and position the plane so it fits within the opening between the two rooms.
* The portal plane should face _outward_ from the source room, i.e. towards the lounge.
## Step 5
![Tutorial Simple 4](images/tutorial_simple4.png)
* In order to make things more exciting, add a few more boxes to the rooms.
* I've used a green material to make them stand out more.
* Also an an `Omni` light to one of the rooms.
## Step 6
![Select RoomList](images/select_roomlist.png)
* Next comes a crucial stage, we must let the `RoomManager` know where the rooms are!
* Select the `RoomManager` and look in the Inspector window in the 'Paths' section.
* You need to assign the 'RoomList' to point to the 'RoomList' node we created earlier (which is the parent of all the rooms).
## Step 7
![Tutorial Simple 5](images/tutorial_simple5.png)
* Make sure you have saved your project before this next step (it is always a good idea to save and make a backup before converting).
* Select the `RoomManager`, and you will see a button in the toolbar at the top of the 3d view called 'Convert Rooms'. Press this button.
* If all goes well, the `RoomManager` will have created the runtime data (the `room graph`) to do culling at runtime.
* Notice how the `Spatial` nodes marked as 'Room_' have automatically been converted to `Room` nodes, and the `Spatial` nodes marked as 'Portal_' have been converted to `Portal` nodes. Although you can add these node types directly, using the indirect method means you can can build your whole game level in blender rather than the Godot editor. All you need to do is use Empties using the naming convention for 'Room_' and 'Portal_'.
* If you now move the editor camera inside the rooms, you should see the meshes in the opposite room being culled depending on what you can see through the portal.
* In the `RoomManager`, turn off the 'Show Debug' tickbox to get a better view.
## Conclusion
This concludes this simple tutorial. Don't be afraid to experiment with the new room system you have created.

#### Some things to try:
* Create different types of geometry - CSG nodes, Particle systems, Multimeshes
* Try creating a `Camera` and adding it to the scene. If you run the scene you will notice that the portal culling is not active. This is because the 'room graph' must be created each time you load a level, by converting the rooms. Instead of using a button in the editor, in real games you call a function in the `RoomManager` to convert the level, called `rooms_convert()`. Try this out with a script, perhaps running within a `_ready` function.
* The geometry you created so far is all `STATIC` (non-moving). If you look in the inspector for geometry nodes, you will see they derive from `CullInstance`. Here you can set the `portal_mode` for objects in the portal system. This determines how the node is processed.
* If you now write a script to move one of your objects within a room and view it through a `Camera` as the scene runs, you may notice that the object gets culled incorrectly. This is because `STATIC` objects are assumed not to move in the system. If you instead change the object to `DYNAMIC`, it should now update the culling correctly.
* There are several `portal_modes`, these are described in the main documentation.
* Try turning the portal on and off at runtime from your script! Once converted to a `Portal`, you can run `set_portal_active` to open and close the portal. 
