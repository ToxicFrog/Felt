local super = class(..., "game.felt.Entity")

function __set_held(self, _, value)
    if value then
        self.qgraphics:setBrush(QBrush(QColor(0, 0, 255)))
    else
        self.qgraphics:setBrush(QBrush(QColor(255, 0, 0)))
    end
    self.qgraphics:update()
end
