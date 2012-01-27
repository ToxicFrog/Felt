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
--require "lqt_debug"

copas = nil

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

ui = { fields = {} }
function ui.message(...)
    print(string.format(...))
    log:append(string.format(...))
end

function ui.addField(field)
    ui.message("field: %s", tostring(field))
    field.ui = field.ui or {}
    field.ui.scene = QGraphicsScene()
    field.ui.view = QGraphicsView(field.ui.scene)
    field.ui.view:setWindowTitle("Felt - "..tostring(field))
    field.ui.view:show()
end

local defaults = {
    name = "ToxicFrog";
    colour = { r=0, g=1, b=1 };
    host = "localhost";
    port = 8088;
}

local C = new "Client" (ddgetopts(defaults, ...))
assert(C:start())

--local timer = QTimer()
--timer:connect(Qt.SIGNAL("timeout()"), function() return C:step(0.1) end)
--timer:start(0)

while C:step(0.1) do
    --app.exec()
    app.sendPostedEvents()
    app.processEvents()
end
