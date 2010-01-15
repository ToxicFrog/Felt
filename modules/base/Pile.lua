local Pile = require("Token"):subclass "base.Pile"

Pile:defaults {
    count = 1;
    type = "Token";
    ctor = {};
    top = nil;
}

Pile:persistent "count" "ctor" "type"
Pile:broadcast "setCount"

function Pile:__init(...)
    Token.__init(self, ...)
    
    self.top = require(self.type)(self.ctor)
    self.w = self.top.w
    self.h = self.top.h
    
    self.label = require "Label" { text = tostring(self.count) }
    self:add(self.label, 0, 0)
end

function Pile:click_left()
    if love.keyboard.isDown "lshift" or love.keyboard.isDown "rshift" then
        return Token.click_left(self)
    end
    
    if self.count > 0 then
        felt.pickup(new(self.type)(self.ctor))
        self:setCount(self.count - 1)
        self.label.text = tostring(self.count)
    end
    
    return true
end

function Pile:setCount(n)
    self.count = n
end

function Pile:click_middle()
    felt.pickup(self)
    return true
end

function Pile:drop(x, y, item)
    if item._NAME ~= self.type then
        return false
    end
    
    self:setCount(self.count + 1)
    item:destroy()    self.label.text = tostring(self.count)
    return true
end

function Pile:draw(scale, x, y, w, h)
    self.top:draw(scale, x, y, w, h)
end

function Pile:drawHidden(scale, x, y, w, h)
    self.top:drawHidden(scale, x, y, w, h)
end
