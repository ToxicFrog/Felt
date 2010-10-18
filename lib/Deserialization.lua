class(...)

unrepr = {}
index = 0

local _init = __init
function __init(self, t)
	_init(self, t)
	
	self.refs = {}
	assert(self.data, "Deserialization requires input!")
end

function unpack(self)
	local obj = self:next()
	self:skip()
	
	if #self.data > 0 then
		return obj,self:unpack()
	else
		return obj
	end
end

-- return the previously-deserialized object associated with the 
function ref(self, key)
	return self.refs[key]
end

function next(self)
	self:skip()
	self.index = self.index +1
	local index = self.index
	local key = self:read(1)
	assert(self.unrepr[key], "Unknown tag while deserializing: "..key)
	local value =  self.unrepr[key](self)
	self.refs[index] = value
	return value
end

function read(self, n)
	if not n then
		local buf = assert(self.data:match("^([^:]+):"), "Serialized data is corrupt")
		self.data = self.data:sub(#buf+2, -1)
		return buf
	end

	buf = self.data:sub(1,n)
	assert(#buf == n, "Serialized data is truncated")

	self.data = self.data:sub(#buf+1,-1)
	return buf
end

function skip(self)
	self.data = self.data:gsub("^%s+", "")
end

function unrepr:S()
	local len = tonumber(self:read())
	return self:read(len)
end

function unrepr:N()
	return tonumber(self:read())
end

function unrepr:t() return true end
function unrepr:f() return false end
function unrepr:n() return nil end

function unrepr:T()
	local T = {}
	local n = tonumber(self:read())
	
	for i=1,n do
		local k = self:next()
		local v = self:next()
		T[k] = v
	end
	
	return T
end

function unrepr:I()
	local id = self:next()
	
	assert(self.object, "attempt to deserialize I-tags without an id->object mapping!")
	
	return assert(self.object(id), "no object with id "..tostring(id).." while deserializing")
end

function unrepr:R()
	local id = tonumber(self:read())
	
	return self:ref(id)
end

function unrepr:C()
	local class = self:next()
	local arg = self:next()
	local obj = new(class)(arg)
	if obj.__load then
		obj:__load(arg)
	end
	return obj
end
