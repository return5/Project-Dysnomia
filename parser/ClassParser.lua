local Class <const> = require('parser.Class')
local ClassAndRecordParser <const> = require('parser.ClassAndRecordParser')

local setmetatable <const> = setmetatable

local ClassParser <const> = {type = 'ClassParser',foundConstructor = false}
ClassParser.__index = ClassParser

setmetatable(ClassParser,ClassAndRecordParser)

_ENV = ClassParser

ClassParser.classes = {}

function ClassParser:grabClassParameters(parserParams,startI)
	local openParen <const> = self:loopUntilMatch(parserParams,startI,"%(",self.doNothing)
	local closingParens <const> = self:loopUntilMatch(parserParams,openParen + 1,"%)",self:returnFunctionAddingTextToParams(self.params))
	return closingParens
end

function ClassParser:grabClassParentName(parserParams,startingIndex)
	local nextI <const> = self:loopUntilMatch(parserParams,startingIndex)
	if parserParams:getAt(nextI) == ">"  then
		local parentI <const> = self:loopUntilMatch(parserParams,nextI + 1, "%S",self.doNothing)
		self.parentName = parserParams:getAt(parentI)
		return parentI + 1
	end
	return nextI
end

function ClassParser:grabClassParentIfItExists(parserParams,startingI)
	local newI <const> = self:loopUntilMatch(parserParams,startingI,"[%S\n]",self.doNothing)
	if parserParams:getAt(newI) == ":"then
		return self:grabClassParentName(parserParams,newI)
	end
	return newI
end

function ClassParser:grabClassName(parserParams)
	local nameI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
	self.classOrRecordName = parserParams:getAt(nameI)
	return nameI
end

function ClassParser:setClass()
	local parent <const> = ClassParser.classes[self.parentName]
	local class <const> = Class:new(self.classOrRecordName,self.params,parent)
	ClassParser.classes[self.classOrRecordName] = class
	self.class = class
	return self
end

function ClassParser:startParsingClass(parserParams)
	local openParens <const> = self:grabClassName(parserParams)
	local closingParens <const> = self:grabClassParameters(parserParams,openParens + 1)
	local startOfClass <const> = self:grabClassParentIfItExists(parserParams,closingParens + 1)
	self:setClass()
	self:writeStartOfClass(parserParams)
	parserParams:updateSetI(self,startOfClass)
	return self
end

function ClassParser:writeStartOfClass(parserParams)
	parserParams:getDysText()
			:writeFiveArgs("\nlocal setmetatable <const> = setmetatable\nlocal ",
				self.classOrRecordName," <const> = {}\n",self.classOrRecordName,".__index = ")
			:writeTwoArgs(self.classOrRecordName,"\n")
	self:writeParent(parserParams)
	return self
end

function ClassParser:writeParent(parserParams)
	if self.class.parent then
		parserParams:getDysText():writeFiveArgs("setmetatable(",self.classOrRecordName,",",self.class.parent.name,")\n")
	end
	return self
end

function ClassParser:parseEndClass(parserParams)
	self:secondPass(parserParams,self.classOrRecordName)
	self:writeEndClass(parserParams)
	parserParams:update(self.returnMode,1)
	return self
end

function ClassParser:writeEndClass(parserParams)
	self:writeClassConstructor(parserParams)
	parserParams:getDysText():writeTwoArgs("return ",self.classOrRecordName)
	return self
end

function ClassParser:writeClassConstructor(parserParams)
	if not self.foundConstructor then
		self:writeClassConstructorToDysText(parserParams)
	end
	return self
end

local function writeFinalParamToDysText(dysText,param)
	dysText:write(param)
end

function ClassParser:writeClassConstructorToDysText(parserParams)
	parserParams:getDysText():writeThreeArgs("function ",self.classOrRecordName,":new(")
	self:writeParamsToDysText(parserParams:getDysText(),self.params,self.writeParamAndCommaToDysText,writeFinalParamToDysText)
	parserParams:getDysText():write(")\n")
	self:writeClassConstructorAndParams(parserParams)
	return self
end

function ClassParser:writeClassConstructorAndParams(parserParams)
	if self.class.parent then
		self:writeClassConstructWithParent(parserParams)
	else
		self:writeClassConstructNoParent(parserParams)
	end
	return self
end

function ClassParser:writeClassConstructWithParent(parserParams)
	parserParams:getDysText():writeThreeArgs("\tlocal __obj__ = setmetatable(",self.class.parent.name,":new(")
	self:writeParamsToDysText(parserParams:getDysText(),self.class.parent.params,self.writeParamAndCommaToDysText,writeFinalParamToDysText)
	parserParams:getDysText():write("),self)\n")
	self:writeChildParams(self.class.parent.params)
	parserParams:getDysText():write("\treturn __obj__\nend\n")
	return self
end

local function createParentParamDictionary(parentParams)
	local parentDict <const> = {}
	if parentParams then
		for i=1,#parentParams,1 do
			parentDict[parentParams[i]] = true
		end
	end
	return parentDict
end

function ClassParser:writeChildParams(parserParams,parentParams)
	local parentParamDict <const> = createParentParamDictionary(parentParams)
	for i=1,#self.params,1 do
		if not parentParamDict[self.params[i]] then
			parserParams:getDysText():writeFiveArgs("\t__obj__.",self.params[i]," = ",self.params[i],"\n")
		end
	end
	return self
end

local function writeFinalParamAssignmentToDysText(dysText,param)
	dysText:writeThreeArgs(param," = ",param)
end

function ClassParser:writeClassConstructNoParent(parserParams)
	parserParams:getDysText():write("\treturn setmetatable({")
	self:writeParamsToDysText(parserParams:getDysText(),self.params,self.writeAssignmentOfParams,writeFinalParamAssignmentToDysText)
	parserParams:getDysText():write("},self)\nend\n")
end

function ClassParser:parseConstructor(parserParams)
	self.foundConstructor = true
	local closingParens<const>, constructorParams <const> = self:grabConstructorParams(parserParams)
	self:writeStartOfConstructor(parserParams,constructorParams)
	local finalI <const> = self:writeSuperConstructorIfNeed(parserParams,closingParens,constructorParams)
	parserParams:updateSetI(self,finalI + 1)
	return self
end

function ClassParser:grabConstructorParams(parserParams)
	local openingParens <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%(",self.doNothing)
	local constructorParams <const> = {}
	local closingParens <const> = self:loopUntilMatch(parserParams,openingParens + 1,"%)",self:returnFunctionAddingTextToParams(constructorParams))
	return closingParens,constructorParams
end

function ClassParser:writeStartOfConstructor(parserParams,constructorParams)
	parserParams:getDysText():writeThreeArgs("function ",self.recName,":new(")
	self:writeParamsToDysText(parserParams:getDysText(),constructorParams,self.writeParamAndCommaToDysText,writeFinalParamToDysText)
	parserParams:getDysText():writeTwoArgs(")\n","\t\tlocal __obj__ = setmetatable(")
	return self
end

function ClassParser:writeSuperConstructorIfNeed(parserParams,closingParens,constructorParams)
	if self.class.parent then
		local endSuper <const> = self:writeSuperConstructor(endParen)
		self:writeEndOfConstructor(parserParams,constructorParams)
		return endSuper + 1
	end
	parserParams:getDysText():write("{}),self)\n")
	self:writeEndOfConstructor(parserParams,constructorParams)
	return closingParens + 1
end

local function updateCount(token,openingChar,closingChar,count)
	if token == openingChar then return count + 1 end
	if token == closingChar then return count - 1 end
	return count
end

local function loopThroughUntilClosingChar(start,parserParams,openingChar,closingChar,loopFunc)
	local index = start
	local count = 0
	local limit <const> = parserParams:getLength()
	while count > 0 and index <= limit do
		local token <const> = parserParams:getAt(index)
		count = updateCount(token,openingChar,closingChar,count)
		loopFunc(token)
		index = index + 1
	end
end

local function writeClosingParenToSuper(dysText)
	dysText:write("),self)\n")
end

function ClassParser:writeSuperConstructor(parserParams,closingParens)
	local parentParams <const> = {}
	local openingParensSuper <const> = self:loopUntilMatch(parserParams,closingParens + 1,"%(",self.doNothing)
	local endSuper <const> = loopThroughUntilClosingChar(openingParensSuper + 1,parserParams,"(",")",self:returnFunctionAddingTextToParams(parentParams))
	parentParams[#parentParams] = nil
	parentParams:getDysText():writeTwoArgs(self.class.parent.name,":new(")
	self:writeParamsToDysText(parentParams:getDysText(),parentParams,self.writeParamAndCommaToDysText,writeClosingParenToSuper)
	return endSuper
end


function ClassParser:writeEndOfConstructor(parserParams,params)
	parserParams:getDysText():write("\t\t__obj__:__constructor__(")
	self:writeParamsToDysText(parserParams:getDysText(),params,self.writeParamAndCommaToDysText,writeFinalParamToDysText)
	parserParams:getDysText():writeThreeArgs(")\n\t\treturn __obj__\n\tend\n\nfunction ",self.classOrRecordName,":__constructor__(")
	self:writeParamsToDysText(parserParams:getDysText(),params,self.writeParamAndCommaToDysText,writeFinalParamToDysText)
	parserParams:getDysText():write(")\n")
	return self
end

ClassParser.tokenFuncs['endClass'] = ClassParser.parseEndClass
ClassParser.tokenFuncs['constructor'] = ClassParser.parseConstructor

function ClassParser:new(returnMode,startI)
	return setmetatable(ClassAndRecordParser:new(returnMode,startI),self)
end


return ClassParser
