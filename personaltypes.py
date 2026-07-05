############################################################################
#
# Copyright (C) 2016 The Qt Company Ltd.
# Contact: https://www.qt.io/licensing/
#
# This file is part of Qt Creator.
#
# Commercial License Usage
# Licensees holding valid commercial Qt licenses may use this file in
# accordance with the commercial license agreement provided with the
# Software or, alternatively, in accordance with the terms contained in
# a written agreement between you and The Qt Company. For licensing terms
# and conditions see https://www.qt.io/terms-conditions. For further
# information use the contact form at https://www.qt.io/contact-us.
#
# GNU General Public License Usage
# Alternatively, this file may be used under the terms of the GNU
# General Public License version 3 as published by the Free Software
# Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT
# included in the packaging of this file. Please review the following
# information to ensure the GNU General Public License requirements will
# be met: https://www.gnu.org/licenses/gpl-3.0.html.
#
############################################################################

# This is a place to add your own dumpers for testing purposes.
# Any contents here will be picked up by GDB, LLDB, and CDB based
# debugging in Qt Creator automatically.

# NOTE: This file will get overwritten when updating Qt Creator.
#
# To add dumpers that don't get overwritten, copy this file here
# to a safe location outside the Qt Creator installation and
# make this location known to Qt Creator using the Debugger >
# Locals & Expressions > Extra Debugging Helpers setting.

# Example to display a simple type
# template<typename U, typename V> struct MapNode
# {
#     U key;
#     V data;
# }
#
# def qdump__MapNode(d, value):
#    d.putValue("This is the value column contents")
#    d.putNumChild(2)
#    if d.isExpanded():
#        with Children(d):
#            # Compact simple case.
#            d.putSubItem("key", value["key"])
#            # Same effect, with more customization possibilities.
#            with SubItem(d, "data")
#                d.putItem("data", value["data"])

# Check http://doc.qt.io/qtcreator/creator-debugging-helpers.html
# for more details or look at qttypes.py, stdtypes.py, boosttypes.py
# for more complex examples.

from dumper import *

######################## Your code below #######################

def qdump__Prim__CoRect(d, value):
    #d.putValue("[{0},  {1},  {2},  {3}]".format(value["left"], value["top"], value["right"], value["bottom"]))
    d.putEmptyValue()
    d.putNumChild(4)
    if d.isExpanded():
        with Children(d):
            d.putSubItem("left", value["left"])
            d.putSubItem("top", value["top"])
            d.putSubItem("right", value["right"])
            d.putSubItem("bot", value["bottom"])

def qdump__Prim__CoPoint2I(d, value):
    d.putEmptyValue()
    d.putNumChild(2)
    if d.isExpanded():
        with Children(d):
            d.putSubItem("x", value["x"])
            d.putSubItem("y", value["y"])

def qdump__Prim__CoPoint2(d, value):
    d.putEmptyValue()
    d.putNumChild(2)
    if d.isExpanded():
        with Children(d):
            d.putSubItem("x", value["x"])
            d.putSubItem("y", value["y"])

def qdump__Prim__CoPoint3I(d, value):
    d.putEmptyValue()
    d.putNumChild(3)
    if d.isExpanded():
        with Children(d):
            d.putSubItem("x", value["x"])
            d.putSubItem("y", value["y"])
            d.putSubItem("z", value["z"])

def qdump__Prim__CoPoint3(d, value):
    d.putEmptyValue()
    d.putNumChild(3)
    if d.isExpanded():
        with Children(d):
            d.putSubItem("x", value["x"])
            d.putSubItem("y", value["y"])
            d.putSubItem("z", value["z"])

###################### NavPhysics
def qdump__NavPhysics__FPoint3(d, value):
    x = value["x"].floatingPoint()
    y = value["y"].floatingPoint()
    z = value["z"].floatingPoint()
    d.putValue("[ %s, %s, %s ]" % (x,y,z))

def qdump__NavPhysics__FPoint2(d, value):
    x = value["x"].floatingPoint()
    y = value["y"].floatingPoint()
    d.putValue("[ %s, %s ]" % (x,y))

def qdump__NavPhysics__IPoint2(d, value):
    x = value["x"].integer()
    y = value["y"].integer()
    d.putValue("[ %d, %d ]" % (x,y))

###################### Godot
def qdump__Vector2(d, value):
    x = value["x"].floatingPoint()
    y = value["y"].floatingPoint()
    d.putValue("[ %s, %s ]" % (x,y))
    d.putEmptyValue()
    d.putNumChild(2)
    if d.isExpanded():
        with Children(d):
            d.putSubItem("x", value["x"])
            d.putSubItem("y", value["y"])

def qdump__Vector2i(d, value):
    x = value["x"].integer()
    y = value["y"].integer()
    d.putValue("[ %s, %s ]" % (x,y))
    d.putEmptyValue()
    d.putNumChild(2)
    if d.isExpanded():
        with Children(d):
            d.putSubItem("x", value["x"])
            d.putSubItem("y", value["y"])


def qdump__Vector3(d, value):
    x = value["x"].floatingPoint()
    y = value["y"].floatingPoint()
    z = value["z"].floatingPoint()
    d.putValue("[ %s, %s, %s ]" % (x,y,z))
    d.putEmptyValue()
    d.putNumChild(3)
    if d.isExpanded():
        with Children(d):
            d.putSubItem("x", value["x"])
            d.putSubItem("y", value["y"])
            d.putSubItem("z", value["z"])

def qdump__Vector3i(d, value):
    x = value["x"].integer()
    y = value["y"].integer()
    z = value["z"].integer()
    d.putValue("[ %s, %s, %s ]" % (x,y,z))
    d.putEmptyValue()
    d.putNumChild(3)
    if d.isExpanded():
        with Children(d):
            d.putSubItem("x", value["x"])
            d.putSubItem("y", value["y"])
            d.putSubItem("z", value["z"])


def qdump__Color(d, value):
    d.putEmptyValue()
    d.putNumChild(4)
    if d.isExpanded():
        with Children(d):
            d.putSubItem("r", value["r"])
            d.putSubItem("g", value["g"])
            d.putSubItem("b", value["b"])
            d.putSubItem("a", value["a"])

def qdump__LocalVector(d, value):
    try:
        size = int(value["count"])
        capacity = int(value["capacity"])
        ptr = value["data"]
        
        # 1. Protection Shield against garbage/uninitialised memory
        if size < 0 or size > 1000000:
            d.putValue("LocalVector [invalid or uninitialized]")
            d.putNumChild(0)
            return
        
        d.putValue(f"LocalVector [size: {size}][capacity: {capacity}]")
        # Limit num of children displayed
        size = min(size, 256)
        d.putNumChild(size)
        
        if d.isExpanded() and size > 0:
            with Children(d, numChild=size, maxNumChild=256):
                for i in range(size):
                    d.putSubItem(f"[{i}]", ptr[i])
    except:
        d.putValue("LocalVector (unparsed)")

def qdump__Vector(d, value):
    try:
        # Extract the underlying CowData structure
        cowdata = value["_cowdata"]
        ptr = cowdata["_ptr"]
        
        # If the pointer is null, the Vector is completely empty
        if not ptr:
            d.putValue("empty Vector")
            d.putNumChild(0)
            return

        # Godot 3.x CowData stores internal metrics just before the data array pointer:
        # ptr[-1] = Array Size (elements)
        # ptr[-2] = Reference Count
        # We cast the pointer to a 32-bit integer array to look backward safely.
        int_ptr = ptr.cast(d.lookupType("int").pointer())
        size = int(int_ptr[-1])
        ref_count = int(int_ptr[-2])

        # 1. Protection Shield against garbage/uninitialised memory
        if size < 0 or size > 1000000:
            d.putValue("Vector [invalid or uninitialized]")
            d.putNumChild(0)
            return

        d.putValue(f"Vector [size: {size}] (refs: {ref_count})")
        
        # 2. Cap UI visual payloads to 1000 items to avoid UI lockups
        display_size = min(size, 256)
        d.putNumChild(display_size)
        
        if d.isExpanded() and display_size > 0:
            # Safely hand off element streaming to Qt Creator
            with Children(d, numChild=display_size, maxNumChild=256):
                for i in range(display_size):
                    d.putSubItem(f"[{i}]", ptr[i])
                
                # 3. Visually append a marker if the array was truncated
                if size > display_size:
                    d.putSubItem(f"... and {size - display_size} more elements", None)
                    
    except Exception as e:
        d.putValue("Vector (unparsed)")

def qdump__Span(d, value):
    try:
        # 1. Fetch internal pointer mapping and array boundaries
        # Update these keys ("data_ptr" and "size") if your implementation varies
        ptr = value["_ptr"]
        size = int(value["_len"])

        # Prevent NullPointer issues if the view is initialized as empty
        if not ptr or int(ptr) == 0 or size == 0:
            d.putValue("empty Span")
            d.putNumChild(0)
            return

        # 2. Protection Shield against garbage or uninitialized stack data
        if size < 0 or size > 1000000:
            d.putValue("Span [invalid or uninitialized size]")
            d.putNumChild(0)
            return

        # 3. Dynamic Type Extraction: Automatically resolve "T" from Span<T>
        # This forces Qt Creator to display sub-items as real objects instead of void* blobs
        element_type = value.type.templateArgument(0)
        typed_ptr = ptr.cast(element_type.pointer())

        d.putValue(f"Span [size: {size}]")
        
        # 4. Freeze-Proof UI Safeguards
        # Cap visual layouts to 1000 visible rows to prevent Qt Creator freezing
        display_size = min(size, 256)
        d.putNumChild(display_size)

        if d.isExpanded() and display_size > 0:
            with Children(d, numChild=display_size, maxNumChild=256):
                for i in range(display_size):
                    # Elements are rendered based on their original template type rules
                    d.putSubItem(f"[{i}]", typed_ptr[i])
                
                # Append visual indicator if data streams past the safety threshold
                if size > display_size:
                    d.putSubItem(f"... and {size - display_size} more sliced elements", None)

    except Exception as e:
        d.putValue("Span (unparsed)")

###################### SIMD

def qdump_____m128(d, value):
    d.putEmptyValue()
    d.putNumChild(4)
    if d.isExpanded():
        d.putArrayData(value.address(), 4, d.lookupType('float'))

def qdump____m128(d, value):
    d.putEmptyValue()
    d.putNumChild(4)
    if d.isExpanded():
        d.putArrayData(value.address(), 4, d.lookupType('float'))

def qdump___m128(d, value):
    d.putEmptyValue()
    d.putNumChild(4)
    if d.isExpanded():
        d.putArrayData(value.address(), 4, d.lookupType('float'))

