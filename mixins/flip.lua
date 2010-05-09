return function(obj, state)
    obj.hidden = state
    
    function obj:click_middle()
        self:flip()
        return true
    end
    
    function obj:flip()
        if self.hidden then
            self.hidden = not self.hidden
            felt.log("%s flips %s", felt.config.name, tostring(self))
        else
            felt.log("%s flips %s", felt.config.name, tostring(self))
            self.hidden = not self.hidden
        end
    end
    
    function obj:setHidden()
        return
    end
end

