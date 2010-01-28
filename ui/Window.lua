local Window = require("Widget"):subclass "Window"


local TitleBar = require("Widget"):subclass "TitleBar"
do
    function TitleBar:__init(win)
        Widget.__init(self, {
            x = 1;
            y = 1;
            w = win.w - 13;
            h = 10;
            save = false;
        })
    end
    
    function TitleBar:resize()
        self.w = self.parent.w - 13
    end
    
    function TitleBar:draw(scale, x, y, w, h)
        love.graphics.pushClip(x, y, w, h)
        love.graphics.setColour(0, 0, 0, 255)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColour(255, 255, 255, 255)
        love.graphics.print(self.parent.title, x, y+8)
        love.graphics.popClip()
    end
    
    function TitleBar:grab()
        self.parent:raise()
        return self.parent
    end
    
    function TitleBar:click_middle()
        if self.parent.folded then
            self.parent:unfold()
        else
            self.parent:fold()
        end
        return true
    end
end

local Resizer = require("Widget"):subclass "Resizer"
do
    function Resizer:__init(win)
        Widget.__init(self, {
            x = win.w - 11;
            y = 1;
            w = 10;
            h = 10;
            save = false;
        })
    end
    
    function Resizer:draw(scale, x, y)
        love.graphics.setColour(0, 0, 0, 255)
        love.graphics.rectangle("fill", x, y, self.w, self.h)
        love.graphics.setColour(128, 128, 128, 255)
        love.graphics.triangle("fill",
            x + 2, y + 1,
            x + self.w - 1, y + 1,
            x + self.w - 1, y + self.h - 2
        )
    end
    
    function Resizer:grab()
        return self
    end
    
    function Resizer:drag_left(x, y, dx, dy)
        self.parent:resize(self.parent.w + dx, self.parent.h + dy)
        return true
    end
end

Window:defaults {
    folded = false;
    save = false;
    owned_by = {};
    visible_to = {};
    w = false;
    h = false;
}

Window:persistent "title" "content"

function Window:__index(key)
    if key == "title" or key == "name" then
        return self.content.name or self.content.title
    end
end

function Window:__init(t)
    Widget.__init(self, t)
    
    self.content = self.content or new "Table" {}

    self.content.x = 1
    self.content.y = 12
    self:add(self.content)

    if not self.w then
        self.w = self.content.w + 2
    else
        self.content.w = self.w - 2
    end
    if not self.h then
        self.h = self.content.h + 13
    else
        self.content.h = self.h - 13
    end

    self.titlebar = self:add(TitleBar(self))
    self.resizer = self:add(Resizer(self))
    
    self.titlebar.w = self.w - 13
     
    self.true_h = self.h
    if self.folded then
        self:fold()
    end
end

function Window:click_right(...)
    return self.content:click_right(...)
end

function Window:all_events()
    return self
end

function Window:drag_left(x, y, dx, dy)
    self.x = math.max(-self.w+20,
        math.min(self.x + dx, love.graphics.getWidth() - 10))
    self.y = math.max(0,
        math.min(self.y + dy, love.graphics.getHeight() - 10))
    return true
end

function Window:resize(w, h)
    -- adjust width. This is easy.
    self.w = math.max(w, 64)
    self.titlebar.w = self.w - 13
    self.content.w = self.w - 2
    self.resizer.x = self.w - 11

    self.h = math.max(h, 64)
    self.content.h = self.h - 13
    
    do return end

    -- adjust height. This is hard.
    if not self.folded then
        local bottom = self.y + self.h
        
        self.h = math.max(64, h)
        self.y = bottom - self.h
        
        if self.y <= 0 then
            self.h = self.h + self.y
            self.y = 0
        end
        
        self.true_h = self.h
    end
    
    self.titlebar.w = self.w - 13
    self.content.w = self.w - 2
    self.content.h = self.h - 13
    self.resizer.x = self.w - 11
end

function Window:fold()
    self.folded = true
    self.h = self.titlebar.h + 2
    self.content.visible = false
end

function Window:unfold()
    self.folded = false
    self.h = self.true_h
    self.content.visible = true
end

function Window:draw(scale, x, y, w, h)
    if self.focused then
        love.graphics.setColour(255, 0, 0, 255)
    else
        love.graphics.setColour(255, 255, 255, 255)
    end
    love.graphics.rectangle("fill", x, y, w, h)
end

