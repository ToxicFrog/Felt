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

local repr = {}


local function serialize(...)
    if select('#', ...) == 0 then return "" end
    
    return (function(v, ...)
        if getmetatable(v) and getmetatable(v).__save then
            return getmetatable(v).__save(v)..serialize(...)
        end
        
        if repr[type(v)] then
            return repr[type(v)](v)..serialize(...)
        end
    
        return error("Cannot serialize type '"..type(v).."'")
    end)(...)
end

repr["nil"] = function()
	return "n"
end

function repr.boolean(b)
	return b and "t" or "f"
end

function repr.number(n)
	return "N"..tostring(n)..":"
end

function repr.string(s)
	return "S"..tostring(#s)..":"..s
end

local indent = ""
function repr.table(t)
	local n = 0
	local buf = {}
	
	indent = indent.."    "
	
	for k,v in pairs(t) do
		n = n+1
		local key = serialize(k)
		local value = serialize(v)
		table.insert(buf, indent)
		table.insert(buf, key)
		table.insert(buf, "\t")
		table.insert(buf, value)
		table.insert(buf, "\n")
	end
	
	indent = indent:sub(1,-5)
	return "T"..tostring(n)..":".."\n"..table.concat(buf)
end
felt.serialize = serialize

