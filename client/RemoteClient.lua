require "socket"

class(..., "client.Client")

socket = false

function send(self, ...)
	assert((...), "no object in client send")
	local buf = new "Serialization" { metamethod = "__send" }
		:pack(table.pack(...))
		:finalize()
	sendmsg(self.socket, buf)
end

function connect(self, host, port)
	self:message("Connecting to %s:%d", host, port)
	local socket,err = socket.connect(host, port)
	if not socket then
		self:message("Connection failed: %s", err)
		return socket,err
	end
	
	socket:settimeout(0)
	
	self.host = host
	self.port = port
	self.socket = socket

	self:message("Sending login request")
	self:send(server, "login", self.name, self.pass)
	return true
end

function disconnect(self, reason)
	self:message("Disconnected: %s", reason)
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
		local buf = assert(recvmsg(sock))
		return new "Deserialization" { data = buf, object = object } :unpack()
	end
		
	-- read messages from the socket
	while true do
		local status,message = pcall(readmsg, self.socket)
		if not status then
			if not message:match("timeout") then
				assert(status, message)
				-- whoops, error reading from the socket
				self:dispatch { self, "disconnect", status }
			end
			break
		else
			self:dispatch(message)
		end
	end
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
	self:message("Game state received from server, unpacking...")
	game = new "Deserialization" { data = game } :unpack()
	_setGame(self, game)
end
