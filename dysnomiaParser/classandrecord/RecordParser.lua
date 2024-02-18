local ClassAndRecordParser <const> = require('dysnomiaParser.classandrecord.ClassAndRecordParser')
local Class <const> = require('dysnomiaParser.classandrecord.Class')
local setmetatable <const> = setmetatable


local RecordParser <const> = {type = 'RecordParser'}
RecordParser.__index = RecordParser

setmetatable(RecordParser,ClassAndRecordParser)

RecordParser.tokenFuncs = {}
for token,func in pairs(ClassAndRecordParser.tokenFuncs) do
	RecordParser.tokenFuncs[token] = func
end

_ENV = RecordParser

function RecordParser:writeEndRecord(parserParams)
	parserParams:getDysText():writeFiveArgs("\treturn setmetatable({},{__index = ",self.classOrRecordName,
			",__newindex = function() end,__len = function() return #",self.classOrRecordName," end})\nend")
	return self
end

function RecordParser:handleRecordName(parserParams)
	local newI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
	self.originalRecordName = parserParams:getAt(newI)
	self.classOrRecordName = "__" .. self.originalRecordName .. "__"
	parserParams:getDysText():writeThreeArgs("function ",self.originalRecordName,"(")
	return newI
end

function RecordParser:parseParams(index,parserParams)
	local openParens <const> = self:loopUntilMatch(parserParams,index,"%(",self.doNothing)
	local closeParens <const> = self:loopUntilMatchParams(parserParams,openParens + 1,"%)",self:returnFunctionAddingTextToParams(self.params))
	return closeParens
end
local function writeFinalAssigmentOfParams(dysText,param)
	dysText:writeFourArgs(param," = ",param,"}\n")
end

local function writeFinalRecordParam(dysText,param)
	dysText:writeTwoArgs(param,")\n")
end

function RecordParser:writeRecordFunctionParams(parserParams)
	local dysText <const> = parserParams:getDysText()
	self:writeParamsToDysText(dysText,self.params,self.writeParamAndCommaToDysText,writeFinalRecordParam)
	return self
end

function RecordParser:writeLocalRecordVar(parserParams)
	local dysText <const> = parserParams:getDysText()
	dysText:writeThreeArgs("\tlocal ",self.classOrRecordName," <const> = {")
	self:writeParamsToDysText(dysText,self.params,self.writeAssignmentOfParams,writeFinalAssigmentOfParams)
	return self
end

function RecordParser:createClassObject()
	local class <const> = Class:new(self.classOrRecordName,self.params,parent)
	self.class = class
	return self
end

function RecordParser:startParsingRecord(parserParams)
	local nameI <const> = self:handleRecordName(parserParams)
	local closingParens <const> = self:parseParams(nameI + 1,parserParams)
	self:createClassObject()
	self:writeRecordFunctionParams(parserParams)
	self:writeLocalRecordVar(parserParams)
	parserParams:updateSetI(self,closingParens + 1)
	return self
end

function RecordParser:startParsingLocalRecord(parserParams)
	parserParams:getDysText():write('local ')
	self:startParsingRecord(parserParams)
	return self
end

function RecordParser:parseEndRec(parserParams)
	self:writeEndRecord(parserParams)
	self:secondPass(parserParams,self.originalRecordName)
	parserParams:update(self.returnMode,1)
	return self
end

RecordParser.tokenFuncs['endRec'] = RecordParser.parseEndRec

function RecordParser:new(returnMode,startI)
	return setmetatable(ClassAndRecordParser:new(returnMode,startI),self)
end


return RecordParser

