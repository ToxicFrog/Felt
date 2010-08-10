-- Implementation of the UI's "settings" tab.

-- widgets:
--  config_name   - the player's name
--  config_colour - the player's colour

-- utility functions for converting between the GdkColor the UI uses and the
-- { red, green, blue } table that the backend uses
local function getColour()
	local colour = gdk.new "GdkColor"
	ui.win.config_colour:get_color(colour)
	return { red = colour.red, green = colour.green, blue = colour.blue }
end

local function setColour(colour)
	local c = gdk.new "GdkColor"
	c.red,c.green,c.blue = colour.red,colour.green,colour.blue
	ui.win.config_colour:set_color(c)
end

-- automatically save configuration settings on page change
function ui.win.main_notebook:switch_page(...)
	local name = ui.win.config_name:get("text")
	local colour = getColour()
	
	felt.config.set("name", name, "colour", colour)
end

return function()
	-- Retrieve settings from config file. Initialize configuration fields, and
	-- if we don't have configuration entries, focus this tab so that it is the
	-- first thing the player sees the first time they run the game.
	local name,colour = felt.config.get("name", "colour")
	
	if not name then
		-- no previous configuration - create default settings
		
		name = ""
		colour = {
			red   = math.random(0,65535);
			green = math.random(0, 65535);
			blue  = math.random(0, 65535);
		}
		
		-- pageflip so that the settings page is the first thing a new player sees
		ui.win.main_notebook:set_current_page(2)
		
		-- commit the default configuration
		felt.config.set(
			"name", name,
			"colour", colour,
			"host:port", 8088,
			"join:port", 8088,
			"join:host", "localhost"
		)
			
	end
	
	ui.win.config_name:set("text", name)
	setColour(colour)
end
