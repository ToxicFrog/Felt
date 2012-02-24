-- A single chess piece. Basically a Token with a PNG face.

local super = class(..., "game.felt.Entity")

mixin "game.felt.Token"

w,h = 23,23
game = "go"
