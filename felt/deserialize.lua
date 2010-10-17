function felt.deserialize(buf)
	local dc = new "Deserialization" {
		data = buf;
		game = felt.game;
	}
	
	return dc:unpack()
end
