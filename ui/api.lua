-- public API functions for the user interface. Any UI implemented must
-- provide these.

-- Enter the UI mainloop. Called once the initialization routines are done
-- setting everything up. Returns on program exit.

local function server_update()
	server:update(); return true
end

local function client_update()
	client:update(); return true
end

local su_closure,cu_closure

function ui.run()
	require "ui.settings" ()
	
	ui.win.main_window:show_all()
	
	su_closure = gnome.closure(server_update)
	cu_closure = gnome.closure(client_update)
	
	glib.timeout_add(50, su_closure, nil)
	glib.timeout_add(50, cu_closure, nil)
	
	gtk.main()
end

-- Display a message to the user.
function ui.message(...)
	local buf = ui.win.messages:get_buffer()
	local str = string.format(...)
	print("[ui]", str)
	
	buf:insert_at_cursor(str.."\n", #str+1)
	
	-- FIXME - if adding lots of text, may not scroll all the way to the bottom
	-- older versions used scroll_to_mark but that crashed on windows
	-- and changing it to this was easier
	local adj = ui.win.scrolledwindow1:get_vadjustment()
	adj:set("value", adj:get_upper())
end

-- display an error to the user
local errmsg = gtk.message_dialog_new(nil, gtk.DIALOG_MODAL, gtk.MESSAGE_ERROR, gtk.BUTTONS_CLOSE, "")
function ui.error(...)
	errmsg:set("text", string.format(...))
	errmsg:run()
	errmsg:hide()
end

-- Set the UI info line.
function ui.set_info(text, image)
	-- FIXME
	ui.message("STUB: set_info")
end

function ui.show_game(game)
	assert(not ui.game, "double call to ui.show_game")
	ui.game = game
	
	for _,field in pairs(ui.game.fields) do
		ui.show_field(field)
	end
	
	-- set menu entries according to the fact that we are now in game
	ui.win.menu_game_join:set("sensitive", false)
	ui.win.menu_game_host:set("sensitive", false)
	ui.win.menu_game_save:set("sensitive", true)
	ui.win.menu_game_load:set("sensitive", true)
end

function ui.show_field(field)
	if not ui.fields[field] then
		ui.fields[field] = ui.field(field)
	end
	ui.fields[field].window:show_all()
end

ui.fields = {}
