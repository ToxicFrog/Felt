local games = {}

for dir in lfs.dir("share") do
	if lfs.attributes("share/"..dir.."/box.png") and lfs.attributes("server/game/"..dir.."/box.lua") then
		table.insert(games, dir)
	end
end

local width = math.ceil((#games)^0.5)

local field = server.game():addField("Game Boxes")

for i,game in ipairs(games) do
	local x = 8 + ((i-1) % width)*(64+8)
	local y = 7 + math.floor((i-1) / width)*(64+8)
	
	local box = new "game.gameboxes.Box" {
		name = game:gsub("^%a", string.upper).." Box";
		face = "box";
		game = game;
		w = 64;
		h = 64;
	}
	
	field:add(box, x, y)
end
