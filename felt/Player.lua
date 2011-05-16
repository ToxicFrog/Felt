class(..., felt.Object)

nextid = 0

mixin "mixins.serialize" ("nextid", "name", "colour")

local _init = __init
function __init(self, t)
	t.id = t.name
	_init(self, t)
end

function __tostring(self)
	return assert(self.name, "nameless player detected")
end

function uniqueID(self)
	self.nextid = self.nextid +1
	return string.format("%s::%d", self.name, self.nextid)
end

function server_pickup(self, who, item)
	ui.message("pickup: holding %s, item %s, held by %s", tostring(self.held), tostring(item), tostring(item.held_by))
	if self.held then return end
	if item.held_by then return end
	
	self:pickup(item)
end

function client_pickup(self, item)
	ui.message("%s picks up %s", tostring(self), tostring(item))
	self.held = item
	item.held_by = self
end

function server_drop(self, who, onto, x, y)
	if not self.held then return end -- sanity check
	self.held:dispatchEvent("dropped", x, y, onto)
	onto:dispatchEvent("caught", x, y, self.held)
	self:drop(onto, x, y)
end

function client_drop(self, onto, x, y)
	local item = self.held
	self.held = nil
	item.held_by = nil
	
	ui.message("%s drops %s onto %s", tostring(self), tostring(item), tostring(onto))
end

function client_setColour(self, colour)
	self.colour = colour
end
