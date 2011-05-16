-- Tokens that can draw front and back faces from a PNG image
-- back face is optional and defaults to front face

local surfaces = setmetatable({}, { __index = function(self, name)
	self[name] = assert(cairo.image_surface_create_from_png(name))
	return self[name]
end})

local _init = __init
function __init(self, ...)
	_init(self, ...)
	
	assert(self.face, "No face for PNG surface")
	self.back = self.back or self.face
	
	self.w = self.w or cairo.image_surface_get_width(surfaces[self.face])
	self.h = self.h or cairo.image_surface_get_height(surfaces[self.face])
end

function draw(self, cr)
	cr:set_source_surface(surfaces[self.face], 0, 0)
	cr:rectangle(0, 0, self.w, self.h)
	cr:fill()
end

function draw_concealed(self, cr)
	cr:set_source_surface(surfaces[self.back], 0, 0)
	cr:rectangle(0, 0, self.w, self.h)
	cr:fill()
end
