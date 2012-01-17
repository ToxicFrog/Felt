-- for sending and receiving messages
-- a message consists of a length in bytes, a newline, and then
-- that many bytes of data.

require "socket"
require "copas"

-- send a packed message to the other end. This can consist of any number of
-- lua objects.
-- "data" is an opaque handle that will be passed to the __send metamethods
-- of any objects supporting them. At present, it is a set of objects which
-- are already known to the receiving side; __send is expected to see if
-- data[self] is set, and if so, generate an ID reference rather than a complete
-- packed object.
local function sendmsg(send, msg)
    return assert(send(string.format("%d\n%s", #msg, msg)))
end

function socket:sendmsg(msg)
    return sendmsg(function(...) return self:send(...) end, msg)
end

function copas:sendmsg(msg)
    return sendmsg(function(...) return copas.send(self, ...) end, msg)
end

local function recvmsg(recv)
    local buf = assert(recv())
    local len = assert(tonumber(buf), "corrupt message header")
    
    return assert(recv(len))
end

function socket:recvmsg()
    return recvmsg(function(...) return self:receive(...) end)
end

function copas:recvmsg()
    return recvmsg(function(...) return copas.receive(self, ...) end)
end

