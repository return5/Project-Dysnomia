local FileWriter <const> = require('fileOperations.FileWriter')
local FileAttr <const> = require('fileOperations.FileAttr')
local ParserParameters <const> = require('parser.ParserParameters')
local TokenParser <const> = require('parser.TokenParser')
local DysText <const> = require('parser.DysText')
local RequireParser <const> = require('parser.RequireParser')
local RequireOnlyParser <const> = require('parser.RequireOnlyParser')

local setmetatable <const> = setmetatable

require('parser.ParserDriver')

local Parser <const> = {type = "Parser"}
Parser.__index = Parser

_ENV = Parser


function Parser:parseFile(tokenParser)
	local parserParameters <const> = ParserParameters:new(tokenParser,1,self.text,DysText:new())
	local index = 1
	while index <= #self.text do
		parserParameters.currentMode:parseInput(parserParameters)
		index = parserParameters:getI()
	end
	local fileWriter <const> = FileWriter:new(FileAttr:new(self.filePath,parserParameters:getDysText():getDysText()))
	fileWriter:writeFile()
	return self
end

function Parser:beginParsing()
	return self:parseFile(TokenParser)
end

function Parser:parseLuaFile()
	return self:parseFile(RequireOnlyParser)
end

function Parser:new(text,filePath)
	return setmetatable({filePath = filePath,text = text,methods = {},inClass = false},self)
end

local function postConstruct()
	RequireParser.Parser = Parser
end

postConstruct()

return Parser
