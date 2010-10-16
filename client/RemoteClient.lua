require "socket"

class(..., "client.Client")

socket = false
events = {}

function send(self, ...)
	-- FIXME: send event through socket
	local event = table.pack(...)
	for i=1,event.n do
		event[i] = tostring(event[i])
	end
	self.socket:send(table.concat(event, " ").."\n")
end

function connect(self, host, port)
	local socket,err = socket.connect(host, port)
	if not socket then
		return socket,err
	end
	
	socket:settimeout(0)
	
	self.host = host
	self.port = port
	self.socket = socket

	self:send(server, "login", self, self.name, self.pass)
	return true
end

function disconnect(self, reason)
	ui.error("Disconnected: %s", reason)
	self.socket:close()
	os.exit(0)
end

function update(self)
	-- read messages from the socket
	while true do
		local msg,err = self.socket:receive()
		if err == "timeout" then
			break
		elseif err then
			self:pushEvent { self, "disconnect", err }
			break
		else
			self:pushEvent { self, "message", "network traffic: %s", tostring(msg) }
		end
	end
	
	local i = 1
	local events = self.events
	
	while events[i] do
		self:dispatch(events[i])
		i = i+1
	end
	
	self.events = {}
end

function pushEvent(self, evt)
	table.insert(self.events, evt)
end

function dispatch(self, evt)
	local obj = evt[1]
	local method = evt[2]
	
	assert(obj, "Malformed RMI: no object")
	assert(obj[method], "Malformed RMI: object "..tostring(obj).." has no method "..tostring(method)) 
	obj[method](obj, unpack(evt, 3))
end
