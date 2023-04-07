
local setmetatable <const> = setmetatable
local concat <const> = table.concat
local random <const> = math.random
local Config <const> = require('config.config')


local ConstructorProperties <const> = {}
ConstructorProperties.__index = ConstructorProperties

_ENV = ConstructorProperties

local function generateMetatable(objName,name,parent,sep1,sep2,params)
	return {"local ",objName," <const> = setmetatable(",parent,sep1,params,sep2,",{__index = ",name,"})"}
end

function ConstructorProperties:replaceSuper(params)
	self.metatableExist = true
	return self:makeMetatableWithParent(params)
end

local function adjustParams(params)
	local adjustedParams <const> = {}
	for i=1,#params,1 do
		adjustedParams[#adjustedParams + 1] = params[i]
		adjustedParams[#adjustedParams + 1] = " = "
		adjustedParams[#adjustedParams + 1] = params[i]
		adjustedParams[#adjustedParams + 1] = ","
	end
	adjustedParams[#adjustedParams] = nil
	return adjustedParams
end

function ConstructorProperties:makeMetatableNoParent(params)
	local adjustedParams <const> = concat(adjustParams(params))
	local constTbl <const> = generateMetatable(self.objName,self.classProperties.name,"","{","}",adjustedParams)
	return concat(constTbl)
end

function ConstructorProperties:makeMetatableWithParent(params)
	local constTbl <const> = generateMetatable(self.objName,self.classProperties.name,self.classProperties:getParentName(),"(",")",concat(params,","))
	return concat(constTbl)
end

function ConstructorProperties:makeMetatable()
	if self.classProperties.parent then
		return self:makeMetatableWithParent(self.classProperties.parent.params)
	end
	return self:makeMetatableNoParent({})
end

function ConstructorProperties:generateConstructorReturn()
	if not self.includeReturn then
		return
	end
	local returnStatement <const> = {"return ",self.objName,"\n","end",Config.newLine}
	return concat(returnStatement)
end

function ConstructorProperties:generateNoParentConstructor()
	local metatable <const> = self:makeMetatableNoParent(self.classProperties.params)
	local constructor <const> = {
		"function ",self.classProperties.name,":new(",concat(self.classProperties.params,","),")",Config.newLine,
		metatable,Config.newLine,self:generateConstructorReturn()
	}
	return concat(constructor)
end

local function generateChildParams(constructor,params,parentParams,objName)
	for i = 1,#params,1 do
		if not parentParams[params[i]] then
			constructor[#constructor + 1] = objName
			constructor[#constructor + 1] = "."
			constructor[#constructor + 1] = params[i]
			constructor[#constructor + 1] = " = "
			constructor[#constructor + 1] = params[i]
			constructor[#constructor + 1] =  Config.newLine
		end
	end
end

function ConstructorProperties:generateConstructorWithParent()
	local metatable <const> = self:makeMetatableWithParent(self.classProperties.parent.params)
	local constructor <const> = {
		"function ",self.classProperties.name,":new(",concat(self.classProperties.params,","),")",Config.newLine,
		metatable,Config.newLine
	}
	generateChildParams(constructor,self.classProperties.params,self.classProperties.parent.paramSet,self.objName)
	constructor[#constructor + 1] = self:generateConstructorReturn()
	return concat(constructor)
end

function ConstructorProperties:generateConstructor()
	self.name = "new"
	if not self.classProperties.parent then
		return self:generateNoParentConstructor()
	end
	return self:generateConstructorWithParent()
end

local nameTable <const> = {
	"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w",
	"x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
}

--we want objName to be a unique name.
local function generateRandomName()
	local name <const> = {}
	for i=1,15,1 do
		name[i] = nameTable[random(#nameTable)]
	end
	return concat(name)
end

--hold info about constructor. if exists then update otherwise construct it.
function ConstructorProperties:new(classProperties,loc)
	local o <const> = setmetatable({constExist = false,classProperties = classProperties,includeReturn = true,metatableExist = false,objName = generateRandomName()},self)
	return o
end

return ConstructorProperties
