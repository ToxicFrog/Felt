local super = class(..., "game.felt.Entity")

mixin "game.felt.Board"
mixin "game.felt.Token"

_CLASS:ACTION("Take Item", "takeItem", "mouse_left")

pack = {
    "count";
}

count = math.huge

local _drop = drop
function drop(self, who, ...)
    -- don't accept items of a different type than we are configured to hold
    if who.held and not who.held:isInstanceOf(self.type) then return end

    _drop(self, who, ...)
    local child = self.children[1]
    child:delete()
    self.count = self.count + 1
end

function takeItem(self, who)
    if self.count > 0 then
        local item = new(self.type)(self.ctor)
        item:pickup(who)
        self.count = self.count - 1
    end
end
