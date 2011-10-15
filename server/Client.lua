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

-- each instance of this function is responsible for handling a single client.
-- Whenever a client connects, copas will automatically create a new thread
-- from this function; when it returns, the socket is closed.
-- Note that neither this function, nor anything called by it, should EVER
-- send data (or perform additional socket reads); doing so may permit the
-- thread to block halfway through an operation on shared state and awaken
-- another thread.
-- Instead, use the server's :sendTo and :broadcast methods, which will
-- insert the messages into a queue which is periodically emptied by another
-- thread.
function run(self)
    copas.setErrorHandler(function(...) return self:reportError(...) end)
    
    self:message("client connecting from %s", self.socket:getpeername())
    
    -- perform login negotiation
    -- the expectation is that the connecting client will send a player info
    -- block - a table containing name, pass, and colour.
    -- we then validate that block, ensuring that the password matches ours (if
    -- any) and that there doesn't already exist a player by that name.
    -- If this is the case, we allocate a server-side Client structure and
    -- transmit the current game state to them.
    -- If the login fails, we disconnect them. FIXME: how?
    local info = box.unpack(copas.recvmsg(self.socket))
    local result,err = self.server:login(self, info)
    if not result then
        self:message("Rejecting connection from %s: %s", self.socket:getpeername(), err)
        self:send(false):send(err)
        return
    end
    
    self:send(true):send(self.server.game)
    
    -- at this point we just sit in a loop reading messages from the client
    -- and invoking method calls in response
    -- A single message consists of:
    --  an object ID
    --  a method name
    --  zero or more arguments to the method
    local function dispatch(msg)
        msg.object[msg.method](msg.object, table.unpack(msg))
    end
    
    local msg,err = copas.recvmsg(self.socket)
    while msg do
        dispatch(box.unpack(msg))
        msg,err = copas.recvmsg(self.socket)
    end
    
    self:message("disconnecting %s (%s)", self.socket:getpeername(), err)
    self.server:logout(info.name)
    
    return
end

function login(self, info)
    print(info)
    for k,v in pairs(info) do
        self:message("[login] %s: %s", tostring(k), tostring(v))
    end
    return true
end

function message(self, ...)
    return self.server:message(...)
end

function send(self, obj)
    copas.sendmsg(self.socket, box.pack(obj, self.objects))
    return self
end

-- error reporting function for client worker threads
-- this will be called if an error is raised inside any client worker
function reportError(self, message, thread, socket)
    self:message("Error in worker connected to %s", socket:getpeername())
    self:message("  Reported error is: %s", message)
    self:message("  This client will be disconnected. Save your game and report this as a bug.")
end
