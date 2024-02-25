local TokenParser <const> = require('dysnomiaParser.TokenParser')
local setmetatable <const> = setmetatable
local match <const> = string.match
local concat <const> = table.concat
local remove <const> = table.remove


local ClassAndRecordParser <const> = {type = 'ClassAndRecordParser'}
ClassAndRecordParser.__index = ClassAndRecordParser

setmetatable(ClassAndRecordParser,TokenParser)

ClassAndRecordParser.tokenFuncs = {}
for token,func in pairs(TokenParser.tokenFuncs) do
	ClassAndRecordParser.tokenFuncs[token] = func
end

_ENV = ClassAndRecordParser


function ClassAndRecordParser:writeSelfInFrontOfMethodCall(i,dysText,regex,pattern)
	local prevI <const> = self:loopBackUntilMatch(dysText,i - 1,"%S",self.doNothing)
	local text <const> = dysText:getAt(prevI)
	if text ~= "." and text ~= ":" and not match(text,regex) and not match(text,pattern) then
		dysText:replaceTextAt(pattern .. dysText:getAt(i),i)
	end
	return self
end

function ClassAndRecordParser:secondPass(parserParams,name)
	local regex <const> = name .. "[:%.]"
	local dysText <const> = parserParams:getDysText()
	for i=self.startI,dysText:getLength(),1 do
		if self.class.methods[dysText:getAt(i)] then
			self:writeSelfInFrontOfMethodCall(i,dysText,regex,"self:")
		elseif self.class.staticMethods[dysText:getAt(i)] then
			self:writeSelfInFrontOfMethodCall(i,dysText,regex,"self.")
		end
	end
	return self
end

function ClassAndRecordParser.writeAssignmentOfParams(dysText,param)
	dysText:writeFourArgs(param," = ",param,",")
end

function ClassAndRecordParser.writeParamAndCommaToDysText(dysText,param)
	dysText:writeTwoArgs(param,",")
end

function ClassAndRecordParser:writeParamsToDysText(dysText,params,loopFunc,endingFunc)
	if #params > 0 then
		for i=1,#params - 1,1 do
			loopFunc(dysText,params[i])
		end
	end
	endingFunc(dysText,params[#params])
	return self
end

local function clearWord(word)
	for i=1,#word,1 do
		remove(word)
	end
end

function ClassAndRecordParser:returnFunctionAddingTextToParams(params)
	return function(text,word)
		if text and #text > 0 and text ~= "," then
			word[#word + 1] = text
		elseif text and #text > 0 and text == "," then
			params[#params + 1] = concat(word)
			clearWord(word)
		end
	end
end

function ClassAndRecordParser:parseStaticAndInstanceMethod(parserParams,sep)
	local newI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
	self.class.methods[parserParams:getAt(newI)] = true
	parserParams:getDysText():writeFourArgs("function ",self.classOrRecordName,sep,parserParams:getAt(newI))
	parserParams:updateSetI(self,newI + 1)
	return self
end


function ClassAndRecordParser:parseMethod(parserParams)
	self:parseStaticAndInstanceMethod(parserParams,":")
	return self
end

function ClassAndRecordParser:parseStatic(parserParams)
	local newI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
	parserParams:updateSetI(self,newI)
	self:parseStaticAndInstanceMethod(parserParams,".")
	return self
end

ClassAndRecordParser.tokenFuncs['method'] = ClassAndRecordParser.parseMethod
ClassAndRecordParser.tokenFuncs['static'] = ClassAndRecordParser.parseStatic

function ClassAndRecordParser:new(returnMode,startI)
	return setmetatable({returnMode = returnMode,startI = startI,params = {}},self)
end

return ClassAndRecordParser

