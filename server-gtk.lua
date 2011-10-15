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

require "init"
require "ddgetopts"
require "Object"
require "glib"
require "gnome"
require "gtk"

package.path = "server/?.lua;server/?/init.lua;"..package.path

local defaults = {
    name = "Felt Game";
    host = "*";
    port = 8088;
    admin = 8089;
    load = false;
    pass = false;
}

local S = new "Server" (ddgetopts(defaults, ...))

-- the server needs to be manually "pumped"; each call to update processes all
-- pending events.
local update = gnome.closure(function() return S:update() end)
glib.timeout_add(50, update)

-- when this returns, the server should shut down
gtk.main()
S:shutdown()
