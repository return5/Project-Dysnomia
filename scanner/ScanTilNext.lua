local ScanChars <const> = require('scanner.ScanChars')
local setmetatable <const> = setmetatable

local ScanTilNext <const> = {type = 'ScanTilNext'}
ScanTilNext.__index = ScanTilNext

setmetatable(ScanTilNext,ScanChars)

_ENV = ScanTilNext

function ScanTilNext:firstInput(word,char,allWords)
	return self:breakWordThenAddCharToWord(word,char,allWords)
end

function ScanTilNext:parseInput(word,char,allWords)
	if char == self.endingChar then
		self:addCharToWordThenCreateNewWord(word,char,allWords)
		return ScanChars
	end
	self:createNewWord(word,allWords)
	return ScanChars:parseInput(word,char,allWords)
end

function ScanTilNext:new(char)
	return setmetatable({endingChar = char},self)
end

return ScanTilNext
