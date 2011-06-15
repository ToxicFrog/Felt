class(..., "felt.ImageToken")

mixin "mixins.serialize" ("module")

function click_left(self)
	self:open_box()
	return true
end

function server_open_box(self)
	if not self.open then
		require(self.module)
		self.open = true
		self.parent:remove(self)
	end
end
