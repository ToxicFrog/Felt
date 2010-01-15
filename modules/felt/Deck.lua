local Deck = require("felt.Token"):subclass "felt.Deck"

Deck:defaults {
    name = "Deck";
}

function Deck:__init(t)
    felt.Token.__init(self, t)
    
    for i,v in ipairs(t) do
        v.z = i
        self:add(v)
    end
    
    if #self.children > 0 then
        self.w = self.children[1].w
        self.h = self.children[1].h
    end
end

function Deck:click_left_before()
    if love.keyboard.isDown "lshift" or love.keyboard.isDown "rshift" then
        return felt.Token.click_left(self)
    end
    
    if #self.children == 0 then return true end
    
    if love.keyboard.isDown "lctrl" or love.keyboard.isDown "rctrl" then
        felt.pickup(self:pull(#self.children))
    else
        felt.pickup(self:pull(1))
    end
    
    return true
end

function Deck:pull(n)
    print("deck-pull", n)
    local item = self.children[n]
    item:moveto(nil)
    return item
end

function Deck:drop(x, y, item)
    item:moveto(self)
    if love.keyboard.isDown "lctrl" or love.keyboard.isDown "rctrl" then
        item:lower()
    else
        item:raise()
    end
    
    return true
end

function Deck:draw(scale, x, y, w, h)
    if #self.children > 0 then
        self.children[1]:draw(scale, x, y, w, h)
    else
        love.graphics.setColour(128, 128, 128, 255)
        love.graphics.rectangle("line", x, y, w, h)
    end
    return true
end

function Deck:drawHidden(scale, x, y, w, h)
    if #self.children > 0 then
        self.children[1]:drawHidden(scale, x, y, w, h)
    else
        love.graphics.setColour(128, 128, 128, 255)
        love.graphics.rectangle("line", x, y, w, h)
    end
    return true
end

