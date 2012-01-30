class(..., "game.felt.Entity")

w,h = 380,380
game = "chess"
face = "board"

mixin "game.felt.Board"
grid = { x = 10, y = 10, w = 45, h = 45, rows = 8, cols = 8, center = true }
