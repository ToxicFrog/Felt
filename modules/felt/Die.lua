local Die = require("felt.ImageToken"):subclass "felt.Die"

Die:persistent "images" "face" "names"
Die:sync "setFace"

function Die:__init(t)
    t.face = t[1] or t.images[1]
    felt.ImageToken.__init(self, t)
    self.images = t.images or {unpack(t)}
    
    for i,image in ipairs(self.images) do
        self[i] = love.graphics.newImage(image)
    end
    
    self.w = self[1]:getWidth()
    self.h = self[1]:getHeight()
    
    self.face = 1
    self.facei = self[self.face]
end

function Die:click_left()
    if love.keyboard.isDown "lshift" or love.keyboard.isDown "rshift" then
        return felt.ImageToken.click_left(self)
    end
    
    self:roll()
    return true
end

function Die:click_middle()
    self:roll()
    return true
end

function Die:roll()
    self:setFace(math.random(1, #self))
end

function Die:setFace(n)
    self.face = n
    self.facei = self[self.face]
    felt.log("%s rolls %s and gets %s"
        , felt.config.name
        , tostring(self)
        , (self.names and self.names[n]) or self.images[n])
end

