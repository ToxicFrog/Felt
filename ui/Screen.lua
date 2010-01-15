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

return Screen

