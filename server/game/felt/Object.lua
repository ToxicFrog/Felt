local super = class(..., "common.Object")

pack = {
    "id";
}

function __init(self, ...)
    super.__init(self, ...)
    
    -- register the object with the gamestate. This will automatically assign
    -- it a unique ID.
    assert(self.game, "attempt to create in-game object without a containing game")
    self.game:addObject(self)
end

function __pack(self, ...)
    -- pack all of the saveable fields and generate the inheritance chain
    local ctor = { _ANCESTRY = {} }
    local class = self
    print("__pack", self._NAME)
    repeat
        print("", class._NAME)
        table.insert(ctor._ANCESTRY, class._NAME)
        for _,key in ipairs(class.pack) do
            print("", key, self[key])
            ctor[key] = self[key]
        end
        class = class._SUPER
    until not class.pack
    
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
