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

-- set up UI
ui = {}
function ui.message(...)
    print(string.format(...))
end

local defaults = {
    name = "ToxicFrog";
    colour = { r=0, g=1, b=1 };
    host = "localhost";
    port = 8088;
}

local C = new "Client" (ddgetopts(defaults, ...))
assert(C:start())

-- Each call to Client::update processes some pending messages. In the final
-- version we register a GTK+ timer to call this ten times a second or so
while C:update(0.1) do end

C:shutdown()
