ui.win = ui.loadFile("ui/felt.glade")

require "ui.settings"
require "ui.join_game"
require "ui.host_game"

ui.win.main_window:connect("delete-event", gtk.main_quit)
