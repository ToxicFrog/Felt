local Serializeable = require "Serializeable"
local Game = Serializeable:subclass "Game"

Game:defaults {}

Game:save "objects" "tables"

function Game:__init(...)
	Serializeable.__init(self, ...)
	self.objects = {}
	self.tables = {}
	self.players = {}
	self.old_tables = {}
end

function Game:newtable(ctor)
	assert(ctor and ctor.name, "Invalid argument to Game:newtable")
	
	if self.tables[name] then
		return self.tables[name]
	end
	
	local t = new "Table" (ctor)
	self:addtable(t)
    
    return t
end

function Game:addtable(t)
	local x = love.graphics.getWidth()/2 - t.w/2
    local y = love.graphics.getHeight()/2 - t.h/2
    
    local w = new "Window" {
        x = x;
        y = y;
        content = t;
    }
    self.screen:add(w)
    self.tables[name] = t
end	

function Game:deltable(name)
    self.tables[name].parent:destroy()
    self.tables[name] = nil
end

function Game:loadmodule(name)
    if love.filesystem.exists("modules/"..name:gsub("%.","/").."/init.lua") then
        require("modules."..name..".init")
    else
        felt.log("No such module %s", name)
    end
end

function Game:id(object)
	if not object.id then return end
	
	local id = #self.objects +1
	object.id = id
	self.objects[id] = object
end

return Game
