-- A die. Internally, it has many possible faces and selects one at random
-- each time it is frobbed.
class(..., "felt.Token")

w = false
h = false
facenames = {}

mixin "ui.actions" {
	{ "roll", "Roll", "click_left" };
}

mixin "mixins.serialize" ("faces")
mixin "ui.render.draw_png" ()

local _init = __init
function __init(self, t)
	self.face = t.faces[1]

	_init(self, t)
end
	
function server_roll(self, who)
    local roll = math.random(1, #self.faces)
	server:announce("%s rolls %s and gets %s",
	    tostring(who),
	    tostring(self),
	    tostring(self.facenames[roll] or roll))
    self:roll(roll)
end

function client_roll(self, face)
	self.face = self.faces[face]
end

do return end

local Die = require("felt.ImageToken"):subclass "felt.Die"

Die:persistent "images" "face" "names"

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
    
    if self.hidden then
        self.back = self.hidden
        self.backi = love.graphics.newImage(self.hidden)
    end
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
    
    if not self.back then
        self.backi = self.facei
    end
    
    felt.log("%s rolls %s and gets %s"
        , felt.config.name
        , tostring(self)
        , (self.names and self.names[n]) or self.images[n])
end

