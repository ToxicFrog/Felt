local pack = {}
local do_pack,getpackmethod,maketoc
local map = list.map

function box.pack(obj, objs, ...)
    return do_pack(obj, {n=1}, objs, ...)
end

function do_pack(obj, refs, objs, ...)
    return getpackmethod(obj, refs, objs)(obj, refs, objs, ...)
end

function getpackmethod(obj, refs, objs)
    local mt = getmetatable(obj)
    
    -- if we've packed this before, generate a backreference to the cached value
    if refs[obj] then
        return pack["ref"]
    
    -- if we know the deserializer already has it, send just a lookup key for it
    elseif objs and objs[obj] then
        return pack["obj"]
        
    elseif mt and mt.__pack then
        return pack["metamethod"]
    
    elseif pack[type(obj)] then
        return pack[type(obj)]
        
    else
        error("I don't know how to pack '%s', which is of type '%s'" % { tostring(obj), type(obj) })
    end
end

function maketoc(data)
    return #data .. ":" .. table.concat(map(data, f "x -> tostring(#x)..':'")) 
end
    
-- nil is packed as the single character "n"
pack["nil"] = function()
    return "n"
end

-- booleans are packed as "t" or "f"
pack["boolean"] = function(b)
    return b and "t" or "f"
end

-- numbers are "N" followed by the base ten number
pack["number"] = function(n)
    return "N"..tostring(n)
end

-- strings are "S" followed by the unmodified string
pack["string"] = function(s)
    return "S"..s
end

-- backreferences are "R" followed by a cache index
pack["ref"] = function(obj, refs)
    return "R"..refs[obj]
end

-- references to objects the deserializer already has are "O" followed by an
-- object id
pack["obj"] = function(obj, refs, objs)
    print("O-ref", objs[obj])
    return "O"..objs[obj]
end

-- tables are "T" followed by a TOC followed by a sequence of K,V pairs
pack["table"] = function(obj, refs, ...)
    refs[obj] = refs.n; refs.n = refs.n + 1
    
    local data = {}
    
    for k,v in pairs(obj) do
        data[#data+1] = do_pack(k, refs, ...)
        data[#data+1] = do_pack(v, refs, ...)
    end
    
    return "T"..maketoc(data)..table.concat(data)
end

-- metamethod calls are a "C" followed a TOC, type name, and single argument
pack["metamethod"] = function(obj, refs, ...)
    local mm = getmetatable(obj).__pack
    
    local how,what,with = mm(obj, ...)
    if how == "raw" then
        refs[obj] = refs.n; refs.n = refs.n + 1
        return what
        
    elseif how == "pack" then
        return do_pack(what, refs, ...)
        
    elseif how == "call" then
        refs[obj] = refs.n; refs.n = refs.n + 1
        local data = { do_pack(what, refs, ...), do_pack(with, refs, ...) }
        return "C"..maketoc(data)..table.concat(data)
        
    else
        return error("__pack metamethod returned illegal values starting with "..tostring(how))
    end
end
