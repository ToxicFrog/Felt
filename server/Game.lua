local super = class(..., "common.Object")

function __init(self, t)
	self.id = "G"
	self.fields = {}
	self.players = {}
	self.objects = {}
	super.__init(self, t)
	
	-- insert ourself into the objects table automatically
	self.objects[self.id] = self
end

function __pack(self, objects)
    return "call","Game",{
        id = id;
        fields = self.fields;
        players = self.players;
        objects = self.objects;
    }
end

function __unpack(arg)
    return new(_CLASS)(arg)
end

-- returns the Player with the given name
function getPlayer(self, name)
	return self.players[name]
end

-- returns the Field with the given name
function getField(self, name)
	return self.fields[name] {}
end

-- returns the in-game object with the given name
-- there are a few "special" IDs; in particular S is always the server and
-- G is always the game object itself
function getObject(self, id)
	return assert(self.objects[id], "no object in game with id "..tostring(id))
end

function addPlayer(self, player)
end

function addField(self, field)
end

function delPlayer(self, name)
end

function delField(self, name)
end

function server_addField(self, field)
	if self.fields[field.name] then
		server:reply(server, "message", "a field named '%s' already exists", field.name)
		return
	end
	
	self:addField(field)
end

function client_addField(self, field)
	assert(not self.fields[field.name], "double create of field "..field.name)

	self.fields[field.name] = field
	ui.show_field(field)
end

function client_newObject(self, class, ctor)
	if self.objects[ctor.id] then
		-- if this is a reflection from one of our own object creations, let
		-- it be.
		if self.objects[ctor.id]._ORIGINAL and ctor.replicant then return end
		assert(not self.objects[ctor.id], "object ID collision")
	end
	
	-- this happens automatically now
	-- self:addObject(require(class)(ctor))
	require(class)(ctor)
end

function addObject(self, obj)
	assert(not self.objects[obj.id], "object ID collision")
	ui.message("[game] Adding object %s (%s)", obj.id, tostring(obj))
	self.objects[obj.id] = obj
end
