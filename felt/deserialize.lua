function felt.deserialize(buf)
	local dc = new "Deserialization" {
		data = buf;
		game = felt.game;
	}
	
	return (function(...)
		for k,v in pairs(dc.refs) do print("ref", k,v) end
		return ...
	end)(dc:unpack())
end
