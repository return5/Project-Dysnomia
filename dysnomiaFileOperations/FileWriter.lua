local Config <const> = require('dysnomiaConfig.config')
local open <const> = io.open
local concat <const> = table.concat
local remove <const> = os.remove
local setmetatable <const> = setmetatable

local write = io.write


local FileWriter <const> = {}
FileWriter.__index = FileWriter

_ENV = FileWriter

FileWriter.files = {}

function FileWriter:writeFile()
	self.file.text[#self.file.text] = Config.newLine
	local fileName <const> = self.file.filePath .. ".lua"
	write("writing: ",fileName,"\n")
	local file <const> = open(fileName,"w+")
	file:write(concat(self.file.text))
	file:close()
	FileWriter.files[#FileWriter.files + 1] = fileName
	return true
end

function FileWriter:removeFiles()
	for i=1,#FileWriter.files,1 do
		remove(FileWriter.files[i])
	end
end

function FileWriter:new(file)
	return setmetatable({file = file},self)
end

return FileWriter