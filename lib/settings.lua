
function felt.save_settings()
    love.filesystem.write("config", felt.serialize(felt.config))
end

local function commit()
    if felt.config.height ~= love.graphics.getHeight()
    or felt.config.width ~= love.graphics.getWidth()
    then
        love.graphics.setMode(felt.config.width, felt.config.height)
    end
    felt.players[felt.config.name] = felt.config.colour
end


function felt.load_settings()
    if love.filesystem.exists("config") then
        felt.config = felt.deserialize(love.filesystem.read("config")) or felt.config
    else
        felt.config = {
            name = "Player"..math.random(1,1024);
            colour = "#FF0000";
            width = love.graphics.getWidth();
            height = love.graphics.getHeight();
        }
    end
    commit()
	print("load", felt.config)
end

felt.load_settings()

local win
win = new "SettingsWindow" {
    "Name", felt.config.name;
    "Colour", felt.config.colour;
    "Width", tostring(felt.config.width);
    "Height", tostring(felt.config.height);
    call = function(win)
        felt.config.name = win:get "Name"
        felt.config.colour = win:get "Colour"
        felt.config.width = tonumber(win:get "Width")
        felt.config.height = tonumber(win:get "Height")
        commit()
        felt.save_settings()
    end;
}

function felt.configure()
    felt.screen:add(win)
end

