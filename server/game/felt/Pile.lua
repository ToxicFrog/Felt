local super = class(..., "game.felt.Entity")

_CLASS:ACTION("Take Item", "takeItem", "mouse_left")

mixin "game.felt.Board"

pack = {
    "count";
}

count = math.huge

function drop(self, ...)
    super.drop(self, ...)
    local child = self.children[1]
    child:destroy()
    self.count = self.count + 1
end

function takeItem(self, who)
    if self.count > 0 then
        local item = new(self.type)(self.ctor)
        item:pickup(who)
        self.count = self.count - 1
    end
end
