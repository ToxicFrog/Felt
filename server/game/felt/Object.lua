local super = class(..., "Object")

pack = {
    "id";
}

function __init(self, ...)
    super.__init(self, ...)
    
    -- register the object with the gamestate. This will automatically assign
    -- it a unique ID.
    server.game():addObject(self)
end

function __pack(self, objs)
    -- pack all of the saveable fields and generate the inheritance chain
    local ctor = { _ANCESTRY = {} }
    local class = self
    repeat
        table.insert(ctor._ANCESTRY, class._NAME)
        for _,key in ipairs(class.pack) do
            ctor[key] = self[key]
        end
        class = class._SUPER
    until not class.pack

    return "call","game.felt.Object",ctor
end

function set(self, key, value)
    self[key] = value
    self:send("set", key, value)
end

function send(self, method, ...)
    server.send {
        self = self;
        method = method;
        ...
    }
end

-- deleting an object is tricky
-- on the server, we need to, at minimum, remove it from the forward and reverse object lookup tables
-- subtypes may also need to do their own cleanup - for example, Entity needs to remove the object
-- from the game world
-- on the client, it needs to be removed from the object tables, and also from the UI, in addition to any
-- other required cleanup
function delete(self)
    server.deleteObject(self)
end
