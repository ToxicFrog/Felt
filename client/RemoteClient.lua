require "socket"

class(..., "client.Client")

socket = false
events = {}

function send(self, ...)
	local buf = new "Serialization" { metamethod = "__send" }
		:pack(table.pack(...))
		:finalize()
	self.socket:send(tostring(#buf).."\n")
	self.socket:send(buf)
	print("CLIENT SEND", #buf, buf)
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

	self:send(server, "login", self.name, self.pass)
	return true
end

function disconnect(self, reason)
	ui.error("Disconnected: %s", reason)
	self.socket:close()
	os.exit(0)
end

function update(self)
	local function object(id)
		if id == "C" then return self
		else return felt.game:getObject(id)
		end
	end

	local function readmsg(sock)
		local buf = assert(sock:receive())
		local len = assert(tonumber(buf), "corrupt message header")
		local data = assert(sock:receive(len))
		return new "Deserialization" { data = data, object = object } :unpack()
	end
		
	-- read messages from the socket
	while true do
		local status,message = pcall(readmsg, self.socket)
		if not status then
			if not message:match("timeout") then
				-- whoops, error reading from the socket
				self:pushEvent { self, "disconnect", message }
			end
			break
		else
			self:pushEvent(message)
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

local _setGame = setGame
function setGame(self, game)
	game = new "Deserialization" { data = game } :unpack()
	_setGame(self, game)
end
