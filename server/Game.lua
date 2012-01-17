local super = class(..., "common.Object")

function __init(self, t)
	self.id = "G"
	self.fields = {}
	self.players = {}
	self.objects = {}
	super.__init(self, t)
end

function __pack(self, objects)
    print("pack Game")
    table.print(self.fields)
    table.print(self.objects)
    return "call","Game",{
        id = id;
        fields = self.fields;
        players = self.players;
        objects = self.objects;
    }
end

function addField(self, name)
    if not self.fields[name] then
        local f = new "game.felt.Field" {
            game = self;
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
end
