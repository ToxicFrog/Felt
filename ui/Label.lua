local Label = require("Widget"):subclass "Label"
function Label:__init(...)
    Widget.__init(self, ...)
    
    self.h = love.graphics.getFont():getHeight()
    self.w = love.graphics.getFont():getWidth(self.text) + 2
end

function Label:draw(scale, x, y, w, h)
    love.graphics.pushClip(x, y, w, h)
    
    love.graphics.setColour(0, 0, 0, 255)
    love.graphics.rectangle("fill", x, y, w, h)
    
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.print(self.text, x-1, y+love.graphics.getFont():getHeight() - 3)
    
    love.graphics.popClip()
end

function Label:set(text)
    self.text = text;
    self.w = love.graphics.getFont():getWidth(self.text) + 2
end

