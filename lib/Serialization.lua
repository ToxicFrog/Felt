--[[
serialization format
A serialized message consists of any number of concatenated items.

nil		:= 'n'
true	:= 't'
false	:= 'f'
number	:= 'N' value
string	:= 'S' size value
table	:= 'T' size (item item)*
no function
no userdata
no thread
]]

-- a serialization context needs to track the following:
-- - buffer so far
-- - indentation level
-- - backreference table
-- and expose the following methods:
-- - indent
-- - exdent
-- - ref
-- - append
-- - finalize

class(...)

metamethod = "__save"
index = 0
repr = {}

local _init = __init
function __init(self, t)
	_init(self, t)
	
	self.buffer = {}
	self.refs = {}
end

function append(self, ...)
	if select('#', ...) == 0 then return end
	
	table.insert(self.buffer, (...))
	self:append(select(2, ...))
end

function finalize(self)
	return table.concat(self.buffer)
end

function pack(self, value)
	self.index = self.index +1

	if self.refs[value] then
		return self.repr.backref(self, value)
	end
	
	self.refs[value] = self.index
	
	local mt = getmetatable(value)
	local buf
	
	if mt and mt[self.metamethod] then
		mt[self.metamethod](value, self)
	elseif self.repr[type(value)] then
		self.repr[type(value)](self, value)
	else
		error("Invalid type for serialization: "..type(value))
	end
end
	
repr["nil"] = function()
	self:append("n")
end

function repr:boolean(b)
	self:append(b and "t" or "f")
end

function repr:number(n)
	self:append("N", tostring(n), ":")
end

function repr:string(s)
	self:append("S", tostring(#s), ":", s)
end

function repr:backref(v)
	self:append("R", tostring(self.refs[v]), ":")
end

function repr:table(t)
	local n = 0
	local buf = {}
	
	for k,v in pairs(t) do n = n+1 end
	
	self:append("T", tostring(n), ":\n")
	
	for k,v in pairs(t) do
		self:pack(k)
		self:append("\n  ")
		self:pack(v)
		self:append("\n")
	end
end
