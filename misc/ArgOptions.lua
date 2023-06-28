
local setmetatable <const> = setmetatable 

local ArgOptions <const> = {}
ArgOptions.__index = ArgOptions

_ENV = ArgOptions

function ArgOptions:new(flag,pat,descr,func)
	 return setmetatable({flag = flag,pat = pat,descr = descr,func = func},self)
end

return ArgOptions
