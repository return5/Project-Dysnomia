local ScanTilNext <const> = require('dysnomiaScanner.ScanTilNext')
local ScanTIllNewLine <const> = require('dysnomiaScanner.ScanTillNewLine')
local setmetatable <const> = setmetatable

local ScanMinusSign <const> = {type = 'ScanMinusSign'}
ScanMinusSign.__index = ScanMinusSign

setmetatable(ScanMinusSign,ScanTilNext)

_ENV = ScanMinusSign

function ScanMinusSign:parseInput(word,char,allWords)
	if self.endingChars[char] then
		return self:parseEndingChar(word,char,allWords)
	end
	if char == self.commentChar then
		self:addToTable(char,word)
		return ScanTIllNewLine
	end
	return self:parseNotEndingChar(word,char,allWords)
end

function ScanMinusSign:new()
	local o <const> = setmetatable(ScanTilNext:new({["="] = true, [">"] = true}),self)
	o.commentChar = "-"
	return o
end


return ScanMinusSign

