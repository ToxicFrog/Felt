local configuration = {
	["name"]      = "Player";
	["colour"]    = "#FF0000";
	["join-host"] = "localhost";
	["join-port"] = 8088;
	["host-port"] = 8088;
}

felt.config = {
	dirty = false;
}

function felt.config.set(key, value, ...)
	if not key then
		if felt.config.dirty then
			felt.config.save()
			felt.config.dirty = false
		end
		return
	end
	if configuration[key] ~= value then
		configuration[key] = value
		felt.config.dirty = true
	end
	return felt.config.set(...)
end

function felt.config.get(key, ...)
	if not key then return end
	return configuration[key],felt.config.get(...)
end

function felt.config.init()
	felt.config.file = felt.userdir.."configuration"

	if not felt.config.load() then
		felt.log("Unable to load configuration file, creating default configuration.")
		felt.config.save()
	end
end

function felt.config.load(file)
	file = file or felt.config.file
	
	local fin,err = io.open(file, "r")
	if not fin then
		felt.log('Unable to load configuration file "%s": %s', file, err)
		return false
	end
	
	configuration = felt.deserialize(fin:read '*a')
	fin:close()
	felt.log('Configuration loaded from "%s".', file)
	
	return true
end

function felt.config.save(file)
	file = file or felt.config.file
	
	local fout,err = io.open(file, "w")
	if not fout then
		felt.log("Unable to create configuration file %s: %s", file, err)
		return false
	else
		fout:write(felt.serialize(configuration))
		fout:close()
		felt.log("Configuration saved to %s.", file)
	end
end
