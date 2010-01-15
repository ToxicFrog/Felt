local Screen = require("Widget"):subclass "Screen"

Screen:defaults {
    x = 0, y = 0;
    w = math.huge, h = math.huge;
}

function Screen:__init(...)
    Widget.__init(self, ...)
    
    felt.log("screen create %s", tostring(self.menu.visible))
end

function Screen:draw() end

function Screen:click_left_before(x, y)
    if felt.held then
        self:event("drop", x, y, felt.held)
        return true
    end
    return false
end

function Screen:click_right_before()
    if felt.held then
        felt.held = nil
        -- FIXME broadcast release
        return true
    end
    return false
end

return Screen

