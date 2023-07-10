
--local Parser <const> = require('parser.Parser')
local Config <const> = require('config.config')
local FileAttr <const> = require('fileOperations.FileAttr')
local setmetatable <const> = setmetatable
local openFile <const> = io.open
local gsub <const> = string.gsub
local match <const> = string.match
local FileReader <const> = {}
FileReader.__index = FileReader

_ENV = FileReader

FileReader.fileRead = {}

local function findFile(filePath,ending)
	local fulFilePath <const> = gsub(filePath,"%.",Config.sep)
	local file <const> = openFile(fulFilePath .. ending,"r")
	if file then
		local text <const> = file:read("a*") .. "\n"
		file:close()
		return FileAttr:new(fulFilePath,text)
	end
	return false
end

function FileReader:readFile()
	--if we havent already read this file
	if not self.fileRead[self.file] then
		local fileName <const> = match(self.file,"[^%.]+$")
		self.fileRead[self.file] = true
		if not Config.skip[fileName .. ".dys"] then
			--search for a dysnomia file
			local dysFile <const> = findFile(self.file,".dys")
			--if it is a dysnomia file then we return it for parsing.
			if dysFile then return dysFile,false end
		end
		if not Config.skip[fileName .. ".lua"] then
			--if it wasnt a dysnomia file then search for a regular lua file.
			local luaFile <const> = findFile(self.file,".lua")
			if luaFile then return luaFile,true end
		end
	end
	return false,false
end

--when user passes in main file to start with, they might have included the .dys or .lua ending.
--this messes up our existing code, so we remove that ending if it is there.
function FileReader.checkMainFile(file)
	if file:match("%.lua$") then
		return file:match("(.+)%.lua$")
	end
	if file:match("%.dys$") then
		return file:match("(.+)%.dys$")
	end
	return file
end

function FileReader:new(file)
	return setmetatable({file = file},self)
end

return FileReader
