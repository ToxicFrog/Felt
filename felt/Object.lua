--[[
	This is where the magic happens.
	Object just contains the basics of the object system - inheritance, mixins,
	metamethods.
	felt.Object contains Felt-specific additional features - serialization to
	network and disk, the ID system, automatic RMI, etc
]]

class(..., Object)

id = false
replicant = false

mixin "mixins.serialize" ("id", "replicant")

-- set up the RMI stubs:
-- * search the object for methods starting with "server_" or "client_"
-- * for each such method, install it as "server.method" or "client.method"
-- * generate a plain 'method' that calls the server version if called by the
--   client, and the client version if called by the server
local function setupRMI(self)
	local rmi = {}
	
	for k,v in pairs(self) do
		if k:match("^server_") or k:match("^client_") then
			local side,stem = k:match("^([^_]+)_(.*)")
			
			rmi[stem] = rmi[stem] or {}
			rmi[stem][side] = v
			--self[k] = nil
		end
	end
	
	for method,v in pairs(rmi) do
		if not v.server then
			function v:server(...)
				self[method](self, ...)
			end
		end
		
		function v:stub(...)
			-- determine if we are in server or client context
			-- if in client context: generate RMI of server.stem
			-- if in server context: generate broadcast RMI of client.stem
			if server.updating then
				-- we are in server context
				-- broadcast a call to the client version to all clients
				server:broadcast(self, "client."..method, ...)
			else
				-- we are in client context
				-- unicast to the server, along with our identity
				client:send(self, "server."..method, felt.me, ...)
			end
		end
		
		assert(not self[method], "Method name collision initializing RMI subsystem")
		self[method] = v.stub
		self["client."..method] = v.client
		self["server."..method] = v.server
	end
end

function replicate(self, t)
	t.id = self.id
	t.replicant = true
	self.replicant = true
	self._ORIGINAL = true
	felt.game:newObject(self._NAME, t)
end

local _init = __init
function __init(self, t)
	_init(self, t)
	
	setupRMI(self)
	
	if self.id == true then
		self.id = felt.me:uniqueID()
	end
	
	if self.id then
		if felt.game then felt.game:addObject(self) end
		if not self.replicant then
			self:replicate(t)
		end
	end
end
