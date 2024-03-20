local Class <const> = require('dysnomiaParser.classandrecord.Class')
local ClassAndRecordParser <const> = require('dysnomiaParser.classandrecord.ClassAndRecordParser')
local Config <const> = require('dysnomiaConfig.config')

local setmetatable <const> = setmetatable

local ClassParser <const> = {type = 'ClassParser',foundConstructor = false}
ClassParser.__index = ClassParser

setmetatable(ClassParser,ClassAndRecordParser)

ClassParser.tokenFuncs = {}
for token,func in pairs(ClassAndRecordParser.tokenFuncs) do
	ClassParser.tokenFuncs[token] = func
end

_ENV = ClassParser

ClassParser.classes = {}

function ClassParser:grabClassParameters(parserParams,startI)
	local openParen <const> = self:loopUntilMatch(parserParams,startI,"%(",self.doNothing)
	local closingParens <const> = self:loopUntilMatchParams(parserParams,openParen + 1,"%)",self:returnFunctionAddingTextToParams(self.params))
	return closingParens
end

function ClassParser:grabClassParentName(parserParams,startingIndex)
	local nextI <const> = self:loopUntilMatch(parserParams,startingIndex + 1, "%S",self.doNothing)
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
			:writeFiveArgs(Config.newLine,"local setmetatable <const> = setmetatable",Config.newLine,"local ",self.classOrRecordName)
			:writeFiveArgs(" <const> = {__className = '",self.classOrRecordName,"'}",Config.newLine,self.classOrRecordName)
			:writeThreeArgs(".__index = ",self.classOrRecordName,Config.newLine)
	self:writeParent(parserParams)
	return self
end

function ClassParser:writeParent(parserParams)
	if self.parentName then
		parserParams:getDysText():writeFiveArgs("setmetatable(",self.classOrRecordName,",",self.parentName,")"):write(Config.newLine)
	end
	return self
end

function ClassParser:parseEndClass(parserParams)
	self:secondPass(parserParams,self.classOrRecordName)
	self:writeEndClass(parserParams)
	parserParams:update(self.returnMode,1)
	self:writeCustomMetaMethods(Config.newLine .. self.classOrRecordName ..".",parserParams:getDysText(),Config.newLine)
	return self
end

function ClassParser:writeEndClass(parserParams)
	self:writeClassConstructor(parserParams)
	self.metaMethodsI = parserParams:getDysText():getLength()
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
	if self.parentName then
		self:writeClassConstructWithParent(parserParams)
	else
		self:writeClassConstructNoParent(parserParams)
	end
	return self
end

local function writeChildParamAssignment(dysText,param)
	dysText:writeFiveArgs("\t__obj__.",param," = ",param,Config.newLine)
end

function ClassParser:writeClassConstructWithParent(parserParams)
	parserParams:getDysText():writeThreeArgs("\tlocal __obj__ = setmetatable(",self.parentName,":new(")
	self:writeParamsToDysText(parserParams:getDysText(),self.class.parent.params,self.writeParamAndCommaToDysText,writeFinalParamToDysText)
	parserParams:getDysText():writeTwoArgs("),self)",Config.newLine)
	self:writeChildParams(parserParams,writeChildParamAssignment,writeChildParamAssignment)
	parserParams:getDysText():writeFourArgs("\treturn __obj__",Config.newLine,"end",Config.newLine)
	return self
end

function ClassParser:writeChildParams(parserParams,writeFunction,finalWriteFunction)
	local parentParamDict <const> = self.class.parent and self.class.parent.paramDict or {}
	local dysText <const> = parserParams:getDysText()
	if #self.params > 0 then
		for i=1,#self.params - 1,1 do
			if not parentParamDict[self.params[i]] then
				writeFunction(dysText,self.params[i])
			end
		end
		if not parentParamDict[self.params[#self.params]] then finalWriteFunction(dysText,self.params[#self.params]) end
	end
	return self
end

local function writeFinalParamAssignmentToDysText(dysText,param)
	if param then
		dysText:writeThreeArgs(param," = ",param)
	end
end

function ClassParser:writeClassConstructNoParent(parserParams)
	parserParams:getDysText():write("\treturn setmetatable({")
	self:writeParamsToDysText(parserParams:getDysText(),self.params,self.writeAssignmentOfParams,writeFinalParamAssignmentToDysText)
	parserParams:getDysText():writeFourArgs("},self)",Config.newLine,"end",Config.newLine)
end

function ClassParser:writeSuperConstructorIfNeed(parserParams,closingParens)
	if self.parentName then
		return self:writeSuperConstructor(parserParams,closingParens) + 1
	end
	parserParams:getDysText():writeTwoArgs("{},self)",Config.newLine)
	return closingParens + 1
end

function ClassParser:writeStartOfConstructor(parserParams,constructorParams)
	parserParams:getDysText():writeThreeArgs("function ",self.classOrRecordName,":new(")
	self:writeParamsToDysText(parserParams:getDysText(),constructorParams,self.writeParamAndCommaToDysText,writeFinalParamToDysText)
	parserParams:getDysText():writeThreeArgs(")",Config.newLine,"\t\tlocal __obj__ = setmetatable(")
	return self
end

function ClassParser.writeAssignmentOfParams(dysText,param)
	dysText:writeFourArgs(param," = ",param,",")
end

local function updateCount(token,openingChar,closingChar,count)
	if token == openingChar then return count + 1 end
	if token == closingChar then return count - 1 end
	return count
end

local function loopThroughUntilClosingChar(start,parserParams,openingChar,closingChar,loopFunc)
	local index = start
	local limit <const> = parserParams:getLength()
	local word <const> = {}
	local count = 1
	while index <= limit do
		local token <const> = parserParams:getAt(index)
		count = updateCount(token,openingChar,closingChar,count)
		if count <= 0 then break end
		loopFunc(token,word)
		index = index + 1
	end
	loopFunc(",",word)
	return index
end

local function writeClosingParenToSuper(dysText,param)
	dysText:writeThreeArgs(param,"),self)",Config.newLine)
end

function ClassParser:writeSuperConstructor(parserParams,closingParens)
	local superParams <const> = {}
	local openingParensSuper <const> = self:loopUntilMatch(parserParams,closingParens + 1,"%(",self.doNothing)
	local endSuper <const> = loopThroughUntilClosingChar(openingParensSuper + 1,parserParams,"(",")",self:returnFunctionAddingTextToParams(superParams))
	parserParams:getDysText():writeTwoArgs(self.parentName,":new(")
	self:writeParamsToDysText(parserParams:getDysText(),superParams,self.writeParamAndCommaToDysText,writeClosingParenToSuper)
	return endSuper
end

function ClassParser:writeEndOfConstructor(parserParams)
	parserParams:getDysText():write("\t\t__obj__:__constructor__(")
	self:writeChildParams(parserParams,self.writeParamAndCommaToDysText,writeFinalParamToDysText)
	parserParams:getDysText():writeFiveArgs(")",Config.newLine,"\t\treturn __obj__\n\tend",Config.newLine,"function "):writeTwoArgs(self.classOrRecordName,":__constructor__(")
	self:writeChildParams(parserParams,self.writeParamAndCommaToDysText,writeFinalParamToDysText)
	parserParams:getDysText():writeTwoArgs(")",Config.newLine)
	return self
end

ClassParser.tokenFuncs['endClass'] = ClassParser.parseEndClass

function ClassParser:new(returnMode,startI)
	return setmetatable(ClassAndRecordParser:new(returnMode,startI),self)
end


return ClassParser

