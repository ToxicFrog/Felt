local Screen = require("Widget"):subclass "Screen"

function Screen:__init(...)
    Widget.__init(self, ...)
    
    self.menu = require "Menu" {
        title = "Felt";
        "Create Window", self:close(self.create);
        visible = false;
    }
end

function Screen:draw()
    return
end

function Screen:create()
    print("create")
    felt.addWindow { x = self.menu.x, y = self.menu.y }
end

function Screen:click_right(x, y)
    self:add(self.menu)
    self.menu:raise()
    self.menu.x = x
    self.menu.y = y
end

return Screen

