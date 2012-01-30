local super = class(..., "Object")

function __init(self, t)
	self.id = 0
	self.fields = {}
	self.players = {}
	self.objects = {}
	super.__init(self, t)
end

function __pack(self, objects)
    -- register self with the object table so that we will be packed by ID next time
    objects[self] = self.id

    return "call","Game",{
        id = id;
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
    self.objects[object.id] = object
    
    server.send {
        self = self;
        method = "addObject";
        object;
    }
end

function addPlayer(self, player)
    self.players[player.name] = player

    server.send {
        self = self;
        method = "addPlayer";
        player;
    }
end
