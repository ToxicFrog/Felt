
local games = {}

for dir in lfs.dir("modules") do
	if lfs.attributes("modules/"..dir.."/box.png") then
		table.insert(games, dir)
	end
end

local width = math.ceil((#games)^0.5)

local field = new "felt.Field" {
	name = "Game Boxes";
	w = width*(64+8)+8, h = width*(64+8)+8;
}

for i,game in ipairs(games) do
	local x = 8 + ((i-1) % width)*(64+8)
	local y = 7 + math.floor((i-1) / width)*(64+8)
	
	local box = new "gameboxes.Box" {
		name = game.." box";
		face = "modules/"..game.."/box.png";
		module = "modules."..game;
		w = 64;
		h = 64;
	}
	
	field:add(box, x, y)
end

felt.game:addField(field)