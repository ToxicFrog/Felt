math.randomseed(os.time())

package.cpath = "lgob/lib/lua/5.1/?.so"

-- an xpcall that permits varargs
function va_xpcall(f, e, ...)
    local argc = select('#', ...)
    local argv = {...}
    
    return xpcall(function() return f(unpack(argv,1,argc)) end, e)
end

-- converse of unpack
function table.pack(...)
    return { n = select('#', ...), ... }
end

-- instantiate something on all nodes simultaneously
function new(type)
    return function(...)
        local obj = require(type)(...)
        print("new", type, obj.id, felt.widgets[obj.id])
        return obj
    end
end

-- converse of assert
function tressa(result, ...)
    if not result then
        return nil,...
    else
        return ...
    end
end

-- fast lambda creation
function L(src)
    return assert(loadstring(src:gsub("%s+%-%>%s+", " = ...; return ")))
end
