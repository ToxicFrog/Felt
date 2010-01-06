local TextInput = require("Widget"):subclass "TextInput"

TextInput:defaults {
    text = "";
    w = 200;
    h = love.graphics.getFont():getHeight() + 4;
}

function TextInput:draw(scale, x, y, w, h)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColour(0, 0, 0, 255)
    love.graphics.rectangle("fill", x+1, y+1, w-1, h-1)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.print(self.text, x + 2, y + h - 2)
end

function TextInput:__index(key)
    if key:match("^key_") and not key:match("_before$") then
        local keycode = key:match("^key_(.*)")
        
        TextInput[keycode] = function()
            self.text = self.text .. keycode
            return true
        end
        self[keycode] = TextInput[keycode]
        return self[keycode]
    end
    
    return nil
end

return TextInput
