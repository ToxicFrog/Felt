require "copas"
require "box"

class("ClientWorker", "common.Object")

local _init = __init
function __init(self, t)
    _init(self, t)
    
    -- this table tracks which objects the remote client knows about. It is
    -- needed by the serializer to determine which objects to serialize entire
    -- and which ones to serialize by ID.
    self.objects = {}
    self.sendq = {}
    self.name = "client:"..self.socket:getpeername()
    
    return self:ClientReader()
end

function __tostring(self)
    return self.name
end

function ClientReader(self)
    copas.setErrorHandler(function(message, thread, socket)
        print("ERROR ON READ", message, thread, socket)
        self:message("Read error in worker connected to %s", self.name)
        self:message("  Reported error is: %s", tostring(message))
        self:message(debug.traceback(thread, "  Stack trace:"))
        
        -- send them a message explaining what happened, if we can
        if socket then
            -- pcall(self.forceClose, self, tostring(message))
        end

        self:message("  Disconnecting client %s.", self.name)
        self.server:unregister(self)
    end)
    
    self:message("Client connecting from %s", self.socket:getpeername())
    
    -- register this client with the server
    self.server:register(self)
    
    -- and now we just sit in the mainloop reading and processing messages
    -- we do it this way (rather than using recv as an iterator) because we
    -- can't yield across iterators in 5.1
    while true do
        local msg = self:recv()
        if not msg then break end
        self:message(" << %s %s", tostring(msg.self), tostring(msg.method))
        self.server:dispatch(msg, self)
    end
    
    self:close("End of socket data - REPORT THIS AS A BUG")        
end

function ClientWriter(self)
    copas.setErrorHandler(function(message, thread, socket)
        print("ERROR ON WRITE", message, thread, socket)
        self:message("Write error in worker connected to %s", self.name)
        self:message("  Reported error is: %s", tostring(message))
        self:message(debug.traceback(thread, "  Stack trace:"))

        -- send them a message explaining what happened, if we can
        if socket then
            --pcall(self.forceClose, self, tostring(message))
        end

        self:message("  Disconnecting client %s.", self.name)
        self.server:unregister(self)
    end)
    
    while #self.sendq > 0 do
        local msg = table.remove(self.sendq, 1)
        
        if msg == false then
            -- a 'false' message is inserted to kill the Client
            self.server:unregister(self)
            return
        end
        
        self:message(" >> %s %s", tostring(msg.self), tostring(msg.method))
        copas.sendmsg(self.socket, box.pack(msg, self.objects))
    end
    -- no more messages in queue? Shut down. A new thread will be spawned if needed.
end

function send(self, msg)
    table.insert(self.sendq, msg)
    
    -- if the queue was previously empty, we need to spawn a worker
    copas.addthread(function() return self:ClientWriter() end)
    
    return self
end

function recv(self)
    return box.unpack(copas.recvmsg(self.socket), self.server.game.objects)
end

function close(self, message)
    self:message("Closing connection to %s: %s", self.socket:getpeername(), message)
    self:send {
        method = "message";
        "Disconnected: "..message;
    }
    self:send(false)
end

function forceClose(self, message)
    self.socket:settimeout(0.1)
    socket.sendmsg(self.socket, box.pack {
        method = "message";
        "Disconnected: "..message;
    })
end

function message(self, ...)
    return self.server:message(...)
end

