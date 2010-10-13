-- This is a simple intermediate class used by the locally connected client.
-- All method calls on it are translated into pushEvent calls on the
-- backing server.

local super = class(..., felt.Object)

function __index(self, method)
	return function(self, ...)
		return self.server:pushEvent(table.pack(self.server, method, ...))
	end
end

function send(self, event)
	return self.server:pushEvent(event)
end

function connect(self, host, port)
	return true
end