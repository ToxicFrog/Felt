local Button = require("Widget"):subclass "Button"

function Button:__init(...)
    Widget.__init(self, ...)
    
    self.h = 12
    self.w = love.graphics.getFont():getWidth(self.text) + 3
end

function Button:draw(scale, x, y, w, h)
    love.graphics.pushClip(x, y, w, h)
    love.graphics.setColour(0, 0, 0, 255)
    love.graphics.rectangle("fill", x, y, w, h)
    if self.focused then
        love.graphics.setColour(255, 0, 0, 255)
    else
        love.graphics.setColour(128, 128, 128, 255)
    end
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.print(self.text, x, y+9)
    love.graphics.popClip()
end

function Button:click_left()
    if type(self.call) == "function" then
        self:call()
    end
    return true
end

return Button

