local FileWriter <const> = require('dysnomiaFileOperations.FileWriter')
local FileAttr <const> = require('dysnomiaFileOperations.FileAttr')
local ParserParameters <const> = require('dysnomiaParser.ParserParameters')
local TokenParser <const> = require('dysnomiaParser.TokenParser')
local DysText <const> = require('dysnomiaParser.DysText')
local RequireParser <const> = require('dysnomiaParser.RequireParser')
local RequireOnlyParser <const> = require('dysnomiaParser.RequireOnlyParser')

local setmetatable <const> = setmetatable

require('dysnomiaParser.ParserDriver')

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
