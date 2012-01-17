-- A server is mainly an event collector and dispatcher. Fundamentally, it
-- consists of the following:
-- - a game state
-- - an event queue, which is filled (in a nonspecific manner) with events
--   generated by the clients
-- - an update method which is called often and empties the queue, dispatching
--   the events stored therein
-- - a means by which RMIs can be propagated to the clients
--   - this implies a set of clients and a broadcast API
require "socket"
require "socket-helpers"
require "copas"

class("Server", "common.Object")


-- constructor fields: 
-- name: name of game, for server browsers
-- host: interface to bind to
-- port: port to bind to
-- pass: game password. Optional.
-- admin: port for admin console. Always binds to localhost. Optional.
-- load: saved game to load on startup. Optional.
local _init = __init
function __init(self, t)
	_init(self, t)
	self.sendq = {}
	self.clients = {}
end

function start(self)
	-- if these aren't set, it's a programming error
	assert(self.port and self.host and self.name, "Invalid arguments to constructor for server.Server")
	assert(not self.game, "Server is already running")

    local err
    self.socket,err = socket.bind(self.host, self.port)
    
    if not self.socket then
        return nil,err
    end
    
    copas.addserver(self.socket, function(...) return self:clientWorker(...) end)
    self.game = new "Game" {}
    self.game:addField("test")
    self:message("Listening on port %d", self.port)
    
    return true
end

-- cleanly shut down the server. FIXME: not implemented
function stop(self)
    self:broadcast {
        method = "message";
        "Disconnected: server shutting down";
    }
    self:broadcast(false)
    self._break = true
end

-- each instance of this function is responsible for handling a single client.
-- Whenever a client connects, copas will automatically create a new thread
-- from this function; when it returns, the socket is closed.
-- Note that neither this function, nor anything called by it, should EVER
-- send data (or perform additional socket reads); doing so may permit the
-- thread to block halfway through an operation on shared state and awaken
-- another thread.
-- Instead, use the server's :sendTo and :broadcast methods, which will
-- insert the messages into a queue which is periodically emptied by another
-- thread.
function clientWorker(self, sock)
    new "ClientWorker" {
        socket = sock;
        server = self;
    }
end

function register(self, client)
    self:message("Client connected from %s.", tostring(client))

    -- send them the initial gamestate
    client:send {
        method = "game";
        self.game;
    }

    -- tell everyone that they've arrived
    self:broadcast {
        method = "message";
        "%s joins the game.", tostring(client);
    }
end

function broadcast(self, msg)
    for client in pairs(self.clients) do
        client:send(msg)
    end
end

function step(self, timeout)
    copas.step(timeout)
    return true
end

function loop(self, timeout)
    self._break = nil
    repeat
        copas.step(timeout)
    until self._break
    self._break = nil
end

-- server message function, prefixes messages with [server]
function message(self, fmt, ...)
	return ui.message("[server] "..fmt, ...)
end

function dispatch(self, sender, msg)
    if not msg.self then
        assert(self.api[msg.method], "no method "..tostring(msg.method).." in server API")
        self.api[msg.method](self, sender, table.unpack(msg))
    else
        msg.self[msg.method](msg.self, sender, table.unpack(msg))
    end
end

-- public API callable by clients
-- signature is (self, client, ...)
api = {}

function api:chat(client, ...)
    self:broadcast {
        method = "chat";
        client.player.name, ...;
    }
end
