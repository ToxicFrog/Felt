local super = class(..., felt.Object)

id = "G"

function __init(self, ...)
	super.__init(self, ...)
	self.fields = {}
	self.players = {}
	self.objects = {
		G = self;
	}
end

function addPlayer(self, name, colour)
	-- FIXME: use an actual Player class
	-- we can assume that the enclosing server won't permit name collisions
	-- thus, if we have one here, it means a player previously part of the
	-- game has reconnected
	-- they keep their old ID increment but the new colour overrides the old
	local player = self.players[name] or {}
	player.colour = colour
	player.id = player.id or 0
	self.players[name] = player
	self.objects[name] = player
end

function addField(self, name)
	assert(not self.fields[name], "double create of field "..name)
	
	self.fields[name] = new "felt.Field" {
		name = name;
	}
	
	return self.fields[name]
end

function getField(self, name)
	return self.fields[name]
end
