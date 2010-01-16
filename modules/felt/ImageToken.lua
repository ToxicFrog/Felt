local ImageToken = require("felt.Token"):subclass "felt.ImageToken"

ImageToken:defaults { w=false, h=false }
ImageToken:persistent "face" "back"

function ImageToken:__init(...)
    felt.Token.__init(self, ...)
    
    self.backi = love.graphics.newImage(self.back or self.face)
    self.facei = love.graphics.newImage(self.face)

    self.w = self.w or self.facei:getWidth()
    self.h = self.h or self.facei:getHeight()
end

function ImageToken:draw(scale, x, y, w, h)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.draw(self.facei, x, y, 0, (w/self.w)*scale, (h/self.h)*scale)
end

function ImageToken:drawHidden(scale, x, y, w, h)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.draw(self.backi, x, y, 0, (w/self.w)*scale, (h/self.h)*scale)
end

return ImageToken
