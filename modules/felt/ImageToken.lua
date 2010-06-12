local ImageToken = require("felt.Token"):subclass "felt.ImageToken"

ImageToken:defaults { w=false, h=false, theta=0 }
ImageToken:persistent "face" "back"

function ImageToken:__init(...)
    felt.Token.__init(self, ...)
    
    self.backi = love.graphics.newImage(self.back or self.face)
    self.facei = love.graphics.newImage(self.face)

    self.iw = self.facei:getWidth()
    self.ih = self.facei:getHeight()
    self.w = self.w or self.iw
    self.h = self.h or self.ih
end

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

