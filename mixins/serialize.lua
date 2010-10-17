-- default to generating an ID reference
function __send(self, sc)
	assert(self.id, "attempt to __send an object with no ID")
	
	sc:append("I")
	sc:pack(self.id)
end

-- default to saving all 
function __save(self, sc)
	local pack = {}
	local node = self.__save_fields
	while node do
		pack[node.key] = self[node.key]
		node = node.next
	end
	
	sc:append("C ")
	sc:pack(self._NAME)
	sc:append(" ")
	sc:pack(pack)
end

for i=1,select('#', ...) do
	local old = __save_fields
	__save_fields = {
		next = old;
		key = (select(i, ...))
	}
end
