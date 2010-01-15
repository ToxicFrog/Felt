local SavedTable = require("Token"):subclass "SavedTable"

function SavedTable:draw(scale, x, y, w, h)
    w = love.graphics.getFont():getWidth(self.name) + 4
    h = love.graphics.getFont():getHeight() + 4
    love.graphics.setColour(0, 0, 0, 255)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColour(255, 255, 255, 255)
    love.graphics.print(self.name, x+1, y+h-4)
end

function SavedTable:dropped(x, y)
    felt.log("dropped %d %d", x, y)
    
    felt.screen:add(felt.deserialize(love.filesystem.read("save/"..self.name)), x, y)
    felt.held = nil
end

local SaveGamesWindow = require("Window"):subclass "SaveGamesWindow"

SaveGamesWindow:defaults {
    save = false
}

function SaveGamesWindow:__init(...)
    Window.__init(self, ...)
    
    self:refresh()
end
    
function SaveGamesWindow:refresh()
    for game in self.content:children() do
        self.content:remove(game)
    end

    local games = love.filesystem.enumerate("save")
    
    for i,game in ipairs(games) do
        self.content:add(SavedTable { name=game }, 10, i * 12)
    end
    
    self.w = 128
    self.h = #games * 12 + 40
    
    self:resize(self.w, self.h)
end

return SaveGamesWindow