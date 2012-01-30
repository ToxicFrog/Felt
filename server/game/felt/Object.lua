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
    
    objs[self] = self.id
    
    return "call","game.felt.Object",ctor
end

function set(self, key, value)
    self[key] = value
    self:broadcast("set", key, value)
end

function broadcast(self, method, ...)
    self.game.server:broadcast {
        self = self;
        method = method;
        ...
    }
end

function message(self, ...)
    self.game.server:broadcast {
        method = "message";
        ...;
    }
end
