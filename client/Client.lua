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

-- server worker function. Handles all communication with the server. Runs
-- inside copas.
function worker(_, self)
    copas.setErrorHandler(function(message, thread, socket)
        self:message("Error receiving message from server: %s", message)
        socket:close()
    end)
    
    self:message("Sending login request")
    -- attempt login
    self:send {
        name = self.name;
        pass = self.pass;
        colour = self.colout;
    }
    
    self:message("Waiting for reply")
    
    -- enter dispatch loop
    while true do
        print(box.unpack(copas.recvmsg(self.socket)))
    end
end

function ServerWriter(self)
    copas.setErrorHandler(function(message, thread, socket)
        self:message("Error sending message to server: %s", message)
        socket:close()
    end)
    
    while #self.sendq > 0 do
        local msg = table.remove(self.sendq, 1)
                
        copas.sendmsg(self.socket, box.pack(msg, self.objects))
    end
    -- no more messages in queue? Shut down. A new thread will be spawned if needed.
end

function send(self, msg)
    table.insert(self.sendq, msg)
    
    -- if the queue was previously empty, we need to spawn a worker
    copas.addthread(self.ServerWriter, self)
    
    return self
end

function message(self, fmt, ...)
	return ui.message("[client] "..fmt, ...)
end

-- mainloop function for the client. The UI is expected to call this frequently
-- (say, 5-30 times a second) to collect network traffic and process pending
-- events.
function step(self, timeout)
    return copas.step(timeout)
end

function loop(self)
    return copas.loop()
end
