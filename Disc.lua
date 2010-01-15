local Disc = require("Token"):subclass "Disc"

function Disc:draw(scale, x, y)
    x = x + (self.w/2)*scale
    y = y + (self.h/2)*scale
    
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.circle("fill", x, y, (self.w/2)*scale)
end

function Disc:inBounds(...)
    print("disc-inbounds", ...)
    return Token.inBounds(self, ...)
end

