require "lib.init"

require "ui.init"

local function stubify(name)
	local mt = {}
	
	function mt:__call(...)
		print("STUB", name, ...)
		if ui.message then
			felt.log("STUB: %s", name)
		end
	end
	
	function mt:__index(key)
		self[key] = stubify(name.."."..key)
		return self[key]
	end
	
	return setmetatable({}, mt)
end

felt = stubify "felt"

function felt.log(...)
	ui.message(string.format(...))
end

ui.run()

-- load supporting libraries
--require "felt"
--require "serialize"
--require "deserialize"
--require "input"
--require "settings"
--require "net"
--require "dispatch"


