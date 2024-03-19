local ClassAndRecordParser <const> = require('dysnomiaParser.classandrecord.ClassAndRecordParser')
local Class <const> = require('dysnomiaParser.classandrecord.Class')
local setmetatable <const> = setmetatable
local write = io.write

local RecordParser <const> = {type = 'RecordParser'}
RecordParser.__index = RecordParser

setmetatable(RecordParser,ClassAndRecordParser)

RecordParser.tokenFuncs = {}
for token,func in pairs(ClassAndRecordParser.tokenFuncs) do
	RecordParser.tokenFuncs[token] = func
end

_ENV = RecordParser

function RecordParser:writeSetmetatableForRecord(parserParams)
	parserParams:getDysText():writeFiveArgs("\t\treturn setmetatable({},{__index = ",self.classOrRecordName,
			',__newindex = function() error("attempt to update a record: ',self.classOrRecordName,'") end,__len = function() return #'):writeFourArgs(self.classOrRecordName,
			" end, __pairs = function() return function(_,k) return next(",self.classOrRecordName,",k) end end");
	self.metaMethodsI = parserParams:getDysText():getLength()
	parserParams:getDysText():write("})\n")
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

local function writeFinalRecordParam(dysText,param)
	dysText:writeTwoArgs(param,")\n")
end

function RecordParser:writeRecordFunctionParams(parserParams)
	self:writeParamsToDysText(parserParams:getDysText(),self.params,self.writeParamAndCommaToDysText,writeFinalRecordParam)
	return self
end

function RecordParser:writeLocalRecordVar(parserParams)
	parserParams:getDysText():writeThreeArgs("\tlocal ",self.classOrRecordName," <const> = {}\n")
	return self
end

function RecordParser:writeNewConstructor(parserParams)
	parserParams:getDysText():writeThreeArgs("\tfunction ",self.classOrRecordName,":new()\n")
	return self
end

function RecordParser.writeAssignmentOfParams(dysText,param)
	dysText:writeFiveArgs('\t\tself.',param,' = ',param,"\n")
end

function RecordParser:writeDefaultConstructor(parserParams)
	self:writeNewConstructor(parserParams)
	self:writeParamsToDysText(parserParams:getDysText(),self.params,self.writeAssignmentOfParams,self.writeAssignmentOfParams)
	return self
end

function RecordParser:createClassObject()
	self.class = Class:new(self.classOrRecordName,self.params)
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

function RecordParser:writeConstructorIfNoneProvided(parserParams)
	if not self.foundConstructor then
		self:writeDefaultConstructor(parserParams)
		self:writeSetmetatableForRecord(parserParams)
		parserParams:getDysText():write("\tend\n")
	end
	return self
end

function RecordParser:returnConstructorCall(parserParams)
	parserParams:getDysText():writeThreeArgs("\treturn ",self.classOrRecordName,":new()\nend\n")
	return self
end

function RecordParser:parseEndRec(parserParams)
	self:writeConstructorIfNoneProvided(parserParams)
	self:returnConstructorCall(parserParams)
	self:secondPass(parserParams,self.originalRecordName,",")
	parserParams:update(self.returnMode,1)
	return self
end

local openBlocks <const> = {
	['do'] = true,
	['then'] = true,
	['function'] = true,
}

function RecordParser:parseOverBlocksUntil(parserParams)
	local index = parserParams:getI()
	local limit <const> = parserParams:getLength()
	local count = 1
	while count > 0 and index <= limit do
		local token <const> = parserParams:getCurrentToken()
		if openBlocks[token] then count = count + 1 elseif token == 'end' then count = count - 1 end
		parserParams.currentMode:parseInput(parserParams)
		index = parserParams:getI()
	end
	return index
end

function RecordParser:writeEndOfConstructor(parserParams)
	parserParams:getDysText():replaceTextAt("",parserParams:getDysText():getLength())
	self:writeSetmetatableForRecord(parserParams)
	parserParams:getDysText():write("\tend\n")
	return self
end

function RecordParser:writeSuperConstructorIfNeed(parserParams)
	local startI <const> = self:loopUntilMatch(parserParams,parserParams:getI(),"%)",self.doNothing) + 1
	parserParams:setI(startI)
	return self:parseOverBlocksUntil(parserParams)
end

function RecordParser:writeStartOfConstructor(parserParams)
	self:writeNewConstructor(parserParams)
	return self
end

RecordParser.tokenFuncs['endRec'] = RecordParser.parseEndRec

function RecordParser:new(returnMode,startI)
	return setmetatable(ClassAndRecordParser:new(returnMode,startI),self)
end


return RecordParser

