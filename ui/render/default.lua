-- provides the default rendering/drawing infrastructure for Widgets

-- default render behaviour:
--  skip if invisible
--  otherwise, call "draw"
--  then, draw all children
function render(self, cr)
    if not self.visible then return end
    
	cr:translate(self.x, self.y)
    cr:scale(self.scale, self.scale)
    
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
