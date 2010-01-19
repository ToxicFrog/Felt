return function(grid, w, h, x, y)
    local _drop = grid.drop
    
    w = w or 32
    h = h or w
    x = x or 0
    y = y or 0
    
    function grid:drop(x, y, item)
        x = math.floor((x - item.w/2)/w + 0.5)*w + item.w/2
        y = math.floor((y - item.h/2)/h + 0.5)*h + item.h/2
        return _drop(self, x, y, item)
    end
end     
