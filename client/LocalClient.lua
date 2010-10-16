class(..., "client.Client")

-- This is a client for connecting to a server running in the same process.
-- Its send method simply pushes the event straight into the server's event
-- queue, without serialization.

function send(self, ...)
	return server:pushEvent(table.pack(...))
end

function connect(self, host, port, pass)
	self.pass = pass
	
	self:send(server, "login", self, self.name, self.pass)
	
	return true
end

function disconnect(self, reason)
	ui.error("Disconnected by server: %s")
	self.server = nil
	self.player = nil
	self.game = nil
end
