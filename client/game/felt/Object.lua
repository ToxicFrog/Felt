-- this is the superclass for all objects in the game world. It supports the
-- basic operations needed to instantiate objects as they are transmitted
-- from the server, and send messages back to the server requesting method
-- invokations.

local super = class(..., "common.Object")

-- instiate a new instance of this type or a subtype thereof
function __unpack(type, ctor)
    print("__unpack", type._NAME)
    for k,v in pairs(ctor) do
        print("", k, v)
    end
    -- walk the inheritance chain and instantiate the most specialized type in
    -- it that we have a definition for
    for _,type in ipairs(ctor._ANCESTRY) do
        print(type, srequire(type))
        if srequire(type) then
            obj = new(type)(ctor)
            print(obj)
            for k,v in pairs(obj) do print(k,v) end
            return obj
        end
    end
    return error("No defined type found attempting to deserialize object of type %s" % ctor._ANCESTRY[1])
end

if _DEBUG then
    function __tostring(self)
        return "%s (%s: %s)" % { tostring(self.name), tostring(self._NAME), tostring(self._ID) }
    end
end

-- send a message to the server requesting invokation of the given method
function send(self, method, ...)
    client:send {
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
    return self:set(...)
end
