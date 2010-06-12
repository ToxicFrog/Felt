local CallableSet = require "Object" :subclass "CallableSet"

function CallableSet:__init(content)
	self.content = {}
	if (content) then
		for k in pairs(content) do
			self.content[k] = true
		end
	end
end

function CallableSet:copy()
	return new "CallableSet" (self.content)
end

function CallableSet:__call(val, ...)
	local function set(val)
		self.content[val] = true
		return set
	end
	local function unset(val)
		self.content[val] = nil
		return unset
	end
	
	if select('#', ...) > 0 then
		val = ...
	end
	
	if val then
		return set(val)
	else
		return unset
	end
end

function CallableSet:contents()
	return pairs(self.content)
end

function CallableSet:__test()
	local function pcs(cs)
		for k in cs:contents() do
			print(k)
		end
	end
	
	local function contains(key)
		return self.content[key]
	end
		
	local cs = self
	assert(self:contents()(self.content, nil) == nil)
	
	self "a" "b" "c"
	assert(contains "a" and contains "b" and contains "c")
	
	self (false) "b"
	assert(not contains "b")
	
	local t = { cs = self }
	t:cs "d" "e" "f"
	assert(contains "d" and contains "e" and contains "f")
	
	t:cs (false) "a" "c"
	assert(not contains "a" and not contains "c")
	
	print(serialize(self))
end

return CallableSet
