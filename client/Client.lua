-- a client is fairly complicated; it needs to react to user input and to
-- messages from the server, providing both a socket interface to the server
-- and a graphical interface to the user.
-- Fortunately, a client.Client is quite simple. Basically all it needs to do
-- is maintain a world model for the view to look at.
require "socket"
require "socket-helpers"
require "copas"
require "box"

class("Client", "common.Object")

local _init = __init
function __init(self, t)
    _init(self, t)
    self.sendq = {}
end

function start(self)
	assert(self.port and self.host and self.name, "Invalid client configuration")
	assert(not self.game, "Client is already connected")
	
	local err
	self.socket,err = socket.connect(self.host, self.port)
	
	if not self.socket then
	    return nil,err
	end
	
	self:message("connected to %s", self.socket:getpeername())
	
	copas.addthread(self.worker, self)
	
	return true
end

-- cleanly shut down the client. FIXME: not implemented
function stop(self)
    assert(self.game, "client is not connected")
    error "not implemented"
end

-- server message function, prefixes messages with [server]
function message(self, fmt, ...)
	return ui.message("[client] "..fmt, ...)
end

-- server worker function. Handles all communication with the server. Runs
-- inside copas.
function worker(_, self)
    
    self:message("Sending login request")
    -- attempt login
    self:send {
        name = self.name;
        pass = self.pass;
        colour = self.colout;
    }
    
    self:message("Waiting for reply")
    -- read response
    local result = box.unpack(copas.recvmsg(self.socket))
    
    if not result then
        local reason = box.unpack(copas.recvmsg(self.socket))
        self:message("connection rejected: %s", reason)
        self:shutdown()
        return
    end
    
    self:message("login accepted")
    self.game = box.unpack(copas.recvmsg(self.socket))

    -- enter event loop
    while true do
        print(box.unpack(copas.recvmsg(self.socket)))
    end
end

function send(self, message)
--    self.sendq[#self.sendq+1] = message
    socket.sendmsg(self.socket, box.pack(message))
end 

function sendQueuedMessages(self)
    for i,msg in ipairs(self.sendq) do
        self:message(">> %s", tostring(msg))
        socket.sendmsg(self.socket, box.pack(msg))
        self.sendq[i] = nil
    end
end

-- mainloop function for the client. The UI is expected to call this frequently
-- (say, 5-30 times a second) to collect network traffic and process pending
-- events.
function update(self, timeout)
    copas.step(timeout)
    self:sendQueuedMessages()
    return true
end
