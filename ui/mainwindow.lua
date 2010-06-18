ui.mainwindow = gtk.Builder.new_from_file("ui/felt.glade")

require "ui.felt_menu"
require "ui.game_menu"

local win = ui.mainwindow

-- hook up the kill-window decoration
function win.window:delete_event()
	os.exit() -- FIXME - proper shutdown
end

-- Help -> about
function win.menu_about:activate()
	win.dialog_about:run()
	win.dialog_about:hide()
end

return win
