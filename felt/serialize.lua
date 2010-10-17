function felt.serialize(...)
	local sc = new "Serialization" {}
	
	for i=1,select('#', ...) do
		sc:pack((select(i, ...)))
	end
	
	return sc:finalize()
end
