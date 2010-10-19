class(..., "client.Client")

-- This is a client for connecting to a server running in the same process.
-- Its send method simply pushes the event straight into the server's event
-- queue, without serialization.

function send(self, ...)
	local evt = table.pack(...)
	function evt.reply(_, ...)
		self:dispatch(table.pack(...))
	end
	evt.sock = self
	print("client send", ...)
	return server:pushEvent(evt)
end

function connect(self)
	self:send(server, "login", self.name, self.pass)
	
	return true
end

function disconnect(self, reason)
	ui.error("Disconnected by server: %s", reason)
	self.server = nil
	self.player = nil
	self.game = nil
end

local _sg = setGame
function setGame(self, ...)
	if not self.game then
		_sg(self, ...)
		-- build index of loadable modules
		require "modules.gameboxes"
	else
		_sg(self, ...)
	end
end
