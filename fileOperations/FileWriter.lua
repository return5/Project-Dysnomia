local Config <const> = require('config.config')
local open <const> = io.open
local concat <const> = table.concat
local remove <const> = os.remove

local FileWriter <const> = {}
FileWriter.__index = FileWriter

_ENV = FileWriter

FileWriter.files = {}

function FileWriter.writeFile(fileInfo)
	fileInfo.text[#fileInfo.text] = Config.newLine
	local fileName <const> = fileInfo.filePath .. ".lua"
	local file <const> = open(fileName,"w+")
	file:write(concat(fileInfo.text," "))
	file:close()
	FileWriter.files[#FileWriter.files + 1] = fileName
	return true
end

function FileWriter.removeFiles()
	for i=1,#FileWriter.files,1 do
		remove(FileWriter.files[i])
	end
end

return FileWriter