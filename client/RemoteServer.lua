-- This is a more complex server class. Where LocalServer is a wrapper around
-- a server.Server object in the same program, RemoteServer is a wrapper around
-- a network socket communicating with a Server on a remote host.

require "socket"

local super = class(..., felt.Object)

id = "S"

function __init(self, ...)
	super.__init(self, ...)
	
	print(self.host, self.port)
	local socket,err = socket.connect(self.host, self.port)
	print(socket, err)
end

function __index(self, method)
	return function(self, ...)
		return self:send(table.pack(self, method, ...))
	end
end

function send(self, event)
	-- FIXME: send event through socket
	print(event)
end
