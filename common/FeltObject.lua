--[[
	This is where the magic happens.
	Object just contains the basics of the object system - inheritance, mixins,
	metamethods.
	felt.Object contains Felt-specific additional features - serialization to
	network and disk, the ID system, the RMI interface, etc
]]

class(..., "common.Object")

id = false

mixin "mixins.serialize" ("id")
local _init = __init
function __init(self, t)
	_init(self, t)
	
	if self.id == true then
	    assert(not self:isInstanceOf("client.FeltObject", "attempt to instantiate named object on the client"))
		self.id = felt.uniqueID() -- FIXME
	end
	
	if self.id then
		if felt.game then felt.game:addObject(self) end
		if not self.replicant then
			self:replicate(t)
		end
	end
end
