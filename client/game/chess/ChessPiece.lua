-- A single chess piece. Basically a Token with a PNG face.

class(..., "felt.Token")

w = false
h = false

mixin "mixins.serialize" ("face", "back")
mixin "ui.render.draw_png" ()
