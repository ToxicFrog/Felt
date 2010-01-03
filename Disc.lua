local Disc = require("Widget"):subclass "Disc"

Disc:defaults {
    z = 0;
}

function Disc:draw(scale, x, y)
    x = x + (self.w/2)*scale
    y = y + (self.h/2)*scale
    
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.circle(love.draw_fill, x, y, (self.w/2)*scale)
end
