local unpack = {}
local do_unpack,getunpacker,readtoc
local map = list.map

function box.unpack(buf)
    return do_unpack(buf, {})
end

function do_unpack(buf, refs)
    return getunpackmethod(buf:sub(1,1))(buf:sub(2), refs)
end
    
function getunpackmethod(key)
    return unpack[key] or error("I don't know how to unpack values with tag '%s'" % key)
end

function readtoc(buf)
    local data = {}
    local offs = 1
    
    local next = buf:match("^[%d:]+"):gmatch("(%d+):()")
    local size = tonumber((next()))
    
    while size >= 1 do
        data[#data+1],offs = next()
        size = size-1
    end
    
    return map(data, function(len)
        offs = offs + len
        return buf:sub(offs - len, offs - 1)
    end)
end    

-- nil is packed as the single character "n"
function unpack.n()
    return nil
end

-- booleans are packed as "t" or "f"
function unpack.t()
    return true
end

function unpack.f()
    return false
end

-- numbers are "N" followed by the base ten number
function unpack.N(buf)
    return (assert(tonumber(buf), "malformed serialized number %s" % buf))
end

-- strings are "S" followed by the unmodified string
function unpack.S(buf)
    return buf
end

-- backreferences are "R" followed by a cache index
function unpack.R(buf, refs)
    return (assert(refs[tonumber(buf)], "invalid backreference %s" % buf))
end

function unpack.T(buf)
end

-- tables are "T" followed by a TOC followed by a sequence of K,V pairs
function unpack.T(buf, refs)
    local T = {}
    refs[#refs+1] = T
    
    local data = map(readtoc(buf), function(x) return do_unpack(x, refs) end)
    
    for i=1,#data,2 do
        T[data[i]] = data[i+1]
    end
    
    return T
end

-- metamethod calls are a "C" followed a TOC, type name, and single argument
function unpack.C(buf, refs)
    local data = readtoc(buf)
    
    local type,arg = do_unpack(data[1], refs),do_unpack(data[2], refs)
    
    local obj = assert(require(type).__unpack(arg), "error deserializating object of type %s" % tostring(type))
    refs[#refs+1] = obj
    return obj
end
