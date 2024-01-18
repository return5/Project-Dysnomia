
local setmetatable <const> = setmetatable

local LambdaScope <const> = {type = "LambdaScope "}
LambdaScope.__index = LambdaScope

_ENV = LambdaScope


function LambdaScope:new()
	return setmetatable({},self)
end

return LambdaScope
