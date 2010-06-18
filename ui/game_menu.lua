local win = ui.mainwindow

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

-- Game -> New Field
function win.menu_new_field:activate()
	felt.newtable()
	local field = {
		draw = function(self, cr)
			cr:set_source_rgba(0, 0, 1, 1)
			cr:rectangle(-10, -10, 20, 20)
			cr:fill()
		end;
	}
	ui.field(field).window:show_all()
end

-- Game -> Save
function win.menu_save:activate()
	local file = sldialog("Save Game", "SAVE")
	if file then
		felt.savegame(file)
	end
end

-- Game -> Load Table
function win.menu_load_field:activate()
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
