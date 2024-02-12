local TokenParser <const> = require('dysnomiaParser.TokenParser')
local SingleStatementLambda <const> = require('dysnomiaParser.lambda.SingleStatementLambda')
local MultiStatementLambda <const> = require('dysnomiaParser.lambda.MultiStatementLambda')

local setmetatable <const> = setmetatable

local LambdaInit <const> = {type = "LambdaInit"}
LambdaInit.__index = LambdaInit

setmetatable(LambdaInit,TokenParser)

_ENV = LambdaInit

function LambdaInit:singleStatementLambda(returnMode,parserParams,bodyStartI)
	local singleStatementLambda <const> = SingleStatementLambda:new(returnMode)
	singleStatementLambda:startParsing(parserParams,bodyStartI)
	return self
end

function LambdaInit:multiStatementLambda(returnMode,parserParams,bodyStartI)
	local multiStatementLambda <const> = MultiStatementLambda:new(returnMode)
	multiStatementLambda:startParsing(parserParams,bodyStartI)
	return self
end

function LambdaInit:getBodyStartI(parserParams)
	return self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
end

function LambdaInit:startParsing(returnMode,parserParams)
	local bodyStartI <const> = self:getBodyStartI(parserParams)
	if parserParams:getAt(bodyStartI) ~= "{" then return self:singleStatementLambda(returnMode,parserParams) end
	return self:multiStatementLambda(returnMode,parserParams,bodyStartI)
end


return LambdaInit