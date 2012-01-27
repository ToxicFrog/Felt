-- this is the superclass for all objects in the game world. It supports the
-- basic operations needed to instantiate objects as they are transmitted
-- from the server, and send messages back to the server requesting method
-- invokations.

local super = class(..., "Object")

-- instantiate a new instance of this type or a subtype thereof
function __unpack(type, ctor)
    -- walk the inheritance chain and instantiate the most specialized type in
    -- it that we have a definition for
    print("unpack", unpack(ctor._ANCESTRY))
    for _,type in ipairs(ctor._ANCESTRY) do
        if srequire(type) then
            return new(type)(ctor)
        else
            print("WARNING:", type, srequire(type))
        end
    end
    return error("No defined type found attempting to deserialize object of type %s" % ctor._ANCESTRY[1])
end

-- this will get triggered when we try to send a message containing this object
-- for the first time. We simply slap this object into the object table,
-- recording that the server knows about it (it knows about all objects, as the
-- client is not permitted to create its own) and kick the ball back to the
-- serializer, which should now pick up the entry in the object table.
function __pack(self, objs)
    print(objs)
    objs[self] = self.id
    return "pack", self
end

if _DEBUG then
    function __tostring(self)
        return "%s (%s: %s)" % { tostring(self.name), tostring(self._NAME), tostring(self._ID) }
    end
end

-- send a message to the server requesting invokation of the given method
function send(self, method, ...)
    Client:instance():send {
        self = self;
        method = method;
        ...
    }
end

-- invoked by the server to update values in client objects when the gamestate
-- changes
-- renderables need to mark themselves dirty when this happens so that they get
-- redrawn.
function set(self, key, value, ...)
    if not key then return end
    self[key] = value
    if self["__set_"..key] then
        self["__set_"..key](self, key, value)
    elseif self.__set then
        self:__set(key, value)
    end
    return self:set(...)
end
