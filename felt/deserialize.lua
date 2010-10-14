local unrepr = {}

local function wrap(str)
	local t = {}
	
	function t:read(n)
		local buf
		if type(n) == "number" then
			buf = str:sub(1,n)
			assert(#buf == n, "Serialized data is truncated")
		elseif type(n) == "string" then
			buf = assert(str:match("^"..n), "Serialized data is corrupt")
		else
			buf = assert(str:match("^([^:]+):"), "Serialized data is corrupt")
			str = str:sub(#buf+2, -1)
			return buf
		end

		str = str:sub(#buf+1,-1)
		return buf
	end
	
	function t:skip()
		str = str:gsub("^%s+", "")
	end
	
	function t:len()
		return #str
	end
	
	function t:raw() return str end
	
	return t
end

local function next(data)
	data:skip()
	local key = data:read(1)
	return unrepr[key](data)
end

function unrepr.S(data)
	local len = tonumber(data:read())
	return data:read(len)
end

function unrepr.N(data)
	return tonumber(data:read())
end

function unrepr.t() return true end
function unrepr.f() return false end
function unrepr.n() return nil end

function unrepr.T(data)
	local T = {}
	local n = tonumber(data:read())
	
	for i=1,n do
		local k = next(data)
		local v = next(data)
		T[k] = v
	end
	
	return T
end

function unrepr.I(data)
	local id = next(data)
	
	return felt.game:getObject(id)
end

function felt.deserialize(buf)
	local data = wrap(buf)
	local t = { n=0 }
	
	while data:len() > 0 do
		t.n = t.n +1
		t[t.n] = next(data)
		data:skip()
	end
	
	return unpack(t, 1, t.n)
end
