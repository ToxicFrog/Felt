local win = ui.win

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

-- Game -> Save
function win.menu_game_save:activate()
	ui.message("[STUB] Save Game")
	do return end
	local file = sldialog("Save Game", "SAVE")
	if file then
		felt.savegame(file)
	end
end

-- Game -> Load
function win.menu_game_load:activate()
	ui.message("[STUB] Load Game")
end

-- Fields -> New
function win.menu_field_new:activate()
	ui.message("[STUB] New Field")
	--ui.field(new "felt.Field" {}).window:show_all()
end

-- Fields -> Vis

-- Fields -> Load
function win.menu_field_load:activate()
	ui.message("[STUB] Load Field")
end

-- Fields -> Save

-- Players -> Vis

-- Help -> About
