require "copas"
require "box"

class("Client", "common.Object")

local _init = __init
function __init(self, t)
    _init(self, t)
    
    -- this table tracks which objects the remote client knows about. It is
    -- needed by the serializer to determine which objects to serialize entire
    -- and which ones to serialize by ID.
    self.objects = {}
end

function ClientReader(self)
    copas.setErrorHandler(function(message, thread, socket)
        self:message("Read error in worker connected to %s", socket:getpeername())
        self:message("  Reported error is: %s", message)
        self:message("  Disconnecting client %s.", socket:getpeername())
        socket:close()
    end)
    
    self:message("Client connecting from %s", self.socket:getpeername())
    
    -- these will raise an error if we fail, the copas error handler will
    -- take care of reporting it and closing the socket
    -- if all the checks pass, the server now adds us to the game and the client
    -- table, and sends the current game state.
    -- at some point we probably want them to send a list of available modules
    -- on login so we can reject them before they get to this point if they
    -- don't have the right modules installed
    self.server:register(self, self:recv())
    
    -- and now we just sit in the mainloop reading and processing messages
    for msg in self.recv,self do
        local r,e
        if not msg.self then
            -- no self specified? It's a call to the server public API.
            r,e = pcall(self.server.api[msg.method], self.server, self. table.unpack(msg))
        else
            -- it's a method call on an in-game object
            r,e = pcall(msg.self[msg.method], msg.self, self, table.unpack(msg))
        end
        -- report errors
        if not r then
            self:close("RMI error: "..e)
            return
        end
    end
    
    self:close("End of socket data - REPORT THIS AS A BUG")        
end

function ClientWriter(self)
    copas.setErrorHandler(function(message, thread, socket)
        self:message("Write error in worker connected to %s", socket:getpeername())
        self:message("  Reported error is: %s", message)
        self:message("  Disconnecting client %s.", socket:getpeername())
        socket:close()
    end)
    
    while #self.sendq > 0 do
        local msg = table.remove(self.sendq, 1)
        
        if msg == false then
            -- a 'false' message is inserted to kill the Client
            self.server:unregister(self)
            return
        end
        
        copas.sendmsg(self.socket, box.pack(msg, self.objects))
    end
    -- no more messages in queue? Shut down. A new thread will be spawned if needed.
end

function send(self, msg)
    table.insert(self.sendq, msg)
    
    -- if the queue was previously empty, we need to spawn a worker
    copas.addthread(self.ClientWriter, self)
    
    return self
end

function recv(self)
    return box.unpack(copas.recvmsg(self.socket), self.objects)
end

function close(self, message)
    self:message("Closing connection to %s: %s", self.socket:getpeername(), message)
    self:send {
        method = "message";
        "Disconnected: "..message;
    }
    self:send(false)
end

function message(self, ...)
    return self.server:message(...)
end

