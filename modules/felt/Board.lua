class(..., "felt.ImageToken")

mixin "serialize" ("grid")

function drop(self, x, y, item)
	if self.grid then
		x = math.floor((x - self.grid.x)/self.grid.w)
			* self.grid.w
			+ self.grid.x
			+ math.floor(self.grid.w/2)
		y = math.floor((y - self.grid.y)/self.grid.h)
			* self.grid.h
			+ self.grid.y
			+ math.floor(self.grid.h/2)
	end

	felt.me:drop(self, x, y)
    
    return true
end
