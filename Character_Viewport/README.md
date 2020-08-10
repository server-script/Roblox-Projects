# Roblox Character_Viewport (ALPHA)

A Roblox module for viewing Roblox character on a viewport frame, where it auto-updates every frame and is somehow optimized for better performance.

Welcome to the Character_Viewport wiki!

# Documentation

This is a documentation written by [fredrick254](https://www.roblox.com/users/472224940/profile) on his Character_Viewport module. This was updated on 10/08/2020.

# Constructors

## Viewer Character_Viewport.new([Table](https://developer.roblox.com/en-us/articles/Table) data | [ViewportFrame](https://developer.roblox.com/en-us/articles/viewportframe-gui) Viewport, [Model](https://developer.roblox.com/en-us/api-reference/class/Model) Character)

##### All parameters are required. Character parameter is the loaded character model, data parameter has the following format

###### data = {[UDim2](https://developer.roblox.com/en-us/api-reference/datatype/UDim2) Position, [UDim2](https://developer.roblox.com/en-us/api-reference/datatype/UDim2) Size} or [ViewportFrame](https://developer.roblox.com/en-us/articles/viewportframe-gui) Viewport

Creates a new Viewer object, which represents a viewport frame wrapper. The data parameter could either have an already-made viewport frame, or a table in which you could specify a Position and Size parameter, where a new viewport frame will be automatically placed and background made transparent by default.

# Viewer Methods

## void Enable([String](https://developer.roblox.com/en-us/articles/String) mode)

##### The mode parameter is not required.

The mode parameter is intended to specify the mode of viewing you want your character to appear in the viewport frame. If no mode is specified, the Front mode is automatically chosen for you.

The different modes are: 1. Front
                         2. Back 
                         3. FreeCam

## void SwitchMode([String](https://developer.roblox.com/en-us/articles/String) mode)

##### The mode parameter is required.

This method changes the mode of the viewer real-time and does not yield in any way. It is heavily optimized and secure at the moment it was last updated.

## void Disable()

This method disables the viewport frame and clears the whole viewport frame. It does nothing special apart from that. You can use the method `Enable()` to re-enable the viewer. Note that re-enabling it causes a yield.

## void Freeze()

This method freezes the viewport frame in its tracks. There is no use I can think of it for now, but have fun!

## void Unfreeze()

This method unfreezes the viewport frame.

## void LoadOnToView([Table](https://developer.roblox.com/en-us/articles/Table) children)

This method loads any sort of visible instance into the current viewport frame. This method is used by the minor vehicle support feature, which currently isn't near completion. The children parameter must consist of the children of what you want to load on to the viewport. Note that the position of the instance loaded in is auto-updated. There are plans to make this optional.

Note that it caches the instances in children parameter in a somewhat disorganized way, and i'm planning to find a way to make it neater soon.

##### ⚠⚠ Note on this method: This method is not tested in any way using imported models and is still under heavy work by me. I advise to not use it unless very necessary.

## void UnloadFromView([Table](https://developer.roblox.com/en-us/articles/Table) children)

This method unloads instances that had already been loaded into the viewport frame by the ```LoadOnToView()``` method. It does this by making everything transparent so that the loading method can find them if they do exist.

## void Destroy()

This method is a work in progress and will be released soon.
