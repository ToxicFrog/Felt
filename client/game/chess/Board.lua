-- The chessboard.

local super = class(..., "game.felt.Entity")

function initGraphics(self)
    self.qgraphics = QGraphicsPixmapItem(QPixmap("client/game/chess/board.png"))
    self.qgraphics:setPos(self.x, self.y)
end
