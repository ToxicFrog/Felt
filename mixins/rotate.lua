return function(class, amount)
    function class:click_middle()
        self:rotate(self.theta + amount)
        return true
    end
end

