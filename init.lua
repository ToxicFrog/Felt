-- set up library search paths
package.path = "?.lua;lib/?.lua;?/init.lua;modules/?.lua;"..package.path
--package.cpath = "lib/?.so;lib/?.dll;"..package.cpath

require "debugger"

-- initialize RNG
math.randomseed(os.time())

require "lfs"

-- an xpcall that permits varargs
function va_xpcall(f, e, ...)
    local argc = select('#', ...)
    local argv = {...}
    
    return xpcall(function() return f(unpack(argv,1,argc)) end, e)
end

-- an unpack that respects t.n rather than using #
local _unpack = unpack
function unpack(t, first, last)
	first = first or 1
	last  = last or t.n or #t
	return _unpack(t, first, last)
end

-- converse of unpack
function table.pack(...)
    return { n = select('#', ...), ... }
end

-- instantiate something using 'new "type" {ctor}'
function new(type)
    return function(...)
        return require(type)(...)
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

-- Class(Object, SubClass)
function Class(super, name)
	if not name then
		name,super = super,Object
	end
	
	if type(super) == "string" then
		super = require(super)
	end
	
	return super:subclass(name)
end

