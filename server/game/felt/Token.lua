trait(...)

_CLASS:ACTION("Pick Up", "pickup", "mouse_left_S", "mouse_left")

function pickup(self, who)
    -- check: no grabbing pieces out of someone else's hand
    -- check: can't hold more than one thing at once
    if self.held_by or who.held then
        return
    end

    who:pickup(self)
end
