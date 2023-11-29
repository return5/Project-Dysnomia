local ScanChars <const> = require('scanner.ScanChars')
local setmetatable <const> = setmetatable

local ScanSpaces <const> = {type = 'ScanSpaces'}
ScanSpaces.__index = ScanSpaces
local io = io

setmetatable(ScanSpaces,ScanChars)

_ENV = ScanSpaces

function ScanSpaces:scanFirstSpace(word,char,allWords)
	io.write("breaking new word\n")
	self:breakWordThenAddCharToAllWords(word,char,allWords)
	return self
end

function ScanSpaces:parseInput(word,char,allWords)
	io.write("scan spaces input\n")
	if not self.spaceChars[char] then
		io.write("not space: ",char,"\n")
		self:createNewWord(word,allWords)
		return ScanChars:parseInput(word,char,allWords)
	end
	self:addToTable(char,word)
	return self
end


return ScanSpaces
