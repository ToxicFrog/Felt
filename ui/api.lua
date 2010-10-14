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
	ui.win.message_window:show_all()
	
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
	
	buf:insert_at_cursor(str.."\n", #str+1)

	local mark = buf:get_mark "scroller"
	if not mark then
		local iter = gtk.new "TextIter" --gtk.text_iter_new()
		buf:get_end_iter(iter)
		mark = buf:create_mark("scroller", iter, false)
	end
	ui.win.messages:scroll_to_mark(mark, 0.1, false, 0, 0)
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
	
	ui.win.main_window:hide_all()
	for _,field in pairs(ui.game.fields) do
		ui.show_field(field)
	end
	
	-- FIXME: enable player/field visibility controls
end

function ui.show_field(field)
	assert(ui.game, "call to ui.show_field before ui.show_game")
	ui.field(field).window:show_all()
end
