require "init"
require "felt"
client = stubify("client") --require "client"
server = stubify("server") --require "server"
require "ui"

felt.init()
ui.run()

-- FIXME: once ui.run returns, that indicates that the user requested a quit.
-- If we're currently connected to or, god forbid, hosting a game, we need to
-- shut that down cleanly before exiting.

--[[

Notes
ID handling: IDs are strings, not integers. Each client is assigned a unique ID on connect, and generates IDs for objects it creates as <client id>:<object id>. It uses an incrementing counter for the object id and skips any IDs already in use - this will mainly come into effect when resuming old games. Objects created by the server have ID prefix 0.

Connection and player management: server sets up first, creates or loads game, clients connect to it. Serialization is messy - need to keep track of which clients have which objects, when serializing an object serialize to ID, but if the client doesn't have any object, generate a new-object message as you do so.

:wrap=soft:
]]