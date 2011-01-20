-- helper function to display save/load dialog
local function sldialog(title, action)
	ui.win.dialog_save_load:set("title", title, "action", gtk["FILE_CHOOSER_ACTION_"..action])
	ui.win.dialog_save_load:show_all()
	local result = ui.win.dialog_save_load:run()
	ui.win.dialog_save_load:hide()
	if result == 1 then
		return ui.win.dialog_save_load:get_filename()
	end
	return nil
end

-- disable these menu entries on load, since 
ui.win.menu_game_save:set("sensitive", false)
ui.win.menu_game_load:set("sensitive", false)

-- Game -> Save
function ui.win.menu_game_save:activate()
	local file = sldialog("Save Game", "SAVE")
	if file then
		ui.message("Save game: %s", file)
		felt.save_game(file)
	end
end

-- Game -> Load
function ui.win.menu_game_load:activate()
	local file = sldialog("Load Game", "LOAD")
	if file then
		ui.message("Load game: %s", file)
--		felt.savegame(file)
	end
end
