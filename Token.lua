local Token = require("Widget"):subclass "Token"

Token:defaults {
    name = "token";
    id = true;
    save = true;
    hidden = false;
}

Token:propagate "moveto" "raise" "lower"

function Token:setHidden(h)
    self.hidden = h
    for child in self:children() do
        child:setHidden(h)
    end
end

function Token:click_left()
    felt.pickup(self)
    return true
end

function Token:__tostring()
    if self.hidden then
        return self.hiddenname or "???"
    end
    return self.name or self._NAME or "(unnamed object)"
end

function Token:draw(scale, x, y, w, h)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.rectangle("fill", x, y, w, h)
end

function Token:drawHidden(scale, x, y, w, h)
    love.graphics.setColour(0, 0, 0, 255)
    love.graphics.rectangle("fill", x, y, w, h)
end

function Token:moveto(parent, ...)
    print("moveto", self.parent, parent)
    if parent and self.parent then
        felt.log("%s moves %s from %s to %s"
            , felt.config.name
            , tostring(self)
            , tostring(self.parent)
            , tostring(parent))
        self.parent:remove(self)
        parent:add(self, ...)
    elseif self.parent then
        felt.log("%s removes %s from %s"
            , felt.config.name
            , tostring(self)
            , tostring(self.parent))
        self.parent:remove(self)
    elseif parent then
        felt.log("%s places %s on %s"
            , felt.config.name
            , tostring(self)
            , tostring(parent))
        parent:add(self, ...)
    end
end

function Token:lower()
    if not self.parent then return end
    
    self.z = self.parent.children[#self.parent.children].z - 1
    self.parent:sort()
end

function Token:add(child, ...)
    Widget.add(self, child, ...)
    
    child:setHidden(self.hidden)
end

return Token

