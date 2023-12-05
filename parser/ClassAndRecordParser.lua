local TokenParser <const> = require('parser.TokenParser')
local setmetatable <const> = setmetatable
local io = io

local ClassAndRecordParser <const> = {type = 'ClassAndRecordParser'}
ClassAndRecordParser.__index = ClassAndRecordParser

setmetatable(ClassAndRecordParser,TokenParser)

ClassAndRecordParser.tokenFuncs = {}
for token,func in pairs(TokenParser.tokenFuncs) do
	ClassAndRecordParser.tokenFuncs[token] = func
end

_ENV = ClassAndRecordParser


function ClassAndRecordParser:returnFunctionAddingTextToParams()
	return function(text)
		if text and #text > 0 and text ~= "," then
			self.params[#self.params + 1] = text
		end
	end
end

function ClassAndRecordParser:parseMethod(parserParams)
	local newI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
	self.methods[parserParams:getAt(newI)] = true
	parserParams:getDysText():writeFourArgs("function ",self.classOrRecordName,":",parserParams:getAt(newI))
	local openParens <const>  = self:loopUntilMatch(parserParams,newI + 1,"%(",self.doNothing)
	parserParams:updateSetI(self,newI + 1)
	return self
end

ClassAndRecordParser.tokenFuncs['method'] = ClassAndRecordParser.parseMethod

function ClassAndRecordParser:new(returnMode,startI)
	return setmetatable({returnMode = returnMode,startI = startI,params = {},methods = {}},self)
end

return ClassAndRecordParser
