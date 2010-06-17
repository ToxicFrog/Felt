local win = gtk.Builder.new_from_file("felt.glade")

function win.window:delete_event()
	os.exit() -- FIXME - proper shutdown
end

-- Felt -> Join Game
function win.menu_join:activate()
	local name, colour, host, port = "ToxicFrog", "#ff0000", "localhost", 8088 --FIXME felt.config:get("name", "colour", "join-host", "join-port")
	
	win.join_name:set("text", name)
	win.join_colour:set("color", gdk.color_parse(colour))
	win.join_host:set("text", host)
	win.join_port:set("text", tostring(port))
	
	local errmsg = gtk.MessageDialog.new(win.dialog_join
	, gtk.DIALOG_DESTROY_WITH_PARENT
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
	
	local function cleanup()
		win.dialog_join:hide()
		errmsg:destroy()
	end
	
	repeat local result = win.dialog_join:run()
		if result ~= 1 then return cleanup() end
		
		name = win.join_name:get "text"
		colour = gdk.Color.to_string(win.join_colour:get "color")
		host = win.join_host:get "text"
		port = tonumber(win.join_port:get "text")
		
	until validate(name, colour, host, port)
	
	cleanup()
	
	-- fixme
	felt.config:set("name", name, "colour", colour, "join-host", host, "join-port", port)
	felt.connect(host, port)
end

-- Felt -> Host Game
function win.menu_host:activate()
	local name, colour, port = "ToxicFrog", "#ff0000", 8088 --FIXME felt.config:get("name", "colour", "host-port")
	
	win.host_name:set("text", name)
	win.host_colour:set("color", gdk.color_parse(colour))
	win.host_port:set("text", tostring(port))
	
	local errmsg = gtk.MessageDialog.new(win.dialog_host
	, gtk.DIALOG_DESTROY_WITH_PARENT
	, gtk.MESSAGE_ERROR
	, gtk.BUTTONS_CLOSE
	, "")
	
	local function validate(name, colour, port)
		local function err(message)
			errmsg:set("text", "You must specify a "..message)
			errmsg:run()
			errmsg:hide()
			return false
		end
		
		if #name == 0 then
			return err "name"
		elseif not port then
			return err "numeric port"
		else
			return true
		end
	end
	
	local function cleanup()
		win.dialog_host:hide()
		errmsg:destroy()
	end
	
	repeat local result = win.dialog_host:run()
		if result ~= 1 then return cleanup() end
		
		name = win.host_name:get "text"
		colour = gdk.Color.to_string(win.host_colour:get "color")
		port = tonumber(win.host_port:get "text")
		print(name, colour, port)
		
	until validate(name, colour, port)
	
	cleanup()
	
	-- FIXME
	felt.config:set("name", name, "colour", colour, "host-port", port)
	felt.host(port)
end

-- Felt -> Quit
function win.menu_quit:activate()
	os.exit()
end

-- helper function to display save/load dialog
local function sldialog(title, action)
	win.dialog_save_load:set("title", title, "action", gtk["FILE_CHOOSER_ACTION_"..action])
	win.dialog_save_load:show_all()
	local result = win.dialog_save_load:run()
	win.dialog_save_load:hide()
	if result == 1 then
		return win.dialog_save_load:get_filename()
	end
	return nil
end

-- Game -> New Table
function win.menu_newtable:activate()
	felt.newtable()
end

-- Game -> Save
function win.menu_save:activate()
	local file = sldialog("Save Game", "SAVE")
	if file then
		felt.savegame(file)
	end
end

-- Game -> Load Table
function win.menu_load_table:activate()
	local file = sldialog("Load Table", "OPEN")
	if file then
		felt.loadtable(file)
	end
end

-- Game -> Load Module
function win.menu_load_module:activate()
	local file = sldialog("Load Module", "OPENDIR")
	if file then
		felt.loadmodule(file)
	end
end

-- Game -> Load Game
function win.menu_load_game:activate()
	local file = sldialog("Load Game", "OPEN")
	if file then
		felt.loadgame(file)
	end
end

-- Help -> about
function win.menu_about:activate()
	win.dialog_about:run()
	win.dialog_about:hide()
end

return win
