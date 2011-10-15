-- common.Object
-- this is the base class from which all other classes are derived
-- It implements a few utility methods like Object:isInstanceOf(foo), but
-- most of this is the basic pipe laying needed to let you create
-- new classes and create instances of them

-- we need to localize everything we plan on using, since this
-- library uses module()
local pairs,setmetatable,module,package,require,unpack,ipairs,table,type,tostring,_G,setfenv,loadfile,assert
= pairs,setmetatable,module,package,require,unpack,ipairs,table,type,tostring,_G,setfenv,loadfile,assert
local print = print


-- the global type() function gets overriden, to support the __type metamethod
-- if __type is a function, it is called; otherwise it is the type
do
    local _type = type
    function type(obj)
        local mt = getmetatable(obj)
        if not mt or not mt.__type then return _type(obj) end
        
        if type(mt.__type) == "function" then
            return mt.__type(obj)
        end
        return mt.__type
    end
end

module(...)

-- the type of an Object is "common.Object"
_M.__type = _M._NAME

function _M:__init(t)
    if t then
        for k,v in pairs(t) do
            self[k] = v
        end
    end
    
    return self
end

function _M:clone()
    return self:cloneto {}
end

function _M:isInstanceOf(t)
    if type(t) == "string" then
        t = require(t)
    end
    
    if type(self) == t then
        return true
    elseif self._NAME == t then
        return true
    end
    
    while self.__super do
        if self.__super._NAME == t then return true end
        self = self.__super
    end
    
    return false
end

function _M:cloneto(child)
    for k,v in pairs(self) do
        child[k] = v
    end
        
    if self.__clone then
        self:__clone(child)
    end
    
    return child
end

function _M:__new(...)
    local obj = self:clone()
    obj._NAME = self._NAME
    obj._ID   = tostring(obj):gsub("^table: ", "")
    
    setmetatable(obj, obj)
    
    if self._TRACE then
		print("NEW", obj._NAME)
		table.print((...), "  ")
		print("------")
	end
    
    obj:__init(...)

    return obj
end

function _M:__tostring()
	return self._NAME.."("..self._ID..")"
end

function _M:close(method)
	method = type(method) == "string" and self[method] or method
    return function(...)
        return method(self, ...)
    end
end

function _G.class(name, superclass)
	superclass = superclass or _M
	
	if type(superclass) == "string" then
		superclass = require(superclass)
	end
	
	module(name)
	local class = package.loaded[name]
	superclass:cloneto(class)
	class._NAME = name
	class._CLASS = class
	class._SUPER = superclass
	setmetatable(class, { __call = class.__new })
	
	local env = {}
	local mt = {}
	function mt:__index(key)
		return class[key] or _G[key]
	end
	function mt:__newindex(key, value)
		if type(value) == "function" then
			setfenv(value, _G)
		end
		class[key] = value
	end
	
	setmetatable(env, mt)
	setfenv(2, env)
	
	function class.mixin(name)
		local f = assert(loadfile(name:gsub('%.', '/')..".lua"))
		setfenv(f, env)
		return function(...)
			return f(...)
		end
	end

	return superclass
end
	
-- instantiate something using 'new "type" {ctor}'
function _G.new(name)
    local class = require(name)
    assert(type(class) == "table" and class._NAME == name, "Malformed or missing class definition for '%s'" % name)
    return function(...)
        return class(...)
    end
end
