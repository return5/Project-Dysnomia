local ScanChars <const> = require('scanner.ScanChars')
local setmetatable <const> = setmetatable

local ScanEqualSign <const> = {type = 'ScanEqualSign'}
ScanEqualSign.__index = ScanEqualSign

setmetatable(ScanEqualSign,ScanChars)

 _ENV = ScanEqualSign


local mathOps <const> = {
	["+"] = true,
	["-"] = true,
	["/"] = true,
	["*"] = true
}

function ScanEqualSign:checkIfNMathChar(char)
	return mathOps[char] ~= nil
end

function ScanEqualSign:parseInput(word,char,allWords)
	if not self:checkMathChar(word[#word]) then self:createNewWord(word,allWords) end
	self:addCharToWordThenCreateNewWord(word,char,allWords)
	return ScanChars
end

return ScanEqualSign
