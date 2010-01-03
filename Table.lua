local Table = require("Widget"):subclass "Table"

function Table:__init(...)
    Widget.__init(self, ...)
    
    self.items = {}
end

Table:defaults {
    -- scale of the contents of this table
    scale = 1.0;
        
    -- location of the origin of the contents relative to upper left, px
    ox = 0, oy = 0;

    -- width and height in grid units
    gw = 100, gh = 100;
}

-- convert grid coordinates to screen coordinates
function Table:toScreen(x, y)
    local _x,_y = self:trueXY()
    return x * self.scale + self.ox + _x
        ,  y * self.scale + self.oy + _y
end

-- convert screen coordinates to grid coordinates
function Table:toGrid(x, y)
    -- turn screen coordinates into viewport coordinates
    return (x - self.x - self.ox)/self.scale
        ,  (y - self.y - self.oy)/self.scale
end

function Table:pan(dx, dy)
    self.ox = self.ox + dx
    self.oy = self.oy + dy
end

-- set zoom factor
function Table:zoom(scale)
    self.scale = scale
end

function Table:clear()
    self.items = {}
end

function Table:reset()
    self.ox,self.oy = 0,0
    self.scale = 1.0
end

function Table:add(item)
    table.insert(self.items, item)
    Widget.add(self, item)
end

function Table:remove(item)
    for i,v in ipairs(self.items) do
        if v == item then
            table.remove(self.items, i)
            break
        end
    end
    Widget.remove(self, item)
end

function Table:grab()
    return self
end

function Table:drag_right(dx, dy)
    self:pan(dx, dy)
end

function Table:isVisible(item)
    local x,y = self:toScreen(item.x, item.y)
    local _x,_y = self:trueXY()
    local rx,by = x + self.scale * item.w, y + self.scale * item.h
    
    if x > _x + self.w
    or y > _y + self.h
    or rx < _x
    or by < _y
    then
        return false
    end
    return true
end

function Table:draw(scale, x, y)
    if self.parent.folded then
        return true
    end
    
    table.sort(self.items, L 'lhs,rhs -> lhs.z < rhs.z')
    
    love.graphics.pushClip(x, y, self.w, self.h)
    love.graphics.setColour(0, 64, 0, 255)
    love.graphics.rectangle(love.draw_fill, x, y, self.w, self.h)
    
    for _,item in ipairs(self.items) do
        if self:isVisible(item) then
            item:render(self.scale, self:toScreen(item.x, item.y))
        end
    end
    
    love.graphics.popClip()
    
    return true
end

return Table
