local unpack = {}

local function next(buf)
    local size,buf = buf:match("(%d+):(.*)")
    local box,buf = buf:sub(1,size), buf:sub(size+1)
    
    return getunpacker(
end

local function getunpacker(key)
    return unpack[buf] or error("I don't know how to unpack values with tag '%s'" % key)
end

function box.unpack(buf)
    return next(buf)
    getunpacker(buf:sub(1,1))(buf:sub(2))
end

function unpack.n()
    return nil
end

function unpack.t()
    return true
end

function unpack.f()
    return false
end

function unpack.N(buf)
    return tonumber(buf)
end

function unpack.S(buf)
    return buf
end

function unpack.T(buf)
end

function unpack.M(buf)
    local typesize,buf = readsize(buf)
    
    require(buf:sub(1,typesize)).__unpack(