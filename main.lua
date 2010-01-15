love.filesystem.load "lib/init.lua" ()

-- initialize love2d
love.filesystem.setIdentity("Felt")
love.graphics.setFont(10)
love.graphics.setBackgroundColour(64, 128, 64)
love.graphics.setLineStyle("rough")
love.graphics.setColourMode("modulate")

-- load supporting libraries
require "felt"
require "serialize"
require "deserialize"
require "input"
require "settings"
require "net"
require "dispatch"

-- install update callback
function love.update(...)
    input.update(...)
    net.update(...)
end

-- install rendering callback
function love.draw()
    felt.screen:render(1.0, felt.screen.x, felt.screen.y, felt.screen.w, felt.screen.h)
    
    if felt.held then
        local x,y = love.mouse.getPosition()
        local w,h = felt.held.w,felt.held.h
        felt.held:render(1.0, x - w/2, y - h/2, w, h)
    end
end

-- initialize the game
felt.screen = new "Screen" {
    menu = {
        title = "Felt";
        "Create Window", function(self, menu) felt.new(menu.x, menu.y) end;
        "Load Window...", function(self, menu) self:add(new "SaveGamesWindow" {}, menu.x, menu.y) end;
        "--";
        "Save Game...", felt.savegame;
        "Load Game...", felt.loadgame;
        "--";
        "Host Game...", felt.host;
        "Join Game...", felt.join;
    --        "Leave Game", felt.leave;
        "--";
        "Settings...", felt.configure;
        "--";
        "Quit", function() love.event.push "q" end;
    };
}

function felt.screen:key_c()
    self:add(new "SettingsWindow" {
        "cmd", "";
        call = function(self)
            felt.log("%s", tostring(false or select(2, pcall(loadstring(self:get "cmd")))))
        end;
    })
    return true
end

felt.screen:add(new "SystemWindow" {})

local t = felt.new()
t:add(new "felt.Deck" {
    new "felt.ImageToken" { face="modules/chess/bbishop.png" };
    new "felt.ImageToken" { face="modules/chess/bknight.png" };
    new "felt.ImageToken" { face="modules/chess/bpawn.png" };
    new "felt.ImageToken" { face="modules/chess/bking.png" };
})

