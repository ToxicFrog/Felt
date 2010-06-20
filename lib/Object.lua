local pairs,setmetatable,module,package,require,unpack,ipairs,table,type
    = pairs,setmetatable,module,package,require,unpack,ipairs,table,type

local print = print

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

__super = false
mixins = {}

function _M:__init(t)
    if t then
        if t.mixins then
            for i,v in ipairs(t.mixins) do
                table.insert(self.mixins, v)
            end
            t.mixins = self.mixins
        end
        for k,v in pairs(t) do
            self[k] = v
        end
    end
    
    for i,mix in ipairs(self.mixins) do
        require("mixins."..mix[1])(self, unpack(mix, 2))
    end
    
    return self
end

function _M:clone()
    return self:cloneto {}
end

function _M:instanceof(t)
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
    
    child.__super = self
    
    if self.__clone then
        self:__clone(child)
    end
    
    return child
end

function _M:__new(...)
    local obj = self:clone()
    obj._NAME = self._NAME
    
    obj:__init(...)

    return setmetatable(obj, obj)
end

function _M:subclass(name)
    module(name)
    self:cloneto(package.loaded[name])
    package.loaded[name]._NAME = name
    package.loaded[name].mixins = { unpack(self.mixins) }
    return setmetatable(package.loaded[name], { __call = package.loaded[name].__new, __class = name })
end

function _M:defaults(t)
    for k,v in pairs(t) do
        self[k] = v
    end
end

function _M:close(method)
    return function(...)
        return method(self, ...)
    end
end

function _M:mixin(...)
    table.insert(self.mixins, {...})
end

_M.__type = _M._NAME

