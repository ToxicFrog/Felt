local super = class(..., "game.felt.Entity")

name = "(untitled field)"

function __init(self, t)
    super.__init(self, t)
    
    self.vis = self.vis or {}
end

function dropped_on(self, who, x, y, item)
    self:message("%s drops %s on %s.", tostring(who), tostring(item), tostring(self))
    item:moveto(self, x - item.w/2, y - item.h/2)
    item:raise()
    return true
end
