local ToggleButton = require("Button"):subclass "ToggleButton"

ToggleButton:defaults {
    set = false;
}

function ToggleButton:draw(scale, x, y, w, h)
    love.graphics.pushClip(x, y, w, h)
    love.graphics.setColour(0, 0, 0, 255)
    love.graphics.rectangle("fill", x, y, w, h)
    if self.focused then
        love.graphics.setColour(255, 0, 0, 255)
        love.graphics.rectangle("line", x, y, w, h)
    end
    if self.set then
        love.graphics.setColour(0, 255, 255, 255)
    else
        love.graphics.setColour(255, 255, 255, 255)
    end
    love.graphics.print(self.text, x, y+9)
    love.graphics.popClip()
end

function ToggleButton:call()
    self.set = not self.set
end

--return ToggleButton

