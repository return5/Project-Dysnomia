local LambdaParser <const> = require('parser.lambda.LambdaParser')

local setmetatable <const> = setmetatable


local MultiStatementLambda <const> = {type = "MultiStatementLambda"}
MultiStatementLambda.__index = MultiStatementLambda

setmetatable(MultiStatementLambda,LambdaParser)

_ENV = MultiStatementLambda

function MultiStatementLambda:parseInput(parserParams)
	local char <const> = parserParams:getCurrentToken()
	if char == "{" then
		self.bracketCount = self.bracketCount + 1
	elseif char == "}" then
		self.bracketCount = self.bracketCount - 1
	end
	if (self:endingFunc(char) and self.bracketCount == 0) or not parserParams:isIWithinLen() then
		return self:finishLambda(parserParams)
	end
	return LambdaParser.parseInput(self,parserParams)
end

function MultiStatementLambda:finishLambda(parserParams)
	parserParams:getDysText():write(" end ")
	parserParams:update(self.returnMode,1)
	return self
end

local endingChars <const> = {
	["}"] = true,
}

function MultiStatementLambda:endingFunc(char)
	return endingChars[char]
end

function MultiStatementLambda:startParsing(parserParams,bodyStartI)
	LambdaParser.startParsing(self,parserParams)
	parserParams:updateSetI(self,bodyStartI + 1)
	return self
end

function MultiStatementLambda:new(returnMode)
	local o <const> = setmetatable(LambdaParser:new(returnMode),self)
	o.bracketCount = 1
	return o
end

return MultiStatementLambda

