-- entry point for Felt server program
-- usage: require this, then do something like
-- server.main {
--   host = "*";
--   port = 1234;
--   load = "saved_game.felt";
--   name = "my game";
--   pass = "secret";
-- }
-- server.main returns when a server shutdown is completed, either from the
-- server console or by the admin (FIXME: UI work needed here

require "felt"
require "ddgetopts"
require "client.init"

require "qtcore"
require "qtgui"

function Qt.SIGNAL(name)
    return "2"..name
end

function Qt.SLOT(name)
    return "1"..name
end

_DEBUG = false

-- set up GUI
local app = QApplication(1, {'Felt'})
local log = QTextEdit()
log:setWindowTitle("Felt - Log")
log:setReadOnly(true)

log:show()

ui = {}
function ui.message(...)
    print(string.format(...))
    log:append(string.format(...))
end

local defaults = {
    name = "ToxicFrog";
    colour = { r=0, g=1, b=1 };
    host = "localhost";
    port = 8088;
}

local C = new "Client" (ddgetopts(defaults, ...))
assert(C:start())

local timer = QTimer()
timer:connect(Qt.SIGNAL("timeout()"), function() print("step") return C:step(0.1) end)
timer:start(0)

app.exec()
