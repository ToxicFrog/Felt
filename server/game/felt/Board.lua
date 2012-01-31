trait(...)

pack = {
    "grid";
}

_CLASS:ACTION(false, "drop", "drop")

function drop(self, who, x, y)
    -- don't drop items onto themselves or any of their children. Otherwise
    -- you end up with a cycle in the widget graph.
    -- also, don't drop thin air
    if who.held == self or not who.held then
        return
    end

    -- if grid-snap is enabled, apply it
    if self.grid then
        local row = math.floor((x - self.grid.x)/self.grid.w)
        local col = math.floor((y - self.grid.y)/self.grid.h)

        if (not self.grid.rows or row <= self.grid.rows)
        and (not self.grid.cols or col <= self.grid.cols) then
            -- position in upper left corner of selected grid square
            x = row * self.grid.w + self.grid.x
            y = col * self.grid.h + self.grid.y

            -- if centering is enabled, center the dropped item in the grid
            if self.grid.center then
                x = x + (self.grid.w - who.held.w)/2
                y = y + (self.grid.h - who.held.h)/2
            end
        end
    else
        -- center the item
        x = x - who.held.w/2
        y = y - who.held.h/2
    end

    -- actually drop the item onto us
    who:drop(self, x, y)
end
