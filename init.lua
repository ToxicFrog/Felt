-- set up library search paths
package.path = "?.lua;lib/?.lua;?/init.lua;modules/?.lua;"..package.path
package.cpath = "lib/?.so;lib/?.dll;"..package.cpath

require "debugger"

-- initialize RNG
math.randomseed(os.time())

require "lfs"

-- auto-expanding stub tables - FIXME discard this when we no longer need stubs
function stubify(name)
	local mt = {}
	
	function mt:__call(...)
		print("STUB", name, ...)
		if ui.message then
			felt.log("STUB: %s", name)
		end
	end
	
	function mt:__index(key)
		self[key] = stubify(name.."."..key)
		return self[key]
	end
	
	return setmetatable({}, mt)
end

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
