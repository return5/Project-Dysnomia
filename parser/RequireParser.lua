local TokenParser <const> = require('parser.TokenParser')
local Scanner <const> = require('scanner.Scanner')
local FileReader <const> = require('fileOperations.FileReader')

local RequireParser <const> = {type = 'RequireParser'}
RequireParser.__index = RequireParser

setmetatable(RequireParser,TokenParser)

_ENV = RequireParser

local function parseFileName(fileNameTable)
	return function(text)
		fileNameTable.fileName = text
	end
end

function RequireParser:parseParenthesisStatement(parserParams)
	local openingQuote <const> = self:loopUntilMatch(parserParams,parserParams:getI(),"'\"",self.doNothing)
	local fileNameTable <const> = {}
	local endQuote <const> = self:loopUntilMatch(parserParams,openingQuote + 1,"'\"",parseFileName(fileNameTable))
	local closingParen <const> = self:loopUntilMatch(parserParams,endQuote + 1,"%)",self.doNothing)
	return closingParen,fileNameTable.fileName
end

function RequireParser:writeFileName(start,stop,parserParams)
	local dysTest <const> = parserParams:getDysText()
	for i=start,stop,1 do
		dysTest:write(parserParams:getTokenAtI(i))
	end
	return self
end

function RequireParser:scanAndParseRequiredFile(fileAttr,isLuaFile)
	if fileAttr then
		local scanner <const> = Scanner:new(fileAttr)
		local scanned <const> = scanner:scanFile()
		local parser <const> = RequireParser.Parser:new(scanned,fileAttr.filePath)
		if isLuaFile then
			parser:scanForRequire()
		else
			parser:beginParsing()
		end
	end
	return self
end

function RequireParser:parseRequire(parserParams)
	local closingParen <const>, fileName <const> = self:parseParenthesisStatement(parserParams)
	self:writeFileName(parserParams:getI(),closingParen,parserParams)
	local fileAttr <const>, isLuaFile <const> = FileReader:new(fileName):readFile()
	self:scanAndParseRequiredFile(fileAttr,isLuaFile)
	parserParams:updateSetI(TokenParser,closingParen + 1)
	return self

end

function RequireParser:parseInput(parserParams)
	local prevNewLine <const> = self:loopBackUntilMatch(parserParams,parserParams:getI() - 1,"\n",self.doNothing)
	local prevNonSpace <const> = self:loopBackUntilMatch(parserParams,prevNewLine - 1,"%S",self.doNothing)
	if prevNewLine > 0 and prevNonSpace > 0 and parserParams:isTokenMatchExpression(prevNonSpace,"#skipRequire") then
		parserParams:update(TokenParser,1)
		return self
	end
	self:parseRequire(parserParams)
	return self
end

return RequireParser
