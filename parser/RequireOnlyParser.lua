local TokenParser <const> = require('parser.TokenParser')


local RequireOnlyParser <const> = {type = "RequireOnlyParser"}
RequireOnlyParser.__index = RequireOnlyParser

setmetatable(RequireOnlyParser,TokenParser)

_ENV = RequireOnlyParser

RequireOnlyParser.tokenFuncs = {
	['require'] = TokenParser.parseRequire
}

return RequireOnlyParser
