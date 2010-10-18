-- implementation of "join game" tab.

-- widgets:
--  join_host     - the server's hostname or IP address
--  join_port     - the server's port number
--  join_password - the game password, if reuired (server will ignore it if it's not)
--  join_ok       - the button that makes the magic happen

local function loadconfig()
	local host,port,pass,name,colour = felt.config.get(
		"join:host",
		"join:port",
		"join:pass",
		"name",
		"colour"
	)
	
	ui.win.join_host:set("text", host)
	ui.win.join_port:set("text", tostring(port))
	ui.win.join_password:set("text", pass)
	ui.win.join_name:set("text", name)
	ui.setColour(ui.win.join_colour, colour)
end

local function saveconfig()
	local host = ui.win.join_host:get("text")
	local port = tonumber(ui.win.join_port:get("text"))
	local pass = ui.win.join_password:get("text")
	local name = ui.win.join_name:get("text")
	local colour = ui.getColour(ui.win.join_colour)
	
	felt.config.set(
		"join:host", host,
		"join:port", port,
		"join:pass", pass,
		"name", name,
		"colour", colour
	)
end

-- Game -> Join
function ui.win.menu_game_join:activate()
	loadconfig()
	ui.win.join_window:show_all()
	ui.win.join_window:run()
	ui.win.join_window:hide_all()
	saveconfig()
end

function ui.win.join_cancel:clicked()
	ui.win.join_window:response(0)
end

-- connect to a game
function ui.win.join_ok:clicked()
	local host = ui.win.join_host:get("text")
	local port = tonumber(ui.win.join_port:get("text"))
	local pass = ui.win.join_password:get("text")
	local name = ui.win.join_name:get("text")
	local colour = ui.getColour(ui.win.join_colour)
	
	if #host == 0 then
		return ui.error("You must specify a host to connect to.")
	elseif not port or port <= 0 or port > 65535 or port % 1 ~= 0 then
		return ui.error("You must specify a valid numeric port.")
	end
	
	ui.win.join_window:response(1)

	client = new "client.RemoteClient" {
		name = name;
		colour = colour;
		host = host;
		port = port;
		pass = pass;
	}
	client:connect(host, port, pass)
end
