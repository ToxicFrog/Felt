local Hand = require("Widget"):subclass("Hand")

Hand:defaults {
    x = 0;
    y = 0;
    z = math.huge;
}

function Hand:draw(scale, x, y, w, h)
    if #self.children > 0 then
        local child = self.children[1]
        child:render(scale, x - child.w/2, y - child.h/2, child.w, child.h)
    end
    return true
end

function Hand:inBounds()
    return true
end

function Hand:render(scale, x, y, w, h)
    return Widget.render(self, scale, love.mouse.getX(), love.mouse.getY(), w, h)
end

function Hand:click_left_before(x, y)
    if #self.children > 0 then
        felt.screen:event("drop", x, y, table.remove(self.children))
        return true
    end
    
    return false
end

function Hand:click_right_before(x, y)
    if #self.children > 0 then
        local child = table.remove(self.children, 1)
        child:moveto(child.oldparent)
        child.oldparent = nil
        return true
    end
    
    return false
end

function Hand:pickup(item)
    item.oldparent = item.parent
    item:moveto(nil)
    self:add(item)
end
