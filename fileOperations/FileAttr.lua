
local setmetatable <const> = setmetatable 

local FileAttr <const> = {}
FileAttr.__index = FileAttr

_ENV = FileAttr

function FileAttr:new(filePath,text)
	local o <const> = setmetatable({filePath = filePath,text = text},self)
	return o
end

return FileAttr
