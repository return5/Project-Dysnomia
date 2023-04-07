
local setmetatable <const> = setmetatable
local concat <const> = table.concat
local Config <const> = require('config.config')

local ClassProperties <const> = {}
ClassProperties.__index = ClassProperties

_ENV = ClassProperties

function ClassProperties:getParentName()
	if self.parent then
		return self.parent.name
	end
	return self.name
end

function ClassProperties:addFunc(funcName)
	self.funcs[funcName] = true
end

function ClassProperties:findFunc(funcName)
	return self.funcs[funcName]
end

function ClassProperties:generateMetatable(constructorName)
	local params <const> = concat(self.params,",")
	local metatable <const> = {
		"setmetatable(",self.name,",{__index = ",self:getParentName(),",__call = function(_,",params,") return ",self.name,
		":",constructorName,"(",params,") end })",Config.newLine,"return ",self.name,Config.newLine
	}
	return concat(metatable)
end

--hold constructor, loc of closing brackets, name of class, reference to parent class, functions in class

function ClassProperties:new(name,params,parent)
	local paramSet <const> = {}
	for i=1,#params,1 do
		paramSet[params[i]] = true
	end
	return setmetatable({name = name,params = params,parent = parent,paramSet = paramSet,closingLoc = -1,funcs = {} },self)
end

return ClassProperties
