local pairs,setmetatable,module,package = pairs,setmetatable,module,package

local print = print

module(...)

__index = _M
__super = _M

function _M:__init(t)
    if t then
        for k,v in pairs(t) do
            self[k] = v
        end
    end
    return
end

function _M:clone()
    return self:cloneto {}
end

function _M:cloneto(child)
    for k,v in pairs(self) do
        if not k:match("^_[A-Z]+") then
            child[k] = v
        end
    end
    
    child.__super = self
    
    if self.__clone then
        self:__clone(child)
    end
    
    return child
end

function _M:new(...)
    local obj = self:clone()
    obj._NAME = self._NAME
    obj:__init(...)

    return setmetatable(obj, obj)
end

function _M:subclass(name)
    module(name)
    self:cloneto(package.loaded[name])
    package.loaded[name].__class = name
    return setmetatable(package.loaded[name], { __call = package.loaded[name].new, __class = name })
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

