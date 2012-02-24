local super = class(..., "Object")

function __init(self, t)
	self.id = 0
	self.fields = {}
	self.players = {}
	self.objects = {}

    -- reverse lookup table, maps objects to IDs
    self.r_objects = {
        [self] = 0;
    }

	super.__init(self, t)
end

function __pack(self)
    return "call","Game",{
        id = self.id;
        fields = self.fields;
        players = self.players;
        objects = self.objects;
    }
end

function openGame(self, name)
    require("game."..name..".box")
end

function addField(self, name)
    if not self.fields[name] then
        local f = new "game.felt.Field" {
            name = name;
        }
        self.fields[name] = f
    end
    
    self:addObject(self.fields[name])
    return self.fields[name]
end

function addObject(self, object)
    assert(not object.id or self.objects[object.id] == object, "object ID collision in addObject")
    object.id = object.id or #self.objects+1

    server.send {
        self = self;
        method = "addObject";
        object;
    }

    self.objects[object.id] = object
    self.r_objects[object] = object.id
end

function deleteObject(self, object)
    server.send {
        self = self;
        method = "deleteObject";
        object;
    }

    self.objects[object.id] = nil
    self.r_objects[object] = nil
end

function addPlayer(self, ctor)
    if self.players[ctor.name] then
        for k,v in pairs(ctor) do
            self.players[ctor.name][k] = v
        end
    else
        self.players[ctor.name] = new "game.felt.Player" (ctor)
    end

    server.send {
        self = self;
        method = "addPlayer";
        self.players[ctor.name];
    }

    return self.players[ctor.name]
end
