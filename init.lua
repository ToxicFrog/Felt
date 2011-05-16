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

-- tprint - recursively display the contents of a table
-- does not generate something the terp can read; use table.dump() for that
function table.print(T, prefix)
        assert(T, "bad argument to table.print")
        local done = {}
        local function tprint_r(T, prefix)
                for k,v in pairs(T) do
                        print(prefix..tostring(k),'=',tostring(v))
                        if type(v) == 'table' then
                                if not done[v] then
                                        done[v] = true
                                        tprint_r(v, prefix.."  ")
                                end
                        end
                end
        end
        done[T] = true
        tprint_r(T, prefix or "")
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

-- permit 'fmt % foo' and 'fmt % { foo, bar }'
getmetatable("").__mod = function(fmt, args)
	if type(args) == "table" then
		return fmt:format(unpack(args))
	else
		return fmt:format(args)
	end
end
