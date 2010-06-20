return function(board)
    function board:drop(x, y, item)
        if item == self then return false end
        
        -- FIXME - there has to be a better way of dropping the item
        item:moveto(self, x - item.w/2, y - item.h/2)
        item:raise()
        felt.held = nil
        return true
    end
end
