-- 'box' safe (de)serialization library
-- used for both save/load and for network traffic

box = {}

-- api:
-- box.pack(object, ...)
-- packs <object> and returns a string
-- the __pack and __unpack metamethods are respected, and ... is passed to
-- them
-- primitives (nil boolean string number) are packed as-is
-- tables are packed recursively
-- threads, functions and userdata raise an error
require "box.pack"

-- box.unpack(string)
-- returns the originally packed object
-- for non-primitive objects, an __unpack metamethod may be invoked
-- this is actually found by doing require(type).__unpack(arg)
--require "box.unpack"

-- __pack(self, ...)
-- metamethod for packing objects
-- possible return values are:
--  nil - do not pack this object at all; omit it from the box
--  string - pack exactly this string
--  string,object - pack such that it will be unpacked with require(string).__unpack(object)
--  the typical use case for this is that, say, a Die can return something like this:
--    "game.dice.Die",{ faces=6, face=1 }
--  and then, in the definition for game.dice.Die, __unpack looks like this:
--    return new(_CLASS)(arg)
--  which is in fact close to the default definition of __unpack, in FeltObject.

return box

--[[ format documentation
    Packed objects do not carry their size with them - the size is implicit in
    the size of the packed string. If an object contains subojects, it also
    contains a table of contents that lists their sizes.
    
    functions and threads cannot be packed.
    nil, true, and false are packed as "n", "t", and "f" respectively.
    strings are packed as "S" followed by the string itself.
    numbers are packed as "N" followed by the number in base ten.
    tables are packed as "T", followed by a table of contents, followed by a
    sequence of key-value pairs matching the table of contents.
    
    A table of contents consists of a base ten number specifying the number of
    TOC entries T, followed by T base ten numbers specifying the length of the
    corresponding data elements. Each number is terminated by ":".
    
    anything with a "__pack" metamethod is handled specially. The metamethod is
    called, and its return value is used to determine what should be packed. The
    following possibilities are supported:
        "raw",str - pack str as-is
        "pack",obj - pack obj instead
        "call",type,arg - unpack by calling require(type).__unpack(arg)
        
    In the latter case, it is packed as "C", followed by a TOC (which always
    contains two entries - the type name and the argument), followed by the type
    name and the argument.
    
    Finally, for the sake of preserving references and not choking on cycles,
    each object is cached as it is packed or unpacked. The next time the same
    object is packed (in a given call to box.pack()), a reference to the cache
    entry is generated instead. These are generated as "R" followed by cache
    index in base ten.
--]]