local ScanTilNext <const> = require('scanner.ScanTilNext')
local ScanTIllNewLine <const> = require('scanner.ScanTillNewLine')
local setmetatable <const> = setmetatable

local ScanMinusSign <const> = {type = 'ScanMinusSign'}
ScanMinusSign.__index = ScanMinusSign

setmetatable(ScanMinusSign,ScanTilNext)

_ENV = ScanMinusSign

function ScanMinusSign:parseInput(word,char,allWords)
	if char == self.endingChar then
		return self:parseEndingChar(word,char,allWords)
	end
	if char == self.commentChar then
		self:addToTable(char,word)
		return ScanTIllNewLine
	end
	return self:parseNotEndingChar(word,char,allWords)
end

function ScanMinusSign:new()
	local o <const> = setmetatable(ScanTilNext:new("="),self)
	o.commentChar = "-"
	return o
end


return ScanMinusSign
