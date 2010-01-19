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
end

-- initialize the game

-- create main menu
felt.menu = {
    title = "Felt";
    --"Create Window", function(self, menu) felt.new {} end;
    --"Load Window...", function(self, menu) self:add(new "SaveGamesWindow" {}, menu.x, menu.y) end;
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

felt.screen = new "Screen" {
    menu = felt.menu;
}

-- enable command line
function felt.screen:key_c()
    self:add(new "SettingsWindow" {
        "cmd", "";
        call = function(self)
            felt.log("%s", tostring(false or select(2, pcall(loadstring(self:get "cmd")))))
        end;
    })
    return true
end

-- install the background
felt.background = new "Table" {
    name = "BACKGROUND";
    z = -math.huge;
    x = 0, y = 0;
    w = love.graphics.getWidth(), h = love.graphics.getHeight();
    menu = felt.menu
}

felt.screen:add(felt.background)

-- create the log window
felt.screen:add(new "SystemWindow" {})

-- create the grasping hand
felt.hand = new "Hand" {}
felt.screen:add(felt.hand)

felt.loadmodule "descent"

