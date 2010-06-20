local Object = require "Object"
local Serializeable = Object:subclass "Serializeable"

Serializeable.save = new "CallableSet" {}

function Serializeable:__clone(child)
	child.save = self.save:copy()
end

function Serializeable:__init(...)
	Object.__init(self, ...)
end

function Serializeable:__save()
    local buf = { "L" }
    
    local function append(s) buf[#buf+1] = s end
    
    append(felt.serialize(self._NAME, "__load"))
    
    -- argument to __load: the set of persistent fields
    append "T"
    for k in pairs(self.save) do
        append(felt.serialize(k, self[k]))
    end
    append "t"    
    append "l"
    
    return table.concat(buf, "")
end

function Serializeable:__load(fields)
	-- create new object
    return self(fields)
end


return Serializeable