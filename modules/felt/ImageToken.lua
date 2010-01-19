local ImageToken = require("felt.Token"):subclass "felt.ImageToken"

ImageToken:defaults { w=false, h=false, theta=0 }
ImageToken:persistent "face" "back"

function ImageToken:__init(...)
    felt.Token.__init(self, ...)
    
    print("ImageToken", self.back, self.face)
    self.backi = love.graphics.newImage(self.back or self.face)
    self.facei = love.graphics.newImage(self.face)

    self.w = self.w or self.facei:getWidth()
    self.h = self.h or self.facei:getHeight()
    self.iw = self.facei:getWidth()
    self.ih = self.facei:getHeight()
end

function ImageToken:draw(scale, x, y, w, h)
    local _x,_y = x,y
    local W = w/2
    local H = h/2
    local Cx = x+W
    local Cy = y+H
    x = Cx - W * math.cos(self.theta) + H * math.sin(self.theta)
    y = Cy - W * math.sin(self.theta) - H * math.cos(self.theta)
    love.graphics.setColour(255, 255, 255)
    love.graphics.draw(self.facei, x, y, self.theta, (w/self.iw), (h/self.ih))
end

function ImageToken:drawHidden(scale, x, y, w, h)
    local W = w/2
    local H = h/2
    local Cx = x+W
    local Cy = y+H
    x = Cx - W * math.cos(self.theta) + H * math.sin(self.theta)
    y = Cy - W * math.sin(self.theta) - H * math.cos(self.theta)
    love.graphics.setColour(255, 255, 255)
    love.graphics.draw(self.backi, x, y, self.theta, (w/self.iw), (h/self.ih))
end

