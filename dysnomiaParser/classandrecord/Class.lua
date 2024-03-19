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

local function inherentMethods(methods,parentMethods)
	for method,_ in pairs(parentMethods) do
		methods[method] = true
	end
end

local function inherentMetaMethods(metamethods,parentMetamethods)
	for i=1,#parentMetamethods,1 do
		metamethods[i] = parentMetamethods[i]
	end
end

function Class:new(name,params,parent)
	local o <const> = setmetatable({name = name, params = params,parent = parent,foundConstructor = false,paramDict = creatParamDictionary(params),methods = {},staticMethods = {},metaMethods = {}},self)
	if parent then
		inherentMethods(o.methods,parent.methods)
		inherentMethods(o.staticMethods,parent.staticMethods)
		inherentMetaMethods(o.metaMethods,parent.metaMethods)
	end
	return o
end

return Class

