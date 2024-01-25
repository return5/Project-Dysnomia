
local setmetatable <const> = setmetatable

local FileAttr <const> = {}
FileAttr.__index = FileAttr

_ENV = FileAttr

function FileAttr:setIsLuaFile(isLua)
	self.isLuaFile = isLua
	return self
end

function FileAttr:new(filePath,text,isLuaFile)
	local o <const> = setmetatable({filePath = filePath,text = text,isLuaFile = isLuaFile},self)
	return o
end

return FileAttr
