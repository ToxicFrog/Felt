local super = class(..., "game.felt.Object")

pack = {
    "name";
    "held";
    "r", "g", "b";
}

function __tostring(self)
    return self.name
end

function disconnect(self)
    if self.held then
        self.held:set("held_by", nil)
        self:set("held", nil)
    end

    server.message("%s disconnected.", tostring(self))
end

function pickup(self, item)
    self:set("held", item)
    item:set("held_by", self)
    server.message("%s picks up %s.", tostring(self), tostring(item))
end

function drop(self, onto, x, y)
    assert(self.held, "drop with empty hand")

    local item = self.held
    self:set("held", nil)
    item:set("held_by", nil)
    item:moveto(onto, x, y)

    server.message("%s drops %s on %s", tostring(self), tostring(item), tostring(onto))
end
