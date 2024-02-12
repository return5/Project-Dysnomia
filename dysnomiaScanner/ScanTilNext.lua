local ScanChars <const> = require('dysnomiaScanner.ScanChars')
local setmetatable <const> = setmetatable

local ScanTilNext <const> = {type = 'ScanTilNext'}
ScanTilNext.__index = ScanTilNext

setmetatable(ScanTilNext,ScanChars)

_ENV = ScanTilNext

function ScanTilNext:firstInput(word,char,allWords)
	return self:breakWordThenAddCharToWord(word,char,allWords)
end

function ScanTilNext:parseEndingChar(word,char,allWords)
	self:addCharToWordThenCreateNewWord(word,char,allWords)
	return ScanChars
end

function ScanTilNext:parseNotEndingChar(word,char,allWords)
	self:createNewWord(word,allWords)
	return ScanChars:parseInput(word,char,allWords)
end

function ScanTilNext:parseInput(word,char,allWords)
	if self.endingChars[char] then
		return self:parseEndingChar(word,char,allWords)
	end
	return self:parseNotEndingChar(word,char,allWords)
end

function ScanTilNext:new(endingChars)
	return setmetatable({endingChars = endingChars},self)
end

return ScanTilNext
