local Menu = require("Widget"):subclass "Menu"

local MenuTitle = require("Widget"):subclass "MenuTitle"
do
    function MenuTitle:__init(...)
        Widget.__init(self, ...)
        
        self.h = 10
        self.w = love.graphics.getFont():getWidth(self.text) + 2
    end
    
    function MenuTitle:draw(scale, x, y, w, h)
        love.graphics.pushClip(x, y, w, h)
        love.graphics.setColour(0, 0, 0, 255)
        love.graphics.draw(self.text, x+1, y+9)
        love.graphics.popClip()
    end
end

local MenuEntry = require("Widget"):subclass "MenuEntry"
do
    function MenuEntry:__init(...)
        Widget.__init(self, ...)
        
        self.h = 10
        self.w = love.graphics.getFont():getWidth(self.text) + 2
    end
    
    function MenuEntry:draw(scale, x, y, w, h)
        love.graphics.pushClip(x, y, w, h)
        love.graphics.setColour(0, 0, 0, 255)
        love.graphics.rectangle(love.draw_fill, x, y, w, h)
        love.graphics.setColour(255, 255, 255, 255)
        love.graphics.draw(self.text, x+1, y+9)
        love.graphics.popClip()
    end
    
    function MenuEntry:click_left()
        print("menu entry clicked", self.text)
        if self.call then
            print("", "calling")
            self.call()
            self.parent.parent:remove(self.parent)
        end
    end
end

local MenuSpacer = require("Widget"):subclass "MenuSpacer"
do
    function MenuSpacer:__init(...)
        Widget.__init(self, ...)
        self.h = 1
    end
    
    function MenuSpacer:draw() end
end

function Menu:__init(t)
    Widget.__init(self, t)
    
    self.w = 0
    self.h = 12
    
    self:add(MenuTitle { x=1, y=1, text = self.title })

    for i=1,#t,2 do
        local entry
        if t[i] == "--" then
            entry = self:add(MenuSpacer { x=1, y = self.h })
        else
            entry = self:add(MenuEntry {
                text = t[i];
                call = t[i+1];
                x = 1;
                y = self.h;
            })
        end
        self.w = math.max(self.w, entry.w)
        self.h = self.h + entry.h + 1
    end

    for child in self:children() do
        child.w = self.w
    end
    
    self.w = self.w + 2
end

function Menu:draw(scale, x, y, w, h)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.rectangle(love.draw_fill, x, y, w, h)
end

function Menu:move(x, y)
end

function Menu:raise()
    Widget.raise(self)
end

