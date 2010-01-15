local TextInput = require("Widget"):subclass "TextInput"

TextInput:defaults {
    text = "";
    w = 200;
    h = love.graphics.getFont():getHeight() + 4;
}

function TextInput:inBounds(x, y)
    return Widget.inBounds(self, x, y)
end

function TextInput:draw(scale, x, y, w, h)
    if self.focused then
        love.graphics.setColour(255, 0, 0, 255)
    else
        love.graphics.setColour(255, 255, 255, 255)
    end
    
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColour(0, 0, 0, 255)
    love.graphics.rectangle("fill", x+1, y+1, w-2, h-2)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.print(self.text, x+1, y + h - (h - love.graphics.getFont():getHeight())/2 - 4)
end

function TextInput:event(type, x, y, ...)
    if type:match("key_") then
        local char = ...
        if char >= ' ' and char <= '~' then
            self.text = self.text .. char
            return true
        end
    end
    
    return Widget.event(self, type, x, y, ...)
end

function TextInput:key_backspace()
    self.text = self.text:sub(1, -2)
    return true
end

return TextInput
