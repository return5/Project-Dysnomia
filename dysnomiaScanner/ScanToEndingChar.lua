local ScanChars <const> = require('dysnomiaScanner.ScanChars')
local setmetatable <const> = setmetatable

local ScanToEndingChar <const> = {type = 'ScanToEndingChar'}
ScanToEndingChar.__index = ScanToEndingChar

setmetatable(ScanToEndingChar,ScanChars)

_ENV = ScanToEndingChar

function ScanToEndingChar:openingChar(word,char)
	self:addToTable(char,word)
	return self
end

function ScanToEndingChar:parseInput(word,char,allWords)
	if not self:checkIfCharIsEscaped(word) and char == self.endingChar then
		self:addCharToWordThenCreateNewWord(word,char,allWords)
		return ScanChars
	end
	self:addToTable(char,word)
	return self
end

function ScanToEndingChar:new(endingChar)
	return setmetatable({endingChar = endingChar},self)
end


return ScanToEndingChar
