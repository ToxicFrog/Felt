local List = require "Object" :subclass "List"

for k,v in pairs(table) do
	List[k] = v
end

function List:__init(...)
	local argv = { n = select('#', ...), ... }
	
	for i=1,argv.n do
		self[i] = argv[i]
	end
	
	self.n = argv.n
end

function List:append(v)
	self.n = self.n+1
	self[self.n] = v
end

function List:map(f)
	local l = List()
	
	for i=1,self.n do
		l:append(f(self[i]))
	end
	
	return l
end

return List