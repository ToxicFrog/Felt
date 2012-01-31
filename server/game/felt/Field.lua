local super = class(..., "game.felt.Entity")

name = "(untitled field)"

mixin "game.felt.Board"

function __init(self, t)
    super.__init(self, t)
    
    self.vis = self.vis or {}
end
