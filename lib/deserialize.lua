local unrepr = {}

local function deserialize_one(buf)
    if #buf == 0 then
        return
    end
    
    if unrepr[buf:sub(1,1)] then
        return unrepr[buf:sub(1,1)](buf:sub(2,-1))
    end
    
    print(buf)
    return error("Unknown tag '"..buf:sub(1,1).."' while deserializing")
end

local function deserialize(buf)
    if buf then
        assert(type(buf) == "string", "invalid argument to deserialize: "..type(buf))
        local val,buf = deserialize_one(buf)
        return val,deserialize(buf)
    end
    
    return
end

function unrepr.S(buf)
    local len = tonumber(buf:sub(1,8))
    return buf:sub(9, 8+len),buf:sub(9+len, -1)
end

function unrepr.N(buf)
    local len = tonumber(buf:sub(1,8))
    return tonumber(buf:sub(9, 8+len)),buf:sub(9+len, -1)
end

function unrepr.B(buf)
    return buf:sub(1,1) == "t",buf:sub(2,-1)
end

unrepr["."] = function(buf)
    return nil,buf
end

function unrepr.T(buf)
    local function next()
        local val
        val,buf = deserialize_one(buf)
        return val
    end

    local val = {}
    
    while buf:sub(1,1) ~= "t" do
        local k,v = next(),next()
        val[k] = v
    end

    return val,buf:sub(2,-1)
end

-- unpack via library load
function unrepr.L(buf)
    local function next()
        local val
        val,buf = deserialize_one(buf)
        return val
    end
    
    local module = next()
    local func = next()
    
    local argv = {}
    local argc = 0
    
    while buf:sub(1,1) ~= "l" do
        argc = argc+1
        argv[argc] = next()
    end
    
    return require(module)[func](require(module), unpack(argv, 1, argc)),buf:sub(2,-1)
end

string.deserialize = deserialize

