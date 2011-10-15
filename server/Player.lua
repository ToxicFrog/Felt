class("Player", "common.Object")

local _init = __init
function __init(self, ...)
    _init(self, ...)
    
    -- set of objects that the client already knows about, and can thus be
    -- sent by ID rather than packed in their entirety.
    -- It is assumed to start out with knowledge of C (the special ID that refers
    -- to the client itself) and with knowledge of S (the stub object on the
    -- client that represents the remote server. FIXME: do we actually need S?
    self.objects = { C = true, S = true }
end

-- send a message through the player's associated socket
function sendmsg(self, ...)
    self.socket:sendmsg(self.objects, ...)
end
