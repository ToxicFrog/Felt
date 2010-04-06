local SettingsWindow = require("PopupWindow"):subclass "SettingsWindow"

SettingsWindow.buttons = {
    "OK", function(self) self.parent:remove(self) self:call() end;
    "Cancel", function(self) self.parent:remove(self) end;
}

function SettingsWindow:__init(...)
    PopupWindow.__init(self, ...)
    assert(self.call, "SettingsWindow instantiated without call method")
end        

return SettingsWindow

