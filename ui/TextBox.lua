local TextBox = require("Widget"):subclass "TextBox"

TextBox:defaults {
    text = "";
}

function TextBox:draw(scale, x, y, w, h)
    love.graphics.pushClip(x, y, w, h)
    
    love.graphics.setColour(0, 0, 0, 255)
    love.graphics.rectangle("fill", x, y, w, h)
    
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.printf(self.text, x+1, y+love.graphics.getFont():getHeight(), w - 2)
    
    love.graphics.popClip()
end

function TextBox:set(text)
    self.text = text;
end
