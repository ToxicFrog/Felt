local Spinner = require ("felt.ImageToken")
    :subclass "felt.Spinner"
    
Spinner:defaults {
    count = 0;
    min = 0;
    max = math.huge;
    step = 1;
    step2 = 5;
    step3 = 25;
}

Spinner:persistent "count" "min" "max" "step" "step2" "step3"
Spinner:sync "set"

function Spinner:__init(...)
    felt.ImageToken.__init(self, ...)
    
    self.label = require "Label" { text = tostring(self.count) }
    self:add(self.label, self.w/2 - self.label.w/2, self.h - self.label.h)
end

function Spinner:click_wheelup()
    local step = self.step
    if love.keyboard.isDown "lshift" or love.keyboard.isDown "rshift" then
        step = self.step2
    elseif love.keyboard.isDown "lctrl" or love.keyboard.isDown "rctrl" then
        step = self.step3
    end
    
    self:set(self.count + step)
    return true
end

function Spinner:click_wheeldown()
    local step = self.step
    if love.keyboard.isDown "lshift" or love.keyboard.isDown "rshift" then
        step = self.step2
    elseif love.keyboard.isDown "lctrl" or love.keyboard.isDown "rctrl" then
        step = self.step3
    end
    
    self:set(self.count - step)
    return true
end

function Spinner:set(n)
    n = math.max(math.min(n, self.max), self.min)
    if n == self.count then return end
    self.count = n
    self.label:set(tostring(n))
    
    felt.log("%s adjusts %s to %d"
        , felt.config.name
        , tostring(self)
        , n)
end

