local ScanChars <const> = require('dysnomiaScanner.ScanChars')
local setmetatable <const> = setmetatable

local SKipTillNewLine <const> = {type = 'ScanTillNewLine'}
SKipTillNewLine.__index = SKipTillNewLine

setmetatable(SKipTillNewLine,ScanChars)

_ENV = SKipTillNewLine

function SKipTillNewLine:parseInput(word,char,allWords)
	if char ~= "\n" then return self:addToTable(char,word) end
	self:addCharToWordThenCreateNewWord(word,char,allWords)
	return ScanChars
end

return SKipTillNewLine

