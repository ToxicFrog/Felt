local Screen = require("Widget"):subclass "Screen"

Screen:defaults {
    menu = {
        title = "Felt";
        "Create Window", function(...) print(...) return Screen.create(...) end;
        "Load Window", felt.load;
        "Host Game", false;
        "Join Game", false;
        "Leave Game", false;
        "test", false;
        "argh", false;
    };
}

function Screen:__init(...)
    Widget.__init(self, ...)
    
    felt.log("screen create %s", tostring(self.menu.visible))
end

function Screen:draw()
    return
end

function Screen:create(menu)
    felt.log("create")
    felt.addWindow { x = menu.x, y = menu.y }
end

function Screen:click_left_before(x, y)
    if felt.held then
        felt.held:dropped(x, y)
        return true
    end
    return false
end

function Screen:key_r()
    love.system.restart()
    return true
end

return Screen

