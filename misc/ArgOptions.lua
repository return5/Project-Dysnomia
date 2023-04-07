
local setmetatable <const> = setmetatable

local ArgOptions <const> = {}
ArgOptions.__index = ArgOptions

function ArgOptions:new(option,pat,description,func)
	return setmetatable({pat = pat,option = option,desc = description,func = func},self)
end

return ArgOptions
