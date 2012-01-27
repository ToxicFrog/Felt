class(..., "game.felt.Entity")

pack = {
    "held_by"
}

_CLASS:ACTION("Pick Up", "pickup", "mouse_left")

function pickup(self, who)
    if self.held_by then return end
    self:set("held_by", who.name)
end
