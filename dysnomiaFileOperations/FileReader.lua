
local Config <const> = require('dysnomiaConfig.config')
local FileAttr <const> = require('dysnomiaFileOperations.FileAttr')
local setmetatable <const> = setmetatable
local openFile <const> = io.open
local gsub <const> = string.gsub
local match <const> = string.match


local FileReader <const> = {}
FileReader.__index = FileReader

_ENV = FileReader

FileReader.fileRead = {}

local function findFile(filePath,ending,isLua)
	local fullFilePath <const> = gsub(filePath,"%.",Config.sep)
	local fileName <const> = fullFilePath .. ending
	local file <const> = openFile(fileName,"r")
	if file then
		local text <const> = file:read("a*") .. "\n"
		file:close()
		return FileAttr:new(fullFilePath,text,fileName,isLua)
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
			local dysFile <const> = findFile(self.file,".dys",false)
			--if it is a dysnomia file then we return it for parsing.
			if dysFile then return dysFile end
		end
		if not Config.skip[fileName .. ".lua"] then
			--if it wasnt a dysnomia file then search for a regular lua file.
			local luaFile <const> = findFile(self.file,".lua",true)
			if luaFile then return luaFile end
		end
	end
	return FileAttr:new("","",nil)
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

