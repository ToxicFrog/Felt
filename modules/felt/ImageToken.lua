local ImageToken = require("felt.Token"):subclass "felt.ImageToken"

ImageToken:defaults { w=false, h=false }
ImageToken:persistent "file"

function ImageToken:__init(...)
    felt.Token.__init(self, ...)
    
    self.back = love.graphics.newImage(self.back or self.face)
    self.face = love.graphics.newImage(self.face)

    self.w = self.w or self.face:getWidth()
    self.h = self.h or self.face:getHeight()
end

function ImageToken:draw(scale, x, y, w, h)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.draw(self.face, x, y, 0, (w/self.w)*scale, (h/self.h)*scale)
end

function ImageToken:drawHidden(scale, x, y, w, h)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.draw(self.back, x, y, 0, (w/self.w)*scale, (h/self.h)*scale)
end

return ImageToken
