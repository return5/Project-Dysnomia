local TokenParser <const> = require('parser.TokenParser')
local SingleStatementLambda <const> = require('parser.lambda.SingleStatementLambda')
local setmetatable <const> = setmetatable
local write <const> = io.write

local LambdaInit <const> = {type = "LambdaInit"}
LambdaInit.__index = LambdaInit

setmetatable(LambdaInit,TokenParser)

_ENV = LambdaInit

function LambdaInit:singleStatementLambda(returnMode,parserParams)
	local singleStatementLambda <const> = SingleStatementLambda:new(returnMode)
	singleStatementLambda:startParsing(parserParams)
	return self
end

function LambdaInit:getBodyStartI(parserParams)
	return self:loopUntilMatch(parserParams,parserParams:getI() + 1,"%S",self.doNothing)
end

function LambdaInit:startParsing(returnMode,parserParams)
	local bodyStartI <const> = self:getBodyStartI(parserParams)
	if parserParams:getAt(bodyStartI) ~= "{" then return self:singleStatementLambda(returnMode,parserParams) end
	-- TODo implement multi statement lambdas
	-- () ->
	-- a -> a
	-- (a,b) ->
	--	func(a -> b,c -> d) if true then return f -> g end statement; g -> h
end


return LambdaInit