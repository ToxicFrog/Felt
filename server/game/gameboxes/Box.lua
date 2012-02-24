class(..., "game.felt.Entity")

_CLASS:ACTION("Open", "open", "mouse_left")

function open(self)
    print("Opening ", self.game, self.opened)
	if not self.opened then
		server.game():openGame(self.game)
		self.opened = true
		self.parent:remove(self)
	end
end
