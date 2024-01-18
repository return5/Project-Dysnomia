local StringParser <const> = require('parser.StringParser')

local setmetatable <const> = setmetatable

local BracketStringParser <const> = {type = "BracketStringParser"}
BracketStringParser.__index = BracketStringParser

_ENV = BracketStringParser

function BracketStringParser:new(returnMode)
	return setmetatable(StringParser:new(returnMode,"]"),self)
end

return BracketStringParser
