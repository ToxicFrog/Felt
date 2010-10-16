function felt.serialize(...)
	local sc = new "Serialization" {}
	
	for i=1,select('#', ...) do
		sc:pack((select(i, ...)))
	end
	
	for k,v in pairs(sc.refs) do print("pref", v, k) end
	
	return sc:finalize()
end
