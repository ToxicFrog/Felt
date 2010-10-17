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

local _init = __init
function __init(self, t)
	_init(self, t)
	self.name = felt.config.get "name"
	self.colour = felt.config.get "colour"
	self.id = "C"
end

function message(self, format, ...)
	return ui.message("[client] "..format, ...)
end

function setGame(self, game)
	felt.game = game
	felt.me = new "felt.Player" {
		name = felt.config.get "name";
		colour = felt.config.get "colour";
	}
	game:addPlayer(felt.me)
	ui.show_game(game)
	
	local foo = new "felt.Field" { name = "foo" }; foo:add(new "felt.Token" {}, 0, 0)
	game:addField(foo)
end

function setPlayer(self, player)
	self.player = player
end

function send(self, object, method, ...)
	error("attempt to send while not connected to a game")
end

function update()
end

function dispatch(self, evt)
	print("dispatch", unpack(evt))
	local obj = evt[1]
	local method = evt[2]
	
	assert(obj, "Malformed RMI: no object")
	assert(obj[method], "Malformed RMI: object "..tostring(obj).." has no method "..tostring(method)) 
	obj[method](obj, unpack(evt, 3))
end
