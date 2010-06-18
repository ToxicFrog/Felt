local win = ui.mainwindow

local errmsg = gtk.MessageDialog.new(nil
	, gtk.DIALOG_MODAL
	, gtk.MESSAGE_ERROR
	, gtk.BUTTONS_CLOSE
	, "")

local function validate(name, colour, host, port)
	local function err(message)
		errmsg:set("text", "You must specify a "..message)
		errmsg:run()
		errmsg:hide()
		return false
	end
	
	if #name == 0 then
		return err "name"
	elseif #host == 0 then
		return err "host"
	elseif not port then
		return err "numeric port"
	else
		return true
	end
end

-- Felt -> Join Game
function win.menu_join:activate()
	local name, colour, host, port = felt.config.get("name", "colour", "join-host", "join-port")
	
	win.join_name:set("text", name)
	win.join_colour:set("color", gdk.color_parse(colour))
	win.join_host:set("text", host)
	win.join_port:set("text", tostring(port))
	
	repeat local result = win.dialog_join:run()
		if result ~= 1 then return win.dialog_join:hide() end
		
		name = win.join_name:get "text"
		colour = gdk.Color.to_string(win.join_colour:get "color")
		host = win.join_host:get "text"
		port = tonumber(win.join_port:get "text")
		
	until validate(name, colour, host, port)
	
	win.dialog_join:hide()
	
	-- FIXME
	felt.config.set("name", name, "colour", colour, "join-host", host, "join-port", port)
	felt.connect(host, port)
end

-- Felt -> Host Game
function win.menu_host:activate()
	local name, colour, port = felt.config.get("name", "colour", "host-port")
	
	win.host_name:set("text", name)
	win.host_colour:set("color", gdk.color_parse(colour))
	win.host_port:set("text", tostring(port))
	
	repeat local result = win.dialog_host:run()
		if result ~= 1 then return win.dialog_host:hide() end
		
		name = win.host_name:get "text"
		colour = gdk.Color.to_string(win.host_colour:get "color")
		port = tonumber(win.host_port:get "text")
		print(name, colour, port)
		
	until validate(name, colour, "unused", port)
	
	win.dialog_host:hide()
	
	-- FIXME
	felt.config.set("name", name, "colour", colour, "host-port", port)
	felt.host(port)
end

-- Felt -> Quit
function win.menu_quit:activate()
	os.exit() -- FIXME - exit cleanly
end

