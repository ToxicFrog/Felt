-- Implementation of the UI's "settings" tab.

-- widgets:
--  config_name   - the player's name
--  config_colour - the player's colour

-- utility functions for converting between the GdkColor the UI uses and the
-- { red, green, blue } table that the backend uses
function ui.getColour(widget)
	local c = gdk.new "GdkColor"
	widget:get_color(c)
	return { red = c.red, green = c.green, blue = c.blue }
end

function ui.setColour(widget, colour)
	local c = gdk.new "GdkColor"
	c.red,c.green,c.blue = colour.red,colour.green,colour.blue
	widget:set_color(c)
end

return function()
	-- Retrieve settings from config file. Initialize configuration fields, and
	-- if we don't have configuration entries, provide defaults.
	local name,colour = felt.config.get("name", "colour")
	
	if not name then
		-- no previous configuration - create default settings
		
		name = "Player"
		colour = {
			red   = math.random(0, 65535);
			green = math.random(0, 65535);
			blue  = math.random(0, 65535);
		}
		
		-- commit the default configuration
		felt.config.set(
			"name", name,
			"colour", colour,
			"host:port", 8088,
			"host:pass", "",
			"host:needpass", false,
			"join:port", 8088,
			"join:host", "localhost",
			"join:pass", ""
		)
	end
end
