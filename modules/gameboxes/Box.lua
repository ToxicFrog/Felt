class(..., "felt.ImageToken")

mixin "serialize" ("module")

function click_left(self)
	require(self.module)
	self:moveto(nil)
	return true
end
