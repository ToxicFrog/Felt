trait(...)

_CLASS:ACTION("Pick Up", "pickup", "mouse_left")

function pickup(self, who)
    self:message("%s picks up %s.", tostring(who), tostring(self))
end
