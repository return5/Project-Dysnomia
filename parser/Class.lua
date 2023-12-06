local setmetatable <const> = setmetatable

local Class <const> = {}
Class.__index = Class

_ENV = Class

local function creatParamDictionary(params)
	local parentDict <const> = {}
	if params then
		for i=1,#params,1 do
			parentDict[params[i]] = true
		end
	end
	return parentDict
end

function Class:new(name,params,parent)
	return setmetatable({name = name, params = params,parent = parent,foundConstructor = false,paramDict = creatParamDictionary(params)},self)
end

return Class
