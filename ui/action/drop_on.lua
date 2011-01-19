function click_left_before(self, x, y)
	if felt.me.held then
		return self:dispatchEvent("drop", x, y, felt.me.held)
	end
	return false
end
