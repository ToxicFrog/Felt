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
require "server.init"

_DEBUG = false

-- set up UI
ui = {}
function ui.message(...)
    print(select(2, pcall(string.format, ...)))
end

local defaults = {
    name = "Felt Game";
    host = "*";
    port = 8088;
    admin = 8089;
    load = false;
    pass = false;
}

local S = new "Server" (ddgetopts(defaults, ...))
S:start()

S:loop(0.1)

S:shutdown()
