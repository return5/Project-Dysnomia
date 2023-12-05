local ClassAndRecordParser <const> = require('parser.ClassAndRecordParser')
local setmetatable <const> = setmetatable
local match <const> = string.match

local RecordParser <const> = {type = 'RecordParser'}
RecordParser.__index = RecordParser

setmetatable(RecordParser,ClassAndRecordParser)

_ENV = RecordParser

function RecordParser:writeEndRecord(parserParams)
	local tempRecName <const> = "__" .. self.recordName .. "__"
	parserParams:getDysText():writeFiveArgs("\treturn setmetatable({},{__index = ",tempRecName,
			",__newindex = function() end,__len = function() return #",tempRecName," end})\nend")
	return self
end

function RecordParser:writeSelfInFrontOfMethodCall(i,dysText,regex,parserParams)
	local prevI <const> = self:loopBackUntilMatch(parserParams,i - 1,"%S",self.doNothing)
	local text <const> = dysText:getTextAt(prevI)
	if text ~= "." and text ~= ":" and not match(text,regex) and not match(text,"self:") then
		dysText:replaceTextAt("self:" .. text,i)
	end
	return self
end

function RecordParser:recordSecondPass(parserParams)
	local regex <const> = self.recordName .. "[:%.]"
	local dysText <const> = parserParams:getDysText()
	for i=self.startI,dysText:getLength(),1 do
		if self.methods[dysText:getTextAt(i)] then
			self:writeSelfInFrontOfMethodCall(i,dysText,regex,parserParams)
		end
	end
	return self
end

function RecordParser:handleRecordName(parserParams)
	local newI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
	self.recordName = parserParams:getTokenAtI(newI)
	parserParams:getDysText():writeThreeArgs("function ",self.recordName,"(")
	return newI
end

function RecordParser:parseParams(index,parserParams)
	local openParens <const> = self:loopUntilMatch(parserParams,index,"%(",self.doNothing)
	local closeParens <const> = self:loopUntilMatch(parserParams,openParens + 1,"%)",self:returnFunctionAddingTextToParams())
	return closeParens
end

local function writeAssignmentOfParams(dysText,param)
	dysText:writeFourArgs(param," = ",param,",")
end

local function writeFinalAssigmentOfParams(dysText,param)
	dysText:writeFourArgs(param," = ",param,"}\n")
end

local function writeRecordFunctionParamsToDysText(dysText,param)
	dysText:writeTwoArgs(param,",")
end

local function writeFinalRecordParam(dysText,param)
	dysText:writeTwoArgs(param,")\n")
end

function RecordParser:writeRecordParams(dysText,loopFunc,endingFunc)
	if #self.params > 0 then
		for i=1,#self.params - 1,1 do
			loopFunc(dysText,self.params[i])
		end
		endingFunc(dysText,self.params[#self.params])
	end
	return self
end

function RecordParser:writeRecordFunctionParams(parserParams)
	local dysText <const> = parserParams:getDysText()
	self:writeRecordParams(dysText,writeRecordFunctionParamsToDysText,writeFinalRecordParam)
	return self
end


function RecordParser:writeLocalRecordVar(parserParams)
	local dysText <const> = parserParams:getDysText()
	dysText:writeThreeArgs("\tlocal __",self.recordName,"__ <const> = {")
	self:writeRecordParams(dysText,writeAssignmentOfParams,writeFinalAssigmentOfParams)
	return self
end

function RecordParser:startParsingRecord(parserParams)
	local nameI <const> = self:handleRecordName(parserParams)
	local closingParens <const> = self:parseParams(nameI + 1,parserParams)
	self:writeRecordFunctionParams(parserParams)
	self:writeLocalRecordVar(parserParams)
	parserParams:updateSetI(self,closingParens + 1)
	return self
end

function RecordParser:parseEndRec(parserParams)
	self:writeEndRecord(parserParams)
	self:recordSecondPass(parserParams)
	parserParams:update(self.returnMode,1)
	return self
end

function RecordParser:new(returnMode,startI)
	local o <const> = setmetatable(ClassAndRecordParser:new(returnMode,startI),self)
	o.tokenFuncs['endRec'] = RecordParser.parseEndRec
	return o
end


return RecordParser
