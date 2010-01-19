local Hand = require("Widget"):subclass("Hand")

Hand:defaults {
    x = 0;
    y = 0;
    z = math.huge;
}

function Hand:draw(scale, x, y, w, h)
    if #self.children > 0 then
        local child = self.children[1]
        child:render(scale, x - (child.w * scale)/2, y - (child.h * scale)/2, child.w * scale, child.h * scale, 128)
    end
    return true
end

function Hand:inBounds()
    return true
end

function Hand:render(scale, x, y, w, h)
    love.graphics.setColour(255, 255, 255, 128)
    Widget.render(self, scale, love.mouse.getX(), love.mouse.getY(), w, h)
    love.graphics.setColour(255, 255, 255, 255)
end

function Hand:click_left_before(x, y)
    if #self.children > 0 then
        felt.screen:event("drop", x, y, self.children[1])
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

function Hand:event(type, x, y, ...)
    local function callhandler(key, ...)
        local eventhandler = self[key]
        if eventhandler then
            local result = eventhandler(self, x, y, ...)
            assert(result or result == false, "event handler "..self._NAME..":"..key.." did not return a value")
            return result
        end
    end
    
    local r = callhandler(type.."_before", ...)
    if r then return r end

    return callhandler(type, ...)
end

