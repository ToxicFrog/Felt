-- provides the default rendering/drawing infrastructure for Widgets

-- default render behaviour:
-- * set up scaling and position
-- * if concealed, call draw_concealed
-- * otherwise, call draw, then render all children back to front
function render(self, cr)
	cr:translate(self.x, self.y)
    cr:scale(self.scale, self.scale)

    if self.concealed then
    	self:draw_concealed(cr)
    	return
    end
    
    self:draw(cr)
    
    for child in self:childrenBTF() do
    	cr:save()
    	child:render(cr)
    	cr:restore()
    end
end

-- default draw behaviour is to draw a solid red box
-- if you start seeing these, someone forgot to implement :draw on their widgets!
function draw(self, cr)
	cr:set_source_rgba(1, 0, 0, 1)
	cr:rectangle(0, 0, self.w, self.h)
	cr:fill()
end

-- default draw_concealed behaviour is to forward to draw()
-- implicitly, this does not draw children (because render() will skip that step)
function draw_concealed(self, cr)
	return self:draw(cr)
end
