-- Tokens that can draw front and back faces from a PNG image
-- back face is optional and defaults to front face

local _init = __init
function __init(self, ...)
	_init(self, ...)
	
	assert(self.face, "No face for PNG surface")
	self.surface = cairo.image_surface_create_from_png(self.face)
    self.back_surface = cairo.image_surface_create_from_png(self.back or self.face)
	
	self.w = self.w or cairo.image_surface_get_width(self.surface)
	self.h = self.h or cairo.image_surface_get_height(self.surface)
end

function draw(self, cr)
	cr:set_source_surface(self.surface, 0, 0)
	cr:rectangle(0, 0, self.w, self.h)
	cr:fill()
end

function drawBack(self, cr)
	cr:set_source_surface(self.back_surface, 0, 0)
	cr:rectangle(0, 0, self.w, self.h)
	cr:fill()
end
