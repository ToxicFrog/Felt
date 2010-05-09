local Deck = require("felt.Token"):subclass "felt.Deck"

Deck:defaults {
    name = "Deck";
    menu = {
        title = "Deck";
        "Shuffle", function(self) return self:shuffle() end;
        "Sort", function(self) return self:sortByName() end;
    };
    spread = false;
}

function Deck:__init(t)
    felt.Token.__init(self, t)
    
    for i,v in ipairs(t) do
        v.z = i
        self:add(v, 0, 0)
    end
    
    if #self.children > 0 then
        self.w = self.children[1].w
        self.h = self.children[1].h
    end
end

function Deck:click_left_before(x, y)
    if love.keyboard.isDown "lshift" or love.keyboard.isDown "rshift" then
        return felt.Token.click_left(self)
    end
    
    if self.spread then
        return false
    end
    
    if #self.children == 0 then return true end
    
    if love.keyboard.isDown "lctrl" or love.keyboard.isDown "rctrl" then
        return self.children[#self.children]:click_left(x, y)
    else
        return self.children[1]:click_left(x, y)
    end
    
    return true
end

function Deck:drop_before(x, y, item)
    if self.type and not item:instanceof(self.type) then
        return false
    end
    
    -- FIXME combine other decks
    
    item:moveto(self, 0, 0)
    if love.keyboard.isDown "lctrl" or love.keyboard.isDown "rctrl" then
        item:lower()
    else
        item:raise()
    end
    
    return true
end

function Deck:sort()
    felt.Token.sort(self)
    
    if not self.spread then return end
    
    -- layout children
    local col = 1
    local cols = math.ceil(math.sqrt(#self.children))
    local cx,cy = 0,0
    
    for i=#self.children,1,-1 do
        local child = self.children[i]
        
        child.x = cx
        child.y = cy
        if col >= cols then
            self.w = cx + child.w
            col = 1
            cx = 0
            cy = cy + child.h/4
            self.h = cy + child.h
        else
            col = col + 1
            cx = cx + child.w/2
        end
    end
end

function Deck:draw(scale, x, y, w, h)
    if #self.children == 0 then
        love.graphics.setColour(128, 128, 128, 255)
        love.graphics.rectangle("line", x, y, w, h)
        return true
    elseif not self.spread then
        self.children[1]:render(scale, x, y, w, h)
        return true
    else
        self:sort()
        return false
    end
end

function Deck:drawHidden(...)
    return self:draw(...)
end

function Deck:click_middle_before()
    self.spread = not self.spread
    if not self.spread then
        self.w = self.children[1].w
        self.h = self.children[1].h
    end
    return true
end

function Deck:shuffle()
    local newcards = {}
    while #self.children > 0 do
        table.insert(newcards
            , table.remove(self.children
                , math.random(1,#self.children)))
    end
    self:commit(newcards
        , "%s shuffles %s"
        , felt.config.name
        , tostring(self))
end

function Deck:sortByName()
    local newcards = {}
    for child in self:children() do
        table.insert(newcards, child)
    end
    table.sort(newcards, L 'x,y -> tostring(x) < tostring(y)')
    self:commit(newcards
        , "%s sorts %s"
        , felt.config.name
        , tostring(self))
end

function Deck:commit(newdeck, ...)
    felt.log(...)
        
    while #self.children > 0 do
        self.children[#self.children] = nil
    end
    
    for i=1,#newdeck do
        self.children[i] = newdeck[i]
        self.children[i].z = i
    end
    self:sort()
end

