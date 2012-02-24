class(..., "game.felt.Entity")

w,h = 480,480
game = "go"
name = "goban"

mixin "game.felt.Board"
grid = { x = 4, y = 4, w = 25, h = 25, rows = 19, cols = 19, center = true }
