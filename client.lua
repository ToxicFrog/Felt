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

-- loop infinitely sending and receiving messages
-- once a UI is hooked up, it should call C:step() several times a second instead
-- if something goes wrong, C:loop() will return at all, and C:step() will return
-- false instead of true.
C:loop()
