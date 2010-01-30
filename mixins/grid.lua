return function(grid, w, h, x, y)
    local _drop = grid.drop
    
    w = w or 32
    h = h or w
    gx = x or 0
    gy = y or 0
    
    function grid:drop(x, y, item)
        local xoff = item.xoff or 0
        local yoff = item.yoff or 0
        x = math.floor((x - item.w/2 - xoff - gx)/w + 0.5)*w + item.w/2 + xoff + gx
        y = math.floor((y - item.h/2 - yoff - gy)/h + 0.5)*h + item.h/2 + yoff + gy
        return _drop(self, x, y, item)
    end
end     
