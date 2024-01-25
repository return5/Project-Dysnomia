local TokenParser <const> = require('parser.TokenParser')
local Scanner <const> = require('scanner.Scanner')
local FileReader <const> = require('fileOperations.FileReader')
local FileSkipper <const> = require('fileOperations.FileSkipper')
local gsub <const> = string.gsub

local RequireParser <const> = {type = 'RequireParser'}
RequireParser.__index = RequireParser

setmetatable(RequireParser,TokenParser)

_ENV = RequireParser

function RequireParser:parseParenthesisStatement(parserParams)
	local fileNameI <const> = self:loopUntilMatch(parserParams,parserParams:getI() + 1,"['\"]",self.doNothing)
	local closingParen <const> = self:loopUntilMatch(parserParams,fileNameI + 1,"%)",self.doNothing)
	local fileName <const> = gsub(parserParams:getAt(fileNameI),"['\"]","")
	return closingParen,fileName
end

function RequireParser:writeFileName(start,stop,parserParams)
	local dysTest <const> = parserParams:getDysText()
	for i=start,stop,1 do
		dysTest:write(parserParams:getAt(i))
	end
	return self
end

function RequireParser:scanAndParseRequiredFile(fileAttr)
	if fileAttr then
		local scanner <const> = Scanner:new(fileAttr)
		local scanned <const> = scanner:scanFile()
		local parser <const> = RequireParser.Parser:new(scanned,fileAttr.filePath)
		if fileAttr.isLuaFile then
			parser:parseLuaFile()
		else
			parser:beginParsing()
		end
	end
	return self
end

function RequireParser:parseRequire(parserParams)
	local closingParen <const>, fileName <const> = self:parseParenthesisStatement(parserParams)
	self:writeFileName(parserParams:getI(),closingParen,parserParams)
	local fileAttr <const> = FileReader:new(fileName):readFile()
	if not FileSkipper:scanForSkipFile(fileAttr) then
		self:scanAndParseRequiredFile(fileAttr)
	end
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
