-- client version of a running game
-- All the interesting stuff happens on the server, and since a game has no
-- existence in the UI, there's no user interface code for this either
-- so all this needs is a few accessors

local super = class("Game", "Object")
local _NAME = _NAME

id = 0

function __unpack(type, arg)
    print("unpack game")
    local self = new(type._NAME)(arg)
    self.objects[0] = self

    -- generate the "reverse object mapping"
    self.r_objects = {}
    for k,v in pairs(self.objects) do
        self.r_objects[v] = v.id
    end

    return self
end

-- returns the Player with the given name
function getPlayer(self, name)
	return self.players[name]
end

-- returns the Field with the given name
function getField(self, name)
	return self.fields[name]
end

-- returns the in-game object with the given name
-- there are a few "special" IDs; in particular S is always the server and
-- G is always the game object itself
function getObject(self, id)
	return assert(self.objects[id], "no object in game with id "..tostring(id))
end

function addObject(self, object)
    self.objects[object.id] = object
    self.r_objects[object] = object.id
end

function addPlayer(self, player)
    self.players[player.name] = player
end
