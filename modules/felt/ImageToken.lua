class(..., "felt.Token")

w = false
h = false

mixin "mixins.serialize" ("face", "back")

--mixin "draw" ("image", "face")
--mixin "drawHidden" ("image", "back")

local surface

local _init = __init
function __init(self, ...)
    _init(self, ...)
    
    self.back_surface = cairo.image_surface_create_from_png(self.back or self.face)
    self.face_surface = cairo.image_surface_create_from_png(self.face)

    self.iw = cairo.image_surface_get_width(self.face_surface)
    self.ih = cairo.image_surface_get_height(self.face_surface)
    self.w = self.w or self.iw
    self.h = self.h or self.ih
end

function draw(self, cr)
	cr:set_source_surface(self.face_surface, 0, 0)
	cr:rectangle(0, 0, self.w, self.h)
	cr:fill()
end

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

