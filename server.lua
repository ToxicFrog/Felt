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

-- set up UI
ui = {}
function ui.message(...)
    print(string.format(...))
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

-- the server needs to be manually "pumped"; each call to update processes all
-- pending events.
while S:update() do end

S:shutdown()
