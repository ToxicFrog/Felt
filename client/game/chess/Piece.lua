-- a single chess piece

local super = class(..., "game.felt.Entity")

function initGraphics(self)
    self.qgraphics = QGraphicsPixmapItem(QPixmap("client/game/chess/"..self.name..".png"))
    self.qgraphics:setPos(self.x, self.y)
end
