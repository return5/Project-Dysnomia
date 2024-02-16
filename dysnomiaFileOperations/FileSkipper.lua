local ConfigManager <const> = require('dysnomiaConfig.ConfigManager')
local match <const> = string.match

local FileSkipper <const> = {type = "FileSkipper"}
FileSkipper.__index = FileSkipper

_ENV = FileSkipper


function FileSkipper:scanForSkipFile(fileAttr)
	local isSkippedFile <const> = match(fileAttr.text,"\n*%s*%-%-.+#[Ss]kip[fF]ile")
	if isSkippedFile then
		ConfigManager:addToSkipFiles(fileAttr.filePath)
		return true
	end
	return false
end

return FileSkipper
