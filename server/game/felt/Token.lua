class(..., "game.felt.Entity")

_CLASS:ACTION("Pick Up", "pickup", "mouse_left")

function pickup(self, who)
    print(self, "pickup", who)
end
