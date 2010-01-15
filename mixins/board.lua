return function(board)
    function board:drop(x, y, item)
        if item == self then return false end
        
        item:moveto(self, x - item.w/2, y - item.h/2)
        item:raise()
        felt.held = nil
        return true
    end
end
