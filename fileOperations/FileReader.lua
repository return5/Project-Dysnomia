
local Parser <const> = require('parser.Parser')
local Config <const> = require('config.config')
local FileAttr <const> = require('fileOperations.FileAttr')
local setmetatable <const> = setmetatable
local gmatch <const> = string.gmatch
local openFile <const> = io.open
local gsub <const> = string.gsub
local concat <const> = table.concat

local FileReader <const> = {}
FileReader.__index = FileReader

_ENV = FileReader

local function handleMultiLineString(char,strTbl)
	strTbl[#strTbl + 1] = char
	if char == "]" and strTbl[#strTbl - 1] == "]" then
		return false
	end
	return true
end

local function checkSpace(char)
	return char == " " or char == "\t"
end

local function checkQuotes(char)
	return char == "'" or char == '"'
end

local function handleString(char,strTbl,closingQuote)
	strTbl[#strTbl + 1] = char
	if char == closingQuote then
		return false
	end
	return true
end

local function resetStrTbl(strTbl,tbl)
	if #strTbl > 0 then
		tbl[#tbl + 1] = concat(strTbl)
	end
	return {}
end

local function readFileIntoTbl(file)
	local tbl <const> = {}
	local strTbl = {}
	local inString = false
	local closingQuote = ""
	local multiLineString = false
	for char in gmatch(file,".") do
		if multiLineString then
			multiLineString = handleMultiLineString(char,strTbl)
		elseif inString then
			inString = handleString(char,strTbl,closingQuote)
		elseif checkSpace(char) then
			strTbl = resetStrTbl(strTbl,tbl)
		elseif char == ";" or char == "}" then
			strTbl = resetStrTbl(strTbl,tbl)
			tbl[#tbl + 1] = char
		elseif checkQuotes(char) then
			closingQuote = char
			inString = true
			strTbl[#strTbl + 1] = char
		elseif char == "\n" then
			strTbl = resetStrTbl(strTbl,tbl)
			tbl[#tbl + 1] = char
		elseif char == "[" and strTbl[#strTbl] == "[" then
			multiLineString = true
			strTbl[#strTbl + 1] = char
		else
			strTbl[#strTbl + 1] = char
		end
	end
	return tbl
end

local function findFile(filePath,ending)
	local fulFilePath <const> = gsub(filePath,"%.",Config.sep)
	local file <const> = openFile(fulFilePath .. ending,"r")
	if file then
		local text <const> = file:read("a*") .. "\n"
		file:close()
		local tbl <const> = readFileIntoTbl(text)
		return tbl,fulFilePath
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
			local parser <const> = Parser:new(FileAttr:new(dysFilePath,dysFile),self)
			parser:startParsing()
			return true
		end
		--if it wasnt a dysnomia file then search for a regular lua file.
		local luaFile,luaFilePath <const> = findFile(filePath,".lua")
		if luaFile then
			local parser <const> = Parser:new(FileAttr:new(luaFilePath,luaFile),self)
			--we are only interested in searching for the require keyword in lua files.
			parser:loopForRequire()
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
