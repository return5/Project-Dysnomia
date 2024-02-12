local Config <const> = require('dysnomiaConfig.config')

local toLower <const> = string.lower

local ConfigManager <const> = {type = "ConfigManager"}
ConfigManager.__index = ConfigManager

_ENV = ConfigManager

function ConfigManager:addToSkipFiles(file)
	if not Config.skip then Config.skip = {} end
	Config.skip[#Config.skip + 1] = file
	return self
end

function ConfigManager:setOs(os)
	Config.os = toLower(os)
	return self
end

function ConfigManager:setNewLine(newLine)
	Config.newLine = newLine
	return self
end

function ConfigManager:setSep(sep)
	Config.sep = sep
	return self
end

function ConfigManager:setRun(run)
	Config.run = run
	return self
end

function ConfigManager:setTemp(temp)
	Config.temp = temp
	return self
end


return ConfigManager
