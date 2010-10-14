-- Clients are a bit trickier than servers, perhaps.
-- As a client, what do we need?
-- - a game state
-- - an event queue, which is filled (in a nonspecific manner) with events
--   from the server
-- - an update method, which is called frequently by the main loop and empties
--   the event queue

-- The event (de)serialization machinery is going to be particularly ugly.
-- We need a special ID for "this", the connection owner - the client itself
-- Initial handshake is something like: client calls S:addPlayer via RMI to the
-- server (we need a stubserver on this end for that, then) passing it credentials.
-- server responds with either a this:disconnect message, or by sending it the
-- entire gamestate (this:setGame) and a unique ID (this:setID)

-- how does this special ID work when it's a localconnect and the client and
-- server are just calling pushEvent on each other?
-- Does the client send itself in the initial handshake, and when not using
-- pushevent, this gets translated into the special 'this' ID? That seems
-- like the easiest approach.

class(..., felt.Object)

game = nil; -- the game state
server = nil; -- the local representation of the remote server

function setGame(self, game)
	felt.game = game
	felt.me = new "felt.Player" {
		name = felt.config.get "name";
		colour = felt.config.get "colour";
	}
	game:addPlayer(felt.me)
	
	game:addField("foo"):add(new "felt.Token" {}, 0, 0)
	game:addField("bar"):add(new "felt.Token" {}, 16, 16)	
	ui.show_game(game)
end

function setPlayer(self, player)
	self.player = player
end

function send(self, object, method, ...)
	self.server:send { object, method, ... }
end

function update(self)
end

-- establish a connection to the server and send a message saying who
-- we are. The server will reply either telling us to shut up (and closing
-- the connection) or by telling us to set up a game.
function connect(self, host, port, pass)
	error("not yet implemented")
	assert(not self.server, "Already connected to "..tostring(self.server))
	
	self.server = new "client.RemoteServer" {
		host = host;
		port = port;
	}

	self.server:login(self, self.name, self.pass)
end

-- this is a bit different; the server is running in the same process as the
-- client. We need to push our join event into the server's event queue
-- directly.
function connectlocal(self, pass)
	self.name = felt.config.get "name"
	self.colour = felt.config.get "colour"
	self.pass = pass

	self.server = new "client.LocalServer" {}

	self.server:login(self, self.name, self.pass)
end
