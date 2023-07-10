local setmetatable <const> = setmetatable

local concat <const> = table.concat

local Class <const> = {}
Class.__index = Class

_ENV = Class

function Class:new(name,params,parent)
	return setmetatable({name = name, params = params,parent = parent,foundConstructor = false},self)
end

return Class
