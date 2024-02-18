local setmetatable <const> = setmetatable

local pairs <const> = pairs

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

function Class:inherentMethods(parentMethods)
	for method,_ in pairs(parentMethods) do
		self.methods[method] = true
	end
	return self
end

function Class:new(name,params,parent)
	local o <const> = setmetatable({name = name, params = params,parent = parent,foundConstructor = false,paramDict = creatParamDictionary(params),methods = {}},self)
	if parent then
		o:inherentMethods(parent.methods)
	end
	return o
end

return Class

