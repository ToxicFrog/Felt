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
	
	self.socket:settimeout(0)
	copas.addthread(self.ServerReader, self)
	
	return true
end

-- cleanly shut down the client. FIXME: not implemented
function stop(self)
    print(debug.traceback())
    if self.socket then
        self.socket:close()
        self.socket = nil
    end
    self._break = true
    print("stop")
end

-- server worker function. Handles all communication with the server. Runs
-- inside copas.
function ServerReader(_, self)
    copas.setErrorHandler(function(message, thread, socket)
        self:message("Error receiving message from server: %s", message)
        self:message(debug.traceback(thread, "  Stack trace:"))
        self:stop()
    end)
    
    self:message("Waiting for acknowledgement from server")
    
    -- enter dispatch loop
    while true do
        local msg = self:recv()
        if not msg then break end
        self:message(" << %s %s", tostring(msg.self), tostring(msg.method))
        self:dispatch(msg)
    end
    
    self:message("client terminating")
end

function ServerWriter(_, self)
    copas.setErrorHandler(function(message, thread, socket)
        self:message("Error sending message to server: %s", message)
        self:stop()
    end)
    
    while #self.sendq > 0 do
        local msg = table.remove(self.sendq, 1)
                
        self:message(" >> %s %s", tostring(msg.self), tostring(msg.method))
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

function recv(self)
    return box.unpack(copas.recvmsg(self.socket), (self.game and self.game.objects))
end

function message(self, fmt, ...)
	return ui.message("[client] "..fmt, ...)
end

function dispatch(self, msg)
    if not msg.self then
        assert(self.api[msg.method], "no method "..tostring(msg.method).." in client API")
        self.api[msg.method](self, table.unpack(msg))
    else
        msg.self[msg.method](msg.self, table.unpack(msg))
    end
end

-- mainloop function for the client. The UI is expected to call this frequently
-- (say, 5-30 times a second) to collect network traffic and process pending
-- events.
function step(self, timeout)
    if not self._break then
        copas.step(timeout)
    end
    return not self._break
end

function loop(self, timeout)
    while not self._break do
        print("loop", self._break)
        copas.step(timeout)
    end
    self._break = nil
end

api = {}

function api:message(...)
    return ui.message(...)
end

function api:game(game)
    self.game = game
    for k,v in pairs(game.objects) do
        print(k,v,v.name,v._TYPE,v.x,v.y,v.z)
    end
end
