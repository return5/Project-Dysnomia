
local setmetatable <const> = setmetatable

local FileAttr <const> = {}
FileAttr.__index = FileAttr

_ENV = FileAttr

function FileAttr:setIsLuaFile(isLua)
	self.isLuaFile = isLua
	return self
end

function FileAttr:new(filePath,text,fileName,isLuaFile)
	local o <const> = setmetatable({filePath = filePath,text = text,fileName = fileName,isLuaFile = isLuaFile or false},self)
	return o
end

return FileAttr

