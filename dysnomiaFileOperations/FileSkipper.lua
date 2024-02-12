local ConfigManager <const> = require('dysnomiaConfig.ConfigManager')
local match <const> = string.match
local write <const> = io.write

local FileSkipper <const> = {type = "FileSkipper"}
FileSkipper.__index = FileSkipper

_ENV = FileSkipper


function FileSkipper:scanForSkipFile(fileAttr)
	local isSkippedFile <const> = match(fileAttr.text,"\n*%s*%-%-.+#[Ss]kip[fF]ile")
	if isSkippedFile then
		write("it is a skipped file\n")
		ConfigManager:addToSkipFiles(fileAttr.filePath)
		return true
	end
	return false
end

return FileSkipper
