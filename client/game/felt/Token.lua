local super = class(..., "game.felt.Entity")

function __set_held_by(self, _, value)
    do return end
    if value == client.getInfo().name then
        client.pickup(self)
        self.qgraphics:setOpacity(0.5)
        -- FIXME make transparent
    elseif value then
        -- FIXME glow
    else
        self.qgraphics:setOpacity(1.0)
    end

    self.qgraphics:update()
end
