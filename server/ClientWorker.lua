require "copas"
require "box"

class("ClientWorker", "Object")

local _init = __init
function __init(self, t)
    _init(self, t)
    
    -- this table tracks which objects the remote client knows about. It is
    -- needed by the serializer to determine which objects to serialize entire
    -- and which ones to serialize by ID.
    self.objects = {}

    -- this is the client's send queue
    self.sendq = {}
    self.name = "client:"..self.socket:getpeername()
end

function __tostring(self)
    return self.name
end

function setName(self, name)
    self.name = name
    -- future versions - maybe some interoperation with visibility tables or the like?
end

function setPlayer(self, player)
    self.player = player
end

function sendOne(self, protected)
    if #self.sendq == 0 then return end

    if not protected then
        return xpcall(function()
            return self:sendOne(true)
        end, function(message)
            self:log("Error sending message: %s", message)
            self:log("%s", debug.traceback("  Stack trace:"))
            self:disconnect("Send error.")
        end)
    end
    
    for k,v in pairs(self.sendq) do print(k,v) end
    
    local msg = assert(table.remove(self.sendq, 1), "INSANITY")
    local buf = box.pack(msg, self.objects)
    assert(self.socket:send(string.format("%d\n%s", #buf, buf)))
    self:log(">> %s:%s(%s)", tostring(msg.self), tostring(msg.method), table.concat(list.map(msg, f "x -> tostring(x)"), ", "))
end

function receiveOne(self, protected)
    if not protected then
        return xpcall(function()
            return self:receiveOne(true)
        end, function(message)
            self:log("Error receiving message: %s", message)
            self:log("%s", debug.traceback("  Stack trace:"))
            self:disconnect("Recieve error.")
        end)
    end
    
    local len = assert(tonumber(assert(self.socket:receive("*l"))), "malformed message header")
    local buf = assert(self.socket:receive(len))
    local msg = box.unpack(buf, server.game().objects)
    self:log("<< %s:%s(%s)", tostring(msg.self), tostring(msg.method), table.concat(list.map(msg, f "x -> tostring(x)"), ", "))
    
    server.dispatch(msg, self)
end

function send(self, msg)
    table.insert(self.sendq, msg)
    
    return self
end

function sendNow(self, msg)
    local buf = box.pack(msg, self.objects)
    self.socket:settimeout(math.huge)
    self.socket:send(string.format("%d\n%s", #buf, buf))
end

function disconnect(self, message)
    self:log("Closing connection to %s: %s", self.socket:getpeername(), tostring(message))
    self:sendNow {
        method = "message";
        "Disconnected: "..tostring(message);
    }
    server.unregister(self)
end

function log(self, fmt, ...)
    return server.log("["..tostring(self).."] "..fmt, ...)
end
