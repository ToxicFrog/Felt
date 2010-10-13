local super = class(..., "felt.Widget")

name = "token"
id = true

function click_left(self)
	felt.me:pickup(self)
	return true
end

-- move the token to a new parent
-- moveto(nil) can be used to remove a token from the object heirarchy entirely
-- without deleting it
function moveto(self, parent, x, y)
	if self.parent then
		self.parent:remove(self)
	end
	if parent then
		parent:add(self, x, y)
	end
end

function render(self, cr)
	if self.held_by then
		local colour = self.held_by.colour
		cr:push_group()
		cr:set_source_rgb(0, 1, 1)
		cr:rectangle(self.x - 2, self.y - 2, self.w+4, self.h+4)
		cr:fill()
	end
	
	super.render(self, cr)
	
	if self.held_by then
		cr:pop_group_to_source()
		cr:paint_with_alpha(0.5)
	end
end

do return end

Token:persistent "name" "hiddenname" "theta"

function Token:rotate(theta)
    self.theta = theta % 360
end

function Token:inBounds(x, y)
    if self.theta >= 90 and self.theta < 180
    or self.theta >= 240 and self.theta < 360
    then
        x,y = y,x
    end
    return Widget.inBounds(self, x, y)
end

function Token:setHidden(h)
    self.hidden = h
    for child in self:children() do
        assert(child ~= self, tostring(self).." "..tostring(child))
        child:setHidden(h)
    end
end

function Token:click_left()
    felt.pickup(self)
    return true
end

function Token:__tostring()
    if self.hidden then
        return self.hiddenname or "???" 
    end
    return self.name or self._NAME or "(unnamed object)"
end

function Token:draw(scale, x, y, w, h)
    love.graphics.setColour(255, 255, 255)
    love.graphics.rectangle("fill", x, y, w, h)
end

function Token:drawHidden(scale, x, y, w, h)
    love.graphics.setColour(0, 0, 0)
    love.graphics.rectangle("fill", x, y, w, h)
end

function Token:add(child, ...)
    assert(child ~= self, tostring(self))
    Widget.add(self, child, ...)
    
    child:setHidden(self.hidden)
end

function Token:enter()
    if self.info then
        felt.info:set(tostring(self).."\n\n"..tostring(self.info))
    else
        felt.info:set(tostring(self))
    end
    return true
end

return Token

