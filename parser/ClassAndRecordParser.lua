local TokenParser <const> = require('parser.TokenParser')
local setmetatable <const> = setmetatable

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

function ClassAndRecordParser:new(returnMode,startI)
	return setmetatable({returnMode = returnMode,startI = startI,params = {},methods = {}},self)
end

return ClassAndRecordParser
