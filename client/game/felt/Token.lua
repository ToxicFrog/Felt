local super = class(..., "game.felt.Entity")

function __set_held_by(self, _, value)
    ui.message("%s picks up %s.", value, tostring(self))
    -- FIXME apply shade effect
    self.qgraphics:update()
end
