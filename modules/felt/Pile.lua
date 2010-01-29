local Pile = require("felt.Token"):subclass "felt.Pile"

Pile:defaults {
    count = 1;
    type = "Token";
    ctor = {};
    mixins = {};
    top = nil;
}

Pile:persistent "count" "ctor" "type"
Pile:sync "setCount"

function Pile:__init(...)
    felt.Token.__init(self, ...)
    
    self.new = self.new or self.type
    
    local id = self.ctor.id
    self.ctor.id = false
    self.top = require(self.new)(self.ctor)
    self.w = self.top.w
    self.h = self.top.h
    self.ctor.id = id
    self.name = "Pile of "..tostring(self.top)
    
    self.label = require "Label" { text = tostring(self.count) }
    self:add(self.label, 0, 0)
end

function Pile:click_left()
    if love.keyboard.isDown "lshift" or love.keyboard.isDown "rshift" then
        return felt.Token.click_left(self)
    end
    
    if self.count > 0 then
        local obj = new(self.new)(self.ctor)
        for _,mixin in ipairs(self.mixins) do
            obj:mixin(unpack(mixin))
        end
        felt.pickup(obj)
        self:setCount(self.count - 1)
        self.label.text = tostring(self.count)
    end
    
    return true
end

function Pile:setCount(n)
    self.count = n
end

function Pile:drop(x, y, item)
    if not item:instanceof(self.type) then
        return false
    end
    
    self:setCount(self.count + 1)
    item:destroy()
    self.label:set(tostring(self.count))
    return true
end

function Pile:draw(scale, x, y, w, h)
    self.top:draw(scale, x, y, w, h)
end

function Pile:drawHidden(scale, x, y, w, h)
    self.top:drawHidden(scale, x, y, w, h)
end
