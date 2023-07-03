
--local Parser <const> = require('parser.Parser')
local Config <const> = require('config.config')
local FileAttr <const> = require('fileOperations.FileAttr')
local Scanner <const> = require('scanner.Scanner')
local setmetatable <const> = setmetatable
local openFile <const> = io.open
local gsub <const> = string.gsub

local FileReader <const> = {}
FileReader.__index = FileReader

_ENV = FileReader

local function findFile(filePath,ending)
	local fulFilePath <const> = gsub(filePath,"%.",Config.sep)
	local file <const> = openFile(fulFilePath .. ending,"r")
	if file then
		local text <const> = file:read("a*") .. "\n"
		file:close()
		return Scanner:new(text):scanFile(),fulFilePath
	end
	return false
end

function FileReader:readFile(filePath)
	--if we havent already read this file
	if not self.fileRead[filePath] then
		self.fileRead[filePath] = true
		--search for a dysnomia file
		local dysFile,dysFilePath <const> = findFile(filePath,".dys")
		--if it is a dysnomia file then we parse through it.
		if dysFile then
			--TODO fix this
			--local parser <const> = Parser:new(FileAttr:new(dysFilePath,dysFile),self)
			--parser:startParsing()
			--return true
			return dysFile
		end
		--if it wasnt a dysnomia file then search for a regular lua file.
		local luaFile,luaFilePath <const> = findFile(filePath,".lua")
		if luaFile then
			--TODO fix this.
			--local parser <const> = Parser:new(FileAttr:new(luaFilePath,luaFile),self)
			--we are only interested in searching for the require keyword in lua files.
			--parser:loopForRequire()
			return true
		end
	end
	return false
end

--when user passes in main file to start with, they might have included the .dys or .lua ending.
--this messes up our existing code, so we remove that ending if it is there.
function FileReader:checkMainFile(file)
	if file:match("%.lua$") then
		return file:match("(.+)%.lua$")
	end
	if file:match("%.dys$") then
		return file:match("(.+)%.dys$")
	end
	return file
end

function FileReader:new()
	return setmetatable({fileRead = {}},self)
end

return FileReader
