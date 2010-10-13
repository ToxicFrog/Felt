--[[
	This is where the magic happens.
	Object just contains the basics of the object system - inheritance, mixins,
	metamethods.
	felt.Object contains Felt-specific additional features - serialization to
	network and disk, the ID system, automatic RMI, etc
]]

local super = class(..., Object)

function __init(self, ...)
	super.__init(self, ...)
	
	local rmi = {}
	
	for k,v in pairs(self) do
		if k:match("^server_") or k:match("^client_") then
			local stem = k:gsub("^[^_]+_", "")
			local side = k:match("^[^_]+")
			
			rmi[side.."."..stem] = v
			rmi[stem] = function(self, ...)
				-- determine if we are in server or client context
				-- if in client context: generate RMI of server.stem
				-- if in server context: generate broadcast RMI of client.stem
				ui.message("RMI stub %s:%s", tostring(self), stem)
				if server.updating then
					-- we are in server context
					-- broadcast a call to the client version to all clients
					server.broadcast(self, "client."..stem, ...)
				else
					-- we are in client context
					-- unicast to the server
					client.send(self, "server."..stem, ...)
				end
			end
			self[k] = nil
		end
	end
	
	for k,v in pairs(rmi) do
		assert(not self[k], "Method name collision initializing RMI subsystem")
		self[k] = v
	end
end
