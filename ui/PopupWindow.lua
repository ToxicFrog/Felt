local PopupWindow = require("Widget"):subclass "PopupWindow"

PopupWindow:defaults {
    z = math.huge;
    save = false;
}

local Setting = require("Widget"):subclass "Setting"
do
    function Setting:__init(...)
        Widget.__init(self, ...)
        
        local label = new "Label" { text = self.text, x=0 }
        local entry = new "TextInput" { text = self.value, x = label.w+1 }
        
        label.y = math.floor(math.max(0,entry.h - label.h)/2)
        entry.y = math.floor(math.max(0,label.h - entry.h)/2)
                
        self.h = math.max(label.h, entry.h)
        self.w = label.w + entry.w + 1
        
        self:add(label)
        self:add(entry)
        
        self.value = entry
    end
    
    function Setting:draw() end
end

function PopupWindow:__init(...)
    Widget.__init(self, ...)
    self.settings = {}
    
    assert(self.buttons, "PopupWindow instantiated without buttons")

    local w = 0
    local y = 1
    local i = 1
    
    for i=1,#self,2 do
        local key = self[i]
        local value = self[i+1]
        local line = self:add(Setting { text = key, value = value }, 1, y)
        y = y + line.h + 1
        w = math.max(w, line.w)
        self.settings[key] = line
    end
    
    for _,line in pairs(self.settings) do
        line.w = w
        line.value.x = line.w - line.value.w
    end
    
    self.w = w + 2
    
    -- add the buttons
    local x = 2
    for i=1,#self.buttons,2 do
        local f = self.buttons[i+1]
        local button = new "Button" {
            y = y;
            text = self.buttons[i];
            call = function() f(self) end;
        }
        self:add(button, x, y)
        x = x + button.w + 1
        self.h = y + button.h + 1
        self.w = math.max(self.w, x)
    end

    self.x = (love.graphics.getWidth() - self.w)/2
    self.y = (love.graphics.getHeight() - self.h)/2
end        

function PopupWindow:inBounds()
    return true
end

function PopupWindow:draw(_, x, y, w, h)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.rectangle("fill", x-1, y-1, w+2, h+2)
    love.graphics.setColour(0, 0, 0, 255)
    love.graphics.rectangle("fill", x, y, w, h)
end

function PopupWindow:get(key)
    return self.settings[key].value.text
end

return PopupWindow

