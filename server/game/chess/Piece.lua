-- A single chess piece. Basically a Token with a PNG face.

local super = class(..., "game.felt.Entity")

mixin "game.felt.Token"

w,h = 45,45
game = "chess"

mixin "game.felt.Token"
mixin "game.felt.Board"

-- if someone else drops a chess piece on us, swap places with it
function drop(self, who, x, y)
    if not self.parent:isInstanceOf("game.chess.Board") then return end

    self.parent:drop(who, x + self.x, y + self.y)
    self:pickup(who)
end
