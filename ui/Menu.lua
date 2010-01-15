local Menu = require("Widget"):subclass "Menu"

Menu:defaults {
    visible = false
}

local MenuTitle = require("Label"):subclass "MenuTitle"
do
    function MenuTitle:__init(...)
        Widget.__init(self, ...)
        
        self.h = 10
        self.w = love.graphics.getFont():getWidth(self.text) + 2
    end
    
    function MenuTitle:draw(scale, x, y, w, h)
        love.graphics.pushClip(x, y, w, h)
        love.graphics.setColour(0, 0, 0, 255)
        love.graphics.print(self.text, x+1, y+9)
        love.graphics.popClip()
    end
end

local MenuEntry = require("Button"):subclass "MenuEntry"
do
    function MenuEntry:click_left()
        if type(self.call) == "function" then
            self.call(self.parent.context, self.parent)
            self.focused = false
            print(self, self.parent)
            self.parent:hide()
        end
        return true
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

    local i = 1;
    while t[i] do
        local entry
        if t[i] == "--" then
            entry = self:add(MenuSpacer { x=1, y = self.h })
            i = i + 1
        else
            entry = self:add(MenuEntry {
                text = t[i];
                call = t[i+1];
                x = 1;
                y = self.h;
            })
            i = i + 2
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
    love.graphics.rectangle("fill", x, y, w, h)
end

function Menu:move(x, y)
end

function Menu:inBounds(x, y)
    return self.visible
end

function Menu:click_right_before()
    self:hide()
    return true
end

function Menu:click_left(x, y)
    if x < 0 or x > self.w
    or y < 0 or y > self.w
    then
        self:hide()
    end
    return true
end

function Menu:show(x, y)
    self.x = x or self.x
    self.y = y or self.y
    
    if not self.visible then
        felt.log("display menu")
        self.visible = true
        felt.screen:add(self)
        self:raise()
    end
end

function Menu:hide()
    if self.visible then
        self.visible = false
        self.parent:remove(self)
    end
end
