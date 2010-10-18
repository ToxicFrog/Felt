class(..., "client.Client")

-- This is a client for connecting to a server running in the same process.
-- Its send method simply pushes the event straight into the server's event
-- queue, without serialization.

function send(self, ...)
	local evt = table.pack(...)
	function evt.reply(_, ...)
		self:dispatch(table.pack(...))
	end
	print("client send", ...)
	return server:pushEvent(evt)
end

function connect(self, host, port, pass)
	self.pass = pass
	
	self:send(server, "login", self.name, self.pass)
	
	return true
end

function disconnect(self, reason)
	ui.error("Disconnected by server: %s")
	self.server = nil
	self.player = nil
	self.game = nil
end

local _setGame = setGame
function setGame(self, ...)
	_setGame(self, ...)
		
	local foo = new "felt.Field" { name = "foo" }; foo:add(new "felt.Token" {}, 0, 0)
	felt.game:addField(foo)
end
