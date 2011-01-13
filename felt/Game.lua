local super = class(..., felt.Object)

replicant = true

mixin "mixins.serialize" ("fields", "objects", "players")

function __init(self, t)
	assert(not felt.game)
	self.id = "G"
	self.fields = {}
	self.players = {}
	self.objects = {}
	super.__init(self, t)
	
	-- even after serialization, we need to create this manually, because
	-- recursive structures cannot be serialized fully
	self.objects[self.id] = self
end

local _save = __save
function __save(self, ...)
	for k,v in pairs(self.objects) do print("game save", k, v) end
	return _save(self, ...)
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

function getField(self, name)
	return self.fields[name]
end

function getObject(self, id)
	return assert(self.objects[id], "no object in game with id "..tostring(id))
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
