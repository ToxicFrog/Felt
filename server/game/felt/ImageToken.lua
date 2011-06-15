-- A subclass of token that renders using a PNG image

class(..., "felt.Token")

w = false
h = false

mixin "mixins.serialize" ("face", "back")
mixin "ui.render.draw_png" ()

do return end

function ImageToken:draw(scale, x, y, w, h)
    if self.theta < 90 then
    elseif self.theta < 180 then
        x = x + h
    elseif self.theta < 270 then
        x = x + w
        y = y + h
    elseif self.theta < 360 then
        y = y + w
    end
    
    love.graphics.setColour(255, 255, 255)
    love.graphics.draw(self.facei, x, y, math.rad(self.theta), (w/self.iw), (h/self.ih))
end

function ImageToken:drawHidden(scale, x, y, w, h)
    if self.theta < 90 then
    elseif self.theta < 180 then
        x = x + h
    elseif self.theta < 270 then
        x = x + w
        y = y + h
    elseif self.theta < 360 then
        y = y + w
    end

    love.graphics.setColour(255, 255, 255)
    love.graphics.draw(self.backi, x, y, math.rad(self.theta), (w/self.iw), (h/self.ih))
end

