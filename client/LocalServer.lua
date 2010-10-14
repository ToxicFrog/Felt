-- This is a simple intermediate class used by the locally connected client.
-- All method calls on it are translated into pushEvent calls on the
-- backing server.

class(..., felt.Object)

function __index(self, method)
	return function(self, ...)
		return server:pushEvent(table.pack(server, method, ...))
	end
end

function send(self, event)
	return server:pushEvent(event)
end

function connect(self, host, port)
	return true
end