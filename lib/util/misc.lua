-- miscellaneous helper functions

-- an xpcall that permits varargs
function va_xpcall(f, e, ...)
    local argc = select('#', ...)
    local argv = {...}
    
    return xpcall(function() return f(unpack(argv,1,argc)) end, e)
end
        
-- fast lambda creation
function f(src)
    local f,e = loadstring(src:gsub("%s+%-%>%s+", " = ...; return "))
    if not f then
        error(tostring(e).."\n"..src:gsub("%s+%-%>%s+", " = ...; return "))
    end
    return f
end

-- turn a function that raises hard errors into one that returns nil,err
function tosofte(f)
    return function(...)
        return (function (result, ...)
            if not result then
                return nil,...
            end
            return ...
        end)(pcall(f, ...))
    end
end
   
-- the converse of tosofte
function toharde(f)
    return function(...)
        return assert(f(...))
    end
end

-- a 'safe' require that doesn't raise errors on failure
srequire = tosofte(require)
