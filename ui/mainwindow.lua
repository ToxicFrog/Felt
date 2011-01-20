ui.win = ui.loadFile("ui/felt.glade")

require "ui.settings"
require "ui.join_game"
require "ui.host_game"
require "ui.save_load_game"

ui.win.main_window:connect("delete-event", gtk.main_quit)

function ui.win.menu_game_quit:activate()
	gtk.main_quit()
end
