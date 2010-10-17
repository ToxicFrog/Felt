local super = class(..., felt.Object)

mixin "serialize" ("fields", "objects", "players")

function __init(self, ...)
	super.__init(self, ...)
	self.fields = {}
	self.players = {}
	self.objects = {
		G = self;
	}
	self.id = "G"
end

function client_addPlayer(self, player)
	-- we can assume that the enclosing server won't permit name collisions
	-- thus, if we have one here, it means a player previously part of the
	-- game has reconnected
	self.players[player.name] = player
end

function getPlayer(self, name)
	print("getplayer", '"'..name..'"', self.players[name])
	for k,v in pairs(self.players) do print("", '"'..k..'"', v) end
	return self.players[name]
end

function client_addField(self, field)
	assert(not self.fields[field.name], "double create of field "..field.name)

	self.fields[field.name] = field
	ui.show_field(field)
	return field
end

function getField(self, name)
	return self.fields[name]
end

function getObject(self, id)
	return assert(self.objects[id], "no object in game with id "..tostring(id))
end

function client_newObject(self, class, ctor)
	assert(not self.objects[ctor.id], "object ID collision")
	
	self:addObject(require(class)(ctor))
end

function addObject(self, obj)
	assert(not self.objects[obj.id], "object ID collision")
	self.objects[obj.id] = obj
end
