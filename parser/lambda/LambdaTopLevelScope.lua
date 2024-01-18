local LambdaScope <const> = require('parser.lambda.LambdaScope')

local setmetatable <const> = setmetatable

local LambdaTopLevelScope <const> = {type = "LambdaTopLevelScope "}
LambdaTopLevelScope .__index = LambdaTopLevelScope

setmetatable(LambdaTopLevelScope,LambdaScope)

_ENV = LambdaTopLevelScope


function LambdaTopLevelScope:new()
	return setmetatable(LambdaScope:new(),self)
end

return LambdaTopLevelScope
