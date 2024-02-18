local ScanChars <const> = require('dysnomiaScanner.ScanChars')
local setmetatable <const> = setmetatable

local ScanSpaces <const> = {type = 'ScanSpaces'}
ScanSpaces.__index = ScanSpaces

setmetatable(ScanSpaces,ScanChars)

_ENV = ScanSpaces

function ScanSpaces:scanFirstSpace(word,char,allWords)
	self:breakWordThenAddCharToAllWords(word,char,allWords)
	return self
end

function ScanSpaces:parseInput(word,char,allWords)
	if not self.spaceChars[char] then
		self:createNewWord(word,allWords)
		return ScanChars:parseInput(word,char,allWords)
	end
	self:addToTable(char,word)
	return self
end


return ScanSpaces

