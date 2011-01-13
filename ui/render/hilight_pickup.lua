-- augments :render with a version that hilights the item when picked up

local _render = render
function render(self, cr)
	if self.held_by then
		local colour = self.held_by.colour
		cr:push_group()
		cr:set_source_rgb(colour.red/65535, colour.green/65535, colour.blue/65535)
		cr:rectangle(self.x - 2, self.y - 2, self.w+4, self.h+4)
		cr:fill()
	end
	
	_render(self, cr)
	
	if self.held_by then
		cr:pop_group_to_source()
		cr:paint_with_alpha(0.5)
	end
end
