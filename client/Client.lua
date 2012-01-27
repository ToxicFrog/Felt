-- a client is fairly complicated; it needs to react to user input and to
-- messages from the server, providing both a socket interface to the server
-- and a graphical interface to the user.
-- Fortunately, a client.Client is quite simple. Basically all it needs to do
-- is maintain a world model for the view to look at.
require "socket"
require "socket-helpers"
require "box"

class("Client", "Object")

local client_instance = nil

local _init = __init
function __init(self, t)
    _init(self, t)

    self.sendq = {}
    self.objects = {}

    client_instance = self
end

function instance()
    return client_instance
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
	
	self.socket:settimeout(0.05)

    self:send {
        method = "login";
        self.name, self.pass;
    }
	
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
function ServerReader(self, protected)
    if not protected then
        return xpcall(function()
            return self:ServerReader(true)
        end, function(message)
        self:message("Error receiving message from server: %s", message)
            self:message(debug.traceback(thread, "  Stack trace:"))
            self:stop()
        end)
    end
    
    self.socket:settimeout(0)
    
    local result,err = self.socket:receive("*l")
    if result then
        self.socket:settimeout(math.huge)
        local buf = self.socket:receive(tonumber(result))
        print(buf)
        local msg = box.unpack(buf, (self.game and self.game.objects))
        self:message(" << %s %s", tostring(msg.self), tostring(msg.method))
        self:dispatch(msg)
    elseif err ~= "timeout" then
        error(err)
    end
    
    self.socket:settimeout(0.05)
end

function ServerWriter(self, protected)
    if not protected then
        return xpcall(function()
            return self:ServerWriter(true)
        end, function(message)
            self:message("Error sending message to server: %s", message)
            self:message(debug.traceback(thread, "  Stack trace:"))
            self:stop()
        end)
    end
    
    if not self.sendbuf and #self.sendq > 0 then
        if self.game then
            table.print(self.game.objects)
        end
        local msg = table.remove(self.sendq, 1)
        local buf = box.pack(msg, self.objects)
        
        self:message(" Q> %s %s", tostring(msg.self), tostring(msg.method))
        self:message("    %s", buf)
        self.sendbuf = string.format("%d\n%s", #buf, buf)
    end
    
    if self.sendbuf then
        local result,err,last = self.socket:send(self.sendbuf)
        self:message(" >> %s %s %s", tostring(result), tostring(err), tostring(last))
        if result then
            self.sendbuf = nil
        elseif err == "timeout" then
            self.sendbuf = self.sendbuf:sub(last+1)
        else
            error(err)
        end
    end
end

function send(self, msg)
    table.insert(self.sendq, msg)
    
    return self
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
    self:ServerReader()
    self:ServerWriter()
    return not self._break
end

function loop(self, timeout)
    while not self._break do
        self:step(timeout)
    end
    self._break = nil
end

api = {}

function api:message(...)
    return ui.message(...)
end

function api:game(game)
    self.game = game
end
