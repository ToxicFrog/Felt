-- implementation of "join game" tab.

-- widgets:
--  host_port     - the server's port number
--  host_require_password
--  host_password - the game password, if reuired (server will ignore it if it's not)
--  host_restore_game
--  host_game_file
--  host_ok       - the button that makes the magic happen

local function loadconfig()
	local port,pass,needpass,name,colour = felt.config.get(
		"host:port",
		"host:pass",
		"host:needpass",
		"name",
		"colour"
	)
	
	ui.win.host_port:set("text", tostring(port))
	ui.win.host_password:set("text", pass)
	ui.win.host_require_password:set_active(needpass)
	ui.win.host_name:set("text", name)
	ui.setColour(ui.win.host_colour, colour)
end

local function saveconfig()
	local port = tonumber(ui.win.host_port:get("text"))
	local pass = ui.win.host_password:get("text")
	local needpass = ui.win.host_require_password:get_active()
	local name = ui.win.host_name:get("text")
	local colour = ui.getColour(ui.win.host_colour)
	
	felt.config.set(
		"host:port", port,
		"host:needpass", needpass,
		"host:pass", pass,
		"name", name,
		"colour", colour
	)
end

-- Game -> Host
function ui.win.menu_game_host:activate()
	loadconfig()
	ui.win.host_window:show_all()
	ui.win.host_window:run()
	ui.win.host_window:hide_all()
	saveconfig()
end

function ui.win.host_cancel:clicked()
	ui.win.host_window:response(0)
end

-- start a new game
function ui.win.host_ok:clicked()
	local port = tonumber(ui.win.host_port:get("text"))
	local pass = ui.win.host_password:get("text")
	local needpass = ui.win.host_require_password:get_active()
	local name = ui.win.host_name:get("text")
	local colour = ui.getColour(ui.win.host_colour)

	if needpass and #pass == 0 then
		return ui.error("If passwords are enabled, you must specify one.")
	end
	
	ui.win.host_window:response(1)
	
	if server:start(port, pass) then
		client = new "client.LocalClient" {
			name = name;
			colour = colour;
			host = "localhost";
			port = port;
			pass = pass;
		}
		assert(client:connect())
	end
end
