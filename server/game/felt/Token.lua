class(..., "game.felt.Entity")

pack = {
    "held"
}

_CLASS:ACTION("Pick Up", "pickup", "mouse_left")

function pickup(self, who)
    print(self, "pickup", who)
    self:set("held", not self.held)
end
