--require "net"

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

--[[
local function net_serialize(v, ...)
    if v == nil and select('#', ...) == 0 then return "" end
    
    if getmetatable(v) and getmetatable(v).__send then
        return getmetatable(v).__send(v)..net.serialize(...)
    end
    
    if repr[type(v)] then
        return repr[type(v)](v, net.serialize)..net.serialize(...)
    end
    
    return error("Cannot serialize type '"..type(v).."'")
end
--]]

function repr.string(s)
    return string.format("S%08d%s", #s, s)
end

function repr.number(n)
    return string.format("N%08d%s", #tostring(n), tostring(n))
end

function repr.boolean(b)
    return b and "Bt" or "Bf"
end

function repr.table(t, f)
    local buf = { "T" }
    for k,v in pairs(t) do
        buf[#buf+1] = (f or serialize)(k)
        buf[#buf+1] = (f or serialize)(v)
    end
    buf[#buf+1] = "t"
    
    return table.concat(buf, "")
end

repr["nil"] = function() return "." end

string.serialize = serialize

