local Table = require("Widget"):subclass "Table"

local DrawOverlay = require("Widget"):subclass "DrawOverlay"
do
    DrawOverlay:defaults {
        visible = false;
    }
    
    function DrawOverlay:__init()
        self.lines = {}
    end
    
    function DrawOverlay:key_d()
        self.visible = not self.visible
    end
    
    function DrawOverlay:key_e()
        self.lines = {}
    end
    
    function DrawOverlay:draw(scale, x, y, w, h)
        
    end
end

Table:defaults {
    -- scale of the contents of this table
    scale = 1.0;
        
    -- location of the origin of the contents relative to upper left, px
    ox = 0, oy = 0;
}

Table.menu = {
    title = "Table";
    "Create Disc", function(self, menu) self:add(require "Disc" {}, self:toGrid(menu.x, menu.y)) end;
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
    return (x - self.ox)/self.scale
        ,  (y - self.oy)/self.scale
end

function Table:childInBounds(child, x, y)
    x,y = self:toGrid(x,y)
    return child:inBounds(x - child.x, y - child.y)
end
    
function Table:pan(ox, oy)
    self.ox = ox
    self.oy = oy
end

-- set zoom factor
function Table:zoom(scale)
    self.scale = scale
end

function Table:clear()
    self.items = {}
end

function Table:grab()
    return self
end

function Table:drag_right(dx, dy)
    self:pan(self.ox + dx, self.oy + dy)
    return true
end
Table.drag_middle = Table.drag_right

function Table:click_wheeldown()
    self:zoom(self.scale * 0.9)
    return true
end

function Table:click_wheelup()
    self:zoom(self.scale * 1.1)
    return true
end

function Table:drop(x, y, item)
    print("drop", item, x, y)
    x,y = self:toGrid(x,y)
    item.parent:remove(item)
    self:add(item, x - item.w/2, y - item.h/2)
    item:raise()
    felt.held = nil
    
    return true
end

function Table:key_c()
    self:pan(0,0)
    return true
end

function Table:key_z()
    self:zoom(1.0)
    return true
end

function Table:draw(scale, x, y)
    love.graphics.pushClip(x, y, self.w, self.h)
    love.graphics.setColour(0, 64, 0, 255)
    love.graphics.rectangle("fill", x, y, self.w, self.h)
    
    for i=#self._children,1,-1 do
        local child = self._children[i]
        local x,y = self:toScreen(child.x, child.y)
        child:render(self.scale, x, y, child.w, child.h)
    end
    
    love.graphics.popClip()
    
    return true
end

return Table
