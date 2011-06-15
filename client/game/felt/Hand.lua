local Hand = require("felt.Deck"):subclass "felt.Hand"

Hand:defaults {
    w = 64;
    h = 64;
}

function Hand:sort()
    felt.Token.sort(self)
    local x = 0
    local children = self.children
    for i=#children,1,-1 do
        children[i].x = x
        children[i].y = 0

        self.w = x + children[i].w
        self.h = math.max(self.h, children[i].h)
        x = x + children[i].w/2
    end
end

function Hand:draw(scale, x, y, w, h)
    self:sort()
    love.graphics.setColour(128, 128, 128, 255)
    love.graphics.rectangle("line", x, y, w, h)
end

function Hand:drawHidden(scale, x, y, w, h)
    self:sort()
    love.graphics.setColour(128, 128, 128, 255)
    love.graphics.rectangle("line", x, y, w, h)
end

function Hand:click_left_before(x, y)
    if love.keyboard.isDown "lshift" or love.keyboard.isDown "rshift" then
        return felt.Token.click_left(self)
    end
    
    return false
end


